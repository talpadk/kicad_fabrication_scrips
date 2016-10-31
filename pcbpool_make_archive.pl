#!/usr/bin/perl

use strict;
use File::Temp;
use Cwd;
use File::stat;
use File::Basename;
use Time::localtime;
use Getopt::Long;

my $scriptPath = dirname(__FILE__);

my $unzipCmd = "file-roller";
my $show = 0;

my %options = (
    'show' => \$show,
    'show-cmd=s' => \$unzipCmd
    );

GetOptions(%options);


my $defaultColour = "\e[39m";
my $redColour = "\e[31m";
my $yellowColour = "\e[33m";

my $blink = "\e[5m";
my $resetAttribs = "\e[0m";

sub fatalError {
    my $line = $_[0];
    die "$blink$redColour$line$defaultColour$resetAttribs\n";
}

sub warning {
    my $line = $_[0];
    print "$blink$yellowColour$line$defaultColour$resetAttribs\n";
}

sub notice{
    my $line = $_[0];
    print "$yellowColour$line$defaultColour\n";
}

sub printStatus {
    my $line = $_[0];
    print $line."\n";
}

my $newestSource = undef;
my $newestSourceTime = undef;


sub updateSourceTime {
    my $filename = $_[0];
    my $status = stat($filename);

    my $mtime = $status->mtime;
    if (!defined($newestSourceTime) ||
	$mtime > $newestSourceTime){

	$newestSource = $filename;
	$newestSourceTime = $mtime;
    }    
}

sub checkFileDateVsSource {
    my $filename = $_[0];
    my $status = stat($filename);

    my $mtime = $status->mtime;
    if ($mtime < $newestSourceTime){
	warning("$filename is older than $newestSource please consider rebuilding your output files");
    }
}

my $projectName = "";



my @fileNames = split(/\n/, `ls`);
foreach my $filename (@fileNames){
    if ($filename =~ /^(.*)\.pro$/){
	updateSourceTime($filename);
	if (!($projectName eq "")){
	    fatalError("Multible *.pro files fount in the current directory, unable to determine the project name");
	}
	$projectName = $1
    }
    if ($filename =~ /^(.*)\.sch$/ ||
	$filename =~ /^(.*)\.kicad_pcb$/){
	updateSourceTime($filename);
    }
}

if ($projectName eq ""){
    fatalError("No *.pro file found in the current directory, unable to determine the project name");
}


printStatus("#" x (length($projectName)+4));
printStatus("# ".$projectName." #");
printStatus("#" x (length($projectName)+4));
printStatus("\n");


#Check BOM
my $generateAssemblyInformation = 0;
my $hasBom = 0;
my $bomName = $projectName."_bom.csv";
if (-e $bomName){
    $hasBom = 1;
    $generateAssemblyInformation = 1;
    checkFileDateVsSource($bomName);
}
else {
    notice("Project without a BOM, generating archive without assembly instructions");
}

#Check assembly docs
my $hasAssemblyPdf = 0;
my $assemblyName = 'assembly.pdf';
if ($generateAssemblyInformation){
    if (-e $assemblyName){
	$hasAssemblyPdf = 1;
	checkFileDateVsSource($assemblyName);
    }
    else {
	fatalError("An assembly.pdf is required for assembly by PCBpool");
    }
}

my $hasPickAndPlaceFile = 0;
my $pickAndPlaceName = "gerber/$projectName-all.pos";
if ($generateAssemblyInformation){
    if (-e $pickAndPlaceName){
	$hasPickAndPlaceFile = 1;
	checkFileDateVsSource($pickAndPlaceName);
    }
    else {
	fatalError("A pick and place file is required for assembly");
    }
}
    

#Check gerber files for existance and age
if (!(-d "gerber")){
    fatalError("No folder called 'gerber' was not found");
}

my @gerberFiles = split(/\n/, `ls gerber`);
foreach my $filename (@gerberFiles){
    checkFileDateVsSource("gerber/$filename");
}


#DONE checking, build zip archive

my $oldPath = cwd();

my $tmpDir = File::Temp->newdir();
my $tmpDirName = $tmpDir->dirname;
my $outputDirectory = "$tmpDirName/$projectName";

`mkdir -p '$outputDirectory'`;

#Handling of gerber files
`cp -r gerber '$outputDirectory'`;

#Build BOM
`cat '$bomName' | $scriptPath/bom2pcbpool.pl | $scriptPath/compress_pcbpool_bom.pl > '$outputDirectory/pcbpool_bom.csv'`;

#Handling of assembly information
`cp $assemblyName '$outputDirectory'`;

if ($hasPickAndPlaceFile){
    chdir($outputDirectory."/gerber");
    print `cat ../$pickAndPlaceName | $scriptPath/make_pcbpool_pick_and_place.pl`;
    if ($? != 0){
	fatalError("Failed to generate pick and place files");
    }
}

#Add a README.txt
chdir($outputDirectory);
print `$scriptPath/make_readme.pl`;
my $errorCode = $?;
if ($errorCode != 0){
    warning("Failed to create a README.txt");
}

#Generate the zip archive
chdir($tmpDirName);
`zip -r /tmp/test.zip '$projectName'`;
chdir($oldPath);

if ($show){
    print `$unzipCmd /tmp/test.zip`;
}



#!/usr/bin/perl
use strict;

my $outputFile = "README.TXT";
our $file;
open($file, ">$outputFile") or die("Unable to write to $outputFile");

our @outputBuffer = ();
our $maxLength = 0;

sub output {
    my @data = split(/\t/, $_[0]);
    our $outputBuffer;
    push (@outputBuffer, \@data);
    if ($#data > 1-1){
	if (length($data[0])>$maxLength){
	    $maxLength = length($data[0]);
	}
    }
}
sub flushBuffer(){
    our $file;

    our @outputBuffer;

    foreach my $row (@outputBuffer){
	my @dataSet = @{$row};
	my $key = $dataSet[0];
	my $value = $dataSet[1];
	my $data = sprintf "%-*s %s", $maxLength+3, $key, $value;
	print $file $data."\r\n";
    }
}


my %knownTypes = ('Gerber_Pick&Place.txt'=>'PCB-POOL formated pick and place file',
		  'gerbv_pick_and_place.csv'=>'Internal use, pick and place file compatible with the gerbv program',
		  '-all.pos'=>'Internal use, raw output pick and place data from kicad',
		  '-B.Cu.gbl'=>'Gerber bottom copper layer',
		  '-B.Mask.gbs'=>'Gerber bottom solder mask',
		  '-B.SilkS.gbo'=>'Gerber bottom silk screen',
		  '-B.Paste.gbp'=>'Gerber bottom solder paste',
		  '[^H].drl'=>'Drill file for plated holes',
		  '-NPTH.drl'=>'Drill file for non plated holes',
		  '-Edge.Cuts.gm1'=>'Gerber edge cuts',
		  '-F.Cu.gtl'=>'Gerber top copper layer',
		  '-F.Mask.gts'=>'Gerber top solder mask',
		  '-F.SilkS.gto'=>'Gerber top silk screen',
		  '-F.Paste.gtp'=>'Gerber top solder paste',
		  'pcbpool_bom_compact.csv'=>'PCB-POOL formated Bill Of Materials file',
		  'pcbpool_bom.csv'=>'PCB-POOL formated Bill Of Materials file',
		  'README.TXT'=>'This file',
		  'assembly.pdf'=>'A pdf file describing/showing the location and orientation of the different parts'
		  
    );




output ("This file describes the content of the folder");
output ("");
output ("The gerber files are supposed to have Protel like file suffixes");
output ("");
output ("");
output ("Files:");
output ("");

my @content = sort(split(/\n/,`ls gerber`));
foreach my $entry (@content){
    my $matchFound = 0;

    foreach my $type (keys(%knownTypes)){
	if ($entry =~ /$type$/){
	    output ("gerber/$entry\t$knownTypes{$type}");
	    $matchFound = 1;
	}
    }
    
    if (!$matchFound){
	die("No information on '$entry'\n");
    }
}

my @content = sort(split(/\n/,`ls`));
foreach my $entry (@content){
    my $matchFound = 0;

    foreach my $type (keys(%knownTypes)){
	if ($entry =~ /$type$/){
	    output ("$entry\t$knownTypes{$type}");
	    $matchFound = 1;
	}
    }
    if ($entry eq "gerber"){
	$matchFound = 1;
    }
    
    if (!$matchFound){
	die("No information on '$entry'\n");
    }
}


flushBuffer();
close (file);

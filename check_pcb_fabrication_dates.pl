#!/usr/bin/perl

use strict;
use Getopt::Long;
use Pod::Usage;
use File::stat;
use Cwd;
use File::Temp;

my $showHelp = 0;
my $testPath = undef;

my %options = (
  'help' => \$showHelp,
  'test|t:s' => \$testPath
);

GetOptions(%options) or pod2usage(2);

if ($showHelp || (! defined $testPath)){
  pod2usage(1);
}

=pod

=head1 NAME
    
  check_pcb_fabrication_dates.pl checks modification times of files in a folder or .zip archive with regard to source (*.sch, *.kicad_pcb, *.pro) files in the current directory. Any file that isn't newer than the newest source is reported

=head1 SYNOPSIS

  check_pcb_fabrication_dates.pl -t "folder or .zip file to check"

=head1 OPTIONS
    
=over 1

=item B<--help>
Shows this help

=item B<--test|-t>
The folder or file to test

=back

=cut

my $newestSource = undef;
my $newestSourceTime = undef;
my $hadWarnings = 0;

sub warning {
    my $line = $_[0];
    print "$line\n";
    $hadWarnings = 1;
}

sub checkFileDateVsSource {
  my $filename = $_[0];
  my $status = stat($filename);

  my $mtime = $status->mtime;
  if ($mtime < $newestSourceTime){
    warning("$filename is older than $newestSource please consider rebuilding your output files");
  }
}

sub updateSourceTime {
  my $filename = $_[0];
  print "checking source $filename\n";
  my $status = stat($filename);
    
  my $mtime = $status->mtime;
  if (!defined($newestSourceTime) || $mtime > $newestSourceTime){
    $newestSource = $filename;
    $newestSourceTime = $mtime;
  }
}

sub doTest {
  my $path = $_[0];
  my @destinationFiles = split(/\n/, `find $path`);
  for my $test (@destinationFiles){
    if (-f $test) {
      checkFileDateVsSource($test);
    }
  }
}

my @fileNames = split(/\n/, `ls`);
foreach my $filename (@fileNames){
  if ($filename =~ /^(.*)\.(sch|kicad_pcb|pro)$/){
    updateSourceTime($filename);
  }
}
if (! defined $newestSourceTime) {
  print STDERR "Didn't find any source files in the current directory, is the current directory a kicad project?\n";
  exit 1;
}

if (-f $testPath) {
  my $oldCWD = getcwd();
  my $tmpDir = File::Temp->newdir;
  chdir($tmpDir);
  `unzip '$oldCWD/$testPath'`;
  doTest(".");
  chdir($oldCWD);
}
else {
  doTest($testPath);
}

if ($hadWarnings) {
  print STDERR "\n\n";
  print STDERR "===============================================\n";
  print STDERR "=== There were file that wasn't up to date! ===\n";
  print STDERR "===============================================\n";
  print STDERR "\n\n";
  exit 1;
}
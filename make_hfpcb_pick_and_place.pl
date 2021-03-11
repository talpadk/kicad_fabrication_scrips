#!/usr/bin/perl
use strict;


my $validHeaderFoundInInput = 0;
my $onlyTopSideComponents = 1;

my @inputData = ();

while (<STDIN>){
  my $isComment = 0;
  my $line = $_;
  my @data = split(/\s+/, $line);
  if (substr($data[0], 0,1) eq '#') {
    $isComment = 1;
  }
  
  if ($#data == 8-1){
    if (join('', @data) eq "#RefValPackagePosXPosYRotSide"){
      $validHeaderFoundInInput = 1;
    }
  }
  if ($#data == 7-1 && !$isComment){
    my %lineHash = ();
    $lineHash{'ref'} = $data[0];
    $lineHash{'val'} = $data[1];
    $lineHash{'package'} = $data[2];
    $lineHash{'x'} = $data[3];
    $lineHash{'y'} = $data[4];
    $lineHash{'rot'} = $data[5]; #Counter clockwise unlike most other packages (but makes much math sense)
    $lineHash{'side'} = $data[6];

    if (!($lineHash{'side'} eq "top")){
      $onlyTopSideComponents = 0;
    }

    push (@inputData, \%lineHash);	
  }    
}

sub outputPcbPoolLine {
    my $outputFile = $_[0];
    my %rowHash = %{$_[1]};

    my $x = sprintf("%.0f", $rowHash{'x'}/0.0254);
    my $y = sprintf("%.0f", $rowHash{'y'}/0.0254);
    my $rotation = 0+$rowHash{'rot'};
    if (!($rotation == 0)){
      $rotation = 360.0-$rotation;
    }
    $rotation = sprintf("%.0f", $rotation);
    my $ref = $rowHash{'ref'};
    my $val = $rowHash{'val'};
    my $pack = $rowHash{'package'};

    #format according to the .txt example file
    $ref = sprintf("%-21s", $ref);
    $x = sprintf("%-10s", $x);
    $y = sprintf("%11s", $y);
    $rotation = sprintf("%9s", $rotation);


 
    print $outputFile "$ref$x$y$rotation    $pack\r\n";
}

if (!$onlyTopSideComponents) {
  print STDERR "ERROR: It is unknown how hfpcb wants the data if there are more than one side to populate\n";
  exit 1;
}
elsif ($validHeaderFoundInInput){
  my $outputFile;
  my $outputFilename = "PnP_for_hfpcb_top_side.txt";
  open ($outputFile, ">$outputFilename") or die("Unable to write to '$outputFilename'\n");

  print $outputFile "UUNITS = MILS\r\n";

  foreach my $row (@inputData){
    my %rowHash = %{$outputFile, $row};
    my $ref = $rowHash{'ref'};    
    if (substr($ref, 0, 3) eq 'REF'){
      outputPcbPoolLine($outputFile, $row);
    }
  }
        
  foreach my $row (@inputData){
    my %rowHash = %{$row};
    my $ref = $rowHash{'ref'};
    if (!(substr($ref, 0, 3) eq 'REF')){
      outputPcbPoolLine($outputFile, $row);
    }
  }
  close($outputFile);

  $outputFilename = "gerbv_pick_and_place.csv";
  open ($outputFile, ">$outputFilename") or die("Unable to write to '$outputFilename'\n");
  print $outputFile  "#ref, description, val, pos_x, pos_y, rot, layer\n";
  print $outputFile  "#X,y in mils, rotation in degrees clockwise\n";
  foreach my $row (@inputData){
    my %rowHash = %{$row};
    my $x = $rowHash{'x'}/0.0254;
    my $y = $rowHash{'y'}/0.0254;
    my $rotation = 0+$rowHash{'rot'};
    if (!($rotation == 0)){
      $rotation = 360.0-$rotation;
    }
    print $outputFile $rowHash{'ref'}.",\"\",\"".$rowHash{'val'}."\",".$x.",".$y.",".$rotation.",".$rowHash{'side'}."\n";
  }
  close($outputFile);
}
else {
  print STDERR "Error: Unabled to find a valid header in the kicad pnp data on std in!\n";
  exit 1
}

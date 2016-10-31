#!/usr/bin/perl
use strict;

#should be configureable by cmd line arguments
my $positionString = "left under edge: X=0 / Y=0";


my $validHeaderFoundInInput = 0;

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
	$lineHash{'rot'} = $data[5];
	$lineHash{'side'} = $data[6];
	push (@inputData, \%lineHash);	
    }
    
}

sub outputPcbPoolLine {
    my $outputFile = $_[0];
    my %rowHash = %{$_[1]};

    my $x = $rowHash{'x'};
    my $y = $rowHash{'y'};
    my $rotation = 0+$rowHash{'rot'};
    if (!($rotation == 0)){
	$rotation = 360.0-$rotation;
    }
    my $ref = $rowHash{'ref'};
    my $val = $rowHash{'val'};
    my $side = $rowHash{'side'};
    my $pack = $rowHash{'package'};
 
    print $outputFile "$ref\t$x\t$y\t$rotation\t$val\t$pack\t$side\n";
}

if ($validHeaderFoundInInput){
    my $outputFile;
    my $outputFilename = "Gerber_Pick&Place.txt";
    open ($outputFile, ">$outputFilename") or die("Unable to write to '$outputFilename'\n");

    print $outputFile "Filename:\t$outputFilename\n\n";

    print $outputFile "Position of PCB:\n$positionString\n\n";

    print $outputFile "name\tX-axis\tY-axis\tangle\tvalue\tpackage\tside\n\n";

    foreach my $row (@inputData){
	my %rowHash = %{$outputFile, $row};
	my $ref = $rowHash{'ref'};
	
	if (substr($ref, 0, 3) eq 'REF'){
	    outputPcbPoolLine($outputFile, $row);
	}
    }
    
    print $outputFile "\n";
    
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

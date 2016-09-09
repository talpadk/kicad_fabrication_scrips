#!/usr/bin/perl

use strict;

my $firstLine = <STDIN>;
print $firstLine;

my %entries = ();


while (<STDIN>){
    my @lineData = split(/,/,$_);
    my $reference = $lineData[0];
    splice(@lineData, 0,1);
    my $key = join(',', @lineData);
   
    if (defined($entries{$key})){
	my @refs = @{$entries{$key}};
	push(@refs, $reference);
	$entries{$key} = \@refs;
    }
    else {
	my @array = ($reference);
	$entries{$key} = \@array;
    }
}

sub sortFunction{
    my @aData = split(/,/,$a);
    my @bData = split(/,/,$b);

    
    my $aKey = $aData[6].$aData[7].join(',',sort(@{$entries{$a}}));
    my $bKey = $bData[6].$bData[7].join(',',sort(@{$entries{$b}}));

    return $aKey cmp $bKey;
}

my @outputKeys = keys(%entries);
@outputKeys = sort sortFunction @outputKeys;

foreach my $key (@outputKeys){
    my @refs = @{$entries{$key}};
    @refs = sort(@refs);

    my @data = split(/,/,$key);
    splice(@data, 5,1, ($#refs+1));
    
    print '"'.join(',', @refs).'",'.join(',',@data);
}
    

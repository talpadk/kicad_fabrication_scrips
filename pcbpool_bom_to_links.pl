#!/usr/bin/perl

use strict;

my $webLinkIndex = -1;
my $placeIndex = -1;
my $suppliedIndex = -1;
    
my $amountIndex = -1;

my $amountName = "OrderQty";

my @cols = split(/,/, <stdin>, -1);
my $colNumber=0;
foreach my $col (@cols){
    if ($col eq "Weblink") {
	$webLinkIndex = $colNumber;
    }
    if ($col eq "Place_YES/NO"){
	$placeIndex = $colNumber;
    }
    if ($col eq "Provided_by_customer_YES/NO"){
	$suppliedIndex = $colNumber
    }
    if ($col eq $amountName) {
	$amountIndex = $colNumber;
    }
    $colNumber++;
}

print "<html><body>\n";

if ($webLinkIndex >= 0 && $placeIndex >= 0 && $suppliedIndex >= 0){

    if ($amountIndex < 0){
	print "<h2>'$amountName' was not found unable to list the order amount</h2>\n";
    }

    while(<stdin>){
	my $line = $_;
	#"escape" , inside quotes
	while($line =~ s/"([^"^,]+),/"$1;/){}
	
	my @cols = split(/,/, $line, -1);
	my $needToBuy = 1;

	if ($cols[$placeIndex] eq "no" ||
	    $cols[$suppliedIndex] eq "no"){
	    $needToBuy = 0;
	}

	if ($needToBuy){
	    my $url = $cols[$webLinkIndex];
	    if ($amountIndex >= 0) {
		print $cols[$amountIndex]."x ";
	    }
	    print "<a href=\"$url\">$url</a><br />\n";
	}
    }
}
else {
    print "<h1>'Weblink' or 'Place_YES/NO' or 'Provided_by_customer_YES/NO' column not found aborting!!!</h1>";
}
print "</body></html>\n";

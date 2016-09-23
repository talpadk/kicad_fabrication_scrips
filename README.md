# kicad_fabrication_scripts
A collection of scripts to help with generating files for having PCBs fabricated


## Files

* bom2csv.xsl, the XML transform from the kicad project github page, consider checking for a newer version. Included for ease of use.
* bom2pcbpool.pl, reads a BOM formatted as a CVS file from STDIN and outputs a Bill of materials with the correct columns for a BOM file suited for assembly at pcbpool.com on STDOUT
* compress_pcbpool_bom.pl, reads the output from bom2pcbpool.pl on STDIN and "compresses" it by joining / grouping similar components on one line.
* make_readme.pl, a script that generates a README.txt in the current working directory explaining the files in the current working directory as well as the folder gerber
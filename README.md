# kicad_fabrication_scripts
A collection of scripts to help with generating files for having PCBs fabricated

The scripts are supposed to automate not only the process of generating the archive files send to the fabrication house,
but also attempt to detect/prevent human errors for instance ensure that the files in the .zip are more recent that the kicad files used to generate them.


* pcbpool_make_archive.pl, when called from the folder containing the kicad .pro project file it generates a /tmp/test.zip file containing the files needed for fabrication by pcbpool.
* check_pcb_fabrication_dates, a script for checking a folder or zip file for out of date files
* bom2csv.xsl, the XML transform from the kicad project github page, consider checking for a newer version. Included for ease of use.
* bom2pcbpool.pl, reads a BOM formatted as a CVS file from STDIN and outputs a Bill of materials with the correct columns for a BOM file suited for assembly at pcbpool.com on STDOUT
* compress_pcbpool_bom.pl, reads the output from bom2pcbpool.pl on STDIN and "compresses" it by joining / grouping similar components on one line.
* make_readme.pl, a script that generates a README.txt in the current working directory explaining the files in the current working directory as well as the folder gerber
* make_pcbpool_pick_and_place.pl reads a kicad .pos file (unit mm and both side in one file) and outputs Gerber_Pick&Place.txt (pcb-pool format) and gerbv_pick_and_place.csv (readable by gerbv) to current directory
* make_hfpcb_pick_and_place.pl reads a kicad .pos file (unit mm and both side in one file) and outputs PnP_for_hfpcb_top_side.txt (high five pcb format) and gerbv_pick_and_place.csv (readable by gerbv) to current directory

## Dependencies
sudo apt install perl libfile-homedir-perl zip
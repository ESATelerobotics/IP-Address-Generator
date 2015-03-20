# IP-Address-Generator
Program that generates a dynamic ip for a 24 subnet

Intended usage for scripte where the textoutput can be used directly

##build
mkdir build
cd build
gnatmake ../generate_random_ip.adb

No installation mechanism yet

###usage 
for help type 
generate_random_ip --help

## Example usage

###exmaple generate a random ip between 192.168.55.46-89
./generate_random_ip 192.168.55. --lower_limit 46 --upper_limit 89

###exmaple generate a random ip between 192.168.55.46-89 but exclude 56,57,65
./generate_random_ip 192.168.55. --lower_limit 46 --upper_limit 89 --avoid 56,57,65


 

# IP-Address-Generator
Program that generates a random ip for a 24 subnet the output is text with the intended usage for script where the text output can be used directly

##How to build
```$>mkdir build```
```$>cd build```
```$>gnatmake ../generate_random_ip.adb```

No installation mechanism yet

##Usage 
###Help
for help type 
```$>generate_random_ip --help```
The first parameter has to be the base IP-address

###Examples

####Generate a random ip between 192.168.55.46-89
```$>./generate_random_ip 192.168.55. --lower_limit 46 --upper_limit 89```


####Generate a random ip between 192.168.55.46-89 but exclude 56,57,65
```./generate_random_ip 192.168.55. --lower_limit 46 --upper_limit 89 --avoid 56,57,65```


 

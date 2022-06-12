#!/bin/sh
#
# install-all-dev-packages.sh
#
# Author: Andrew Smith http://littlesvr.ca
# Version 1.0 (12 Dec 2012)
#
# The following script installs all the -dev and -doc packages that should have
# been installed with your software but were omitted for some stupid reason.
#
# Tested on Linux Mint 13 but should work on any Debian/Ubuntu/Mint 
# or really on any Debian derivative.
#
# If you get errors like A : Conflicts: B but C is to be installed
# then add those packages (all of the A) into the following list:  
#BADPKGLIST="libdb5.1 libglew1.5 libglew1.6 librdf0"

# List of all available packages
apt-cache pkgnames > /tmp/allpackages

NEWPKGLIST="build-essential"

echo "Searching for required -dev and -doc packages..."
for PKG in `dpkg --get-selections | cut -f 1`
do
  # Make sure it's not in the ignore list
  echo $BADPKGLIST | grep -q $PKG
  if [ $? -eq 0 ]
  then
    continue
  fi
  # See if a -dev package is available
  grep -qe "^$PKG-dev$" /tmp/allpackages
  if [ $? -eq 0 ]
  then
    NEWPKGLIST=" $NEWPKGLIST $PKG-dev"
  fi
  # See if a -doc package is available
  #grep -qe "^$PKG-doc$" /tmp/allpackages
  #if [ $? -eq 0 ] 
  #then
  #  NEWPKGLIST=" $NEWPKGLIST $PKG-doc"
  #fi
done

echo "The following packages have been found:"
echo
echo sudo apt-get install $NEWPKGLIST
echo
echo -n "Do you want to install them? (y/n) "
read YN
if [ a$YN = ay ]
then
  sudo apt-get install $NEWPKGLIST --install-suggests
fi

if [ $? -eq 100 ]
then
  echo
  echo "If you got apt-get erros such as 'A Conflicts: B but C is to be installed'"\
       " then make a change at the top of this script to ignore those packages,"\
       " hopefully that will work."
fi


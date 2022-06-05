#!/bin/bash
#clear

. ~/.functions.sh

shift # strip the -c that vim adds to bash from arguments to this script
fill_echo $stout "XXX   $@"
eval $@

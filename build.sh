#!/bin/bash

PATH=$PATH:`cat $HOME/.Garmin/ConnectIQ/current-sdk.cfg`/bin
set -x

# build via monkeyc 
monkeyc -d fenix3 -f monkey.jungle -o BatHist.prg -y ../thekr1s.key

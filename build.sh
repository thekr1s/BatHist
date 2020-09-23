#!/bin/bash

PATH=$PATH:`cat $HOME/.Garmin/ConnectIQ/current-sdk.cfg`/bin
set -x

# build via monkeyc 
monkeyc -d fenix3 -f monkey.jungle -o AviatorLike.prg -y ../thekr1s.key

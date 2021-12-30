#!/bin/bash

PATH=$PATH:`cat $HOME/.Garmin/ConnectIQ/current-sdk.cfg`/bin
set -x


/usr/lib/jvm/java-11-openjdk-amd64/bin/java -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar /home/robert/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-3.2.2-2020-08-28-a50584d55/bin/monkeybrains.jar -o /home/robert/proj/garmin/BatHist.iq -e -w -y /home/robert/proj/garmin/thekr1s.key -r -f /home/robert/proj/garmin/Aviatorlike/monkey.jungle 

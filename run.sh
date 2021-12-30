#!/bin/bash

PATH=$PATH:`cat $HOME/.Garmin/ConnectIQ/current-sdk.cfg`/bin


# kill the simulator if it's running
pkill simulator

# launch the simulator, and wait
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/eclipse/garmin/extra/usr/lib/x86_64-linux-gnu/
connectiq&
sleep 3

# run the app, as the corresponding device type
monkeydo BatHist.prg fenix3

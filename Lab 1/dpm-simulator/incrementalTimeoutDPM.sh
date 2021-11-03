#!/bin/bash

psm="example/psm.txt"
wl="../workloads/workload_1.txt"
outputfile="EnergyStats.txt"
>$outputfile
for timeout in {0..1000}; do
	printf "%d " $timeout >>$outputfile
	./dpm_simulator.exe -t $timeout -psm $psm -wl $wl | grep -o " Energy w DPM.*" | egrep -o "[0-9]+\.[0-9]+" >>$outputfile
done

exit 0

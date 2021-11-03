#!/bin/bash

psm="example/psm.txt"
wl="../workloads/workload_1.txt"
stats="EnergyStats.txt"
tmpfile="tmpfile.txt"
>$stats
for timeout in {0..10}; do
	./dpm_simulator.exe -t $timeout -psm $psm -wl $wl >$tmpfile
	printf "%d " $timeout >>$stats
	grep -o "Energy w DPM.*" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n'>>$stats
	printf " " >>$stats
	grep "Time overhead for transition" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n'>> $stats
	printf " " >>$stats
	fgrep "N. of transition" <$tmpfile | egrep -o "[0-9]+" >> $stats 
done

rm -f $tmpfile

exit 0

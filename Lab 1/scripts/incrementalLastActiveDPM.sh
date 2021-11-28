#!/bin/bash

main_dir="../dpm-simulator"
psm="$main_dir/example/psm.txt"
wl="$main_dir/../workloads/workload_1.txt"
stats="$main_dir/../results/LastActiveResults.txt"
tmpfile="tmpfile.txt"
dpm_simulator="$main_dir/dpm_simulator.exe"
>$stats
for thrSleep in {1..100}; do
	for (( thrIdle = thrSleep + 1; thrIdle < 100; thrIdle++ )) do
	$dpm_simulator -la $thrSleep $thrIdle -psm $psm -wl $wl >$tmpfile 
	printf "%d %d" $thrSleep $thrIdle >>$stats
	printf " " >>$stats
	grep -o "Energy w DPM.*" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n'>>$stats
	printf " " >>$stats
	grep "Time overhead for transition" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n'>> $stats
	printf " " >>$stats
	fgrep "N. of transition" <$tmpfile | egrep -o "[0-9]+" >> $stats 
	done
done

rm -f $tmpfile

exit 0

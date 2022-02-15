#!/bin/bash

main_dir="../dpm-simulator"
psm="$main_dir/example/psm.txt"
wl="$main_dir/../workloads/workload_2.txt"
stats="$main_dir/../results/__NEW__LastActiveResults_wl2.txt"
tmpfile="tmpfile.txt"
dpm_simulator="$main_dir/dpm_simulator"
>$stats

for thrIdle in {1..100}; do
	for (( thrSleep = thrIdle + 1; thrSleep < 1000; thrSleep++ )) do
	$dpm_simulator -la $thrIdle $thrSleep -psm $psm -wl $wl >$tmpfile 
	
    printf "%d %d" $thrIdle $thrSleep >>$stats
	printf " " >>$stats
	
    grep -o "Energy w DPM.*" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n'>>$stats
	printf " " >>$stats

    grep -o "Time w DPM.*" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n' >> $stats
	printf " " >>$stats
	
    grep "Time overhead for transition" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n'>> $stats
	printf " " >>$stats
	
    fgrep "N. of transition" <$tmpfile | egrep -o "[0-9]+" >> $stats 
	done
done

rm -f $tmpfile

exit 0

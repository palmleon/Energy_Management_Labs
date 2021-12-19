#!/bin/bash

main_dir="../dpm-simulator"
psm="$main_dir/example/psm.txt"
wl="$main_dir/../workloads/workload_2.txt"
stats="$main_dir/../results/__NEW__historybasedDPM_wl2.txt"
tmpfile="tmpfile.txt"
dpm_simulator="$main_dir/dpm_simulator"
>$stats

printf "x (1-x) x(1-x) energy time overhead #transitions\n" >> $stats
x=0
_x=0
sx=0
for timeout in {0..100}; do
    x=$(python -c "print($timeout/100.0)")
    _x=$(python -c "print(1-$x)")
    sx=$(python -c "print($x*$_x)") 
	$dpm_simulator -h 0 $x 0 $_x $sx 0 74 0 -psm $psm -wl $wl >$tmpfile 
	printf "%.2f %.2f %.2f " $x $_x $sx >>$stats

	grep -o "Energy w DPM.*" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n' >>$stats
	printf " " >>$stats

    grep -o "Time w DPM.*" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n' >> $stats
	printf " " >>$stats

	grep "Time overhead for transition" <$tmpfile | egrep -o "[0-9]+\.[0-9]+" | tr -d '\n' >> $stats
	printf " " >>$stats
	
    fgrep "N. of transition" <$tmpfile | egrep -o "[0-9]+" >> $stats 
done

rm -f $tmpfile

exit 0

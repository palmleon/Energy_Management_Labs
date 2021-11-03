#!/bin/bash

wl="../workloads/$1"
outputfile="../results/$2"
>$outputfile
declare -i i=0
for line in $(cat $wl); do
	if (( i % 2 == 0 )); then
		begin=$line
	else 
		end=$line
		(( duration = $end - $begin ))
		echo $duration >>$outputfile
	fi
	i=$i+1
done
exit 0

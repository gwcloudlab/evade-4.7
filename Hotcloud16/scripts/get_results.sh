#!/bin/bash

dt=$(date +"%y-%m-%d")
DIR=/home/sundarcs/Hotcloud16/exp/$dt/httperf
vms=(opensuse ubuntu)
INTS=(10 30 50 70 100 200)
for vm in ${vms[@]}; do
	echo "Results for $vm"
	for i in ${INTS[@]}; do
	    grep 'Request rate' $DIR/$vm/httperf-$i.out | awk '{print $3}'
	    grep suspend_and_send_dirty $DIR/$vm/remus-httperf-$i.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
	    grep dirty_pages $DIR/$vm/remus-httperf-$i.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
	    grep Dirty $DIR/$vm/remus-httperf-$i.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
	done
done

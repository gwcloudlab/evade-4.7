#!/bin/bash

dt=$(date +"%y-%m-%d")
vms=ubuntu
a=httperf
DIR=/home/sundarcs/Hotcloud16/exp/$dt/$a
#INTS=(10 30 50 70 100 200)
INTS=(30)
category=(nonet local local-nonet)
for vm in ${vms[@]}; do
	echo "Baseline Results for httperf"
	grep 'Request rate' $DIR/$vm/$a-0.out | awk '{print $3}'
	for i in ${INTS[@]}; do
	    echo "Results for $vm with interval $i"
	    grep 'Request rate' $DIR/$vm/$a-$i.out | awk '{print $3}'
	    grep "suspend domain" $DIR/$vm/remus-$a-$i.log | awk '{print $7}' | awk '{sum=sum+$1} END {print sum/NR}'
	    # grep suspend_and_send_dirty $DIR/$vm/remus-$a-$i.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
	    # grep dirty_pages $DIR/$vm/remus-$a-$i.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
	    grep Dirty $DIR/$vm/remus-$a-$i.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
	done

	for b in ${category[@]}; do
		echo "$b"
		grep 'Request rate' $DIR/$vm/$a-$i-$b.out | awk '{print $3}'
		grep "suspend domain" $DIR/$vm/remus-$a-$i-$b.log | awk '{print $7}' | awk '{sum=sum+$1} END {print sum/NR}'
		# grep suspend_and_send_dirty $DIR/$vm/remus-$a-$i-$b.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
		# grep dirty_pages $DIR/$vm/remus-$a-$i-$b.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
		grep Dirty $DIR/$vm/remus-$a-$i-$b.log | awk '{print $8}' | awk '{sum=sum+$1} END {print sum/NR}'
	done
done

#!/bin/zsh

HOME='/home/sundarcs'
DIR='/home/sundarcs/ycsb_thread_out'
YCSB='/home/sundarcs/YCSB'

APPS=(memcached cassandra2-cql)
INTS=(10 30 50 70 100 200)

THRD=50

for a in ${APPS[@]}; do
	for i in ${INTS[@]}; do
		cd $HOME
		sudo xl -vvvv remus -Fd -i $i ubuntu1204 nimbnode11 > $DIR/remus-$a-$i 2>&1 &
		sleep 15
		tail -f $DIR/remus-$a-$i > $DIR/"remus-$a-$i-keep" &
		last_pid=$!
		cd $YCSB
		$YCSB/bin/ycsb load $a -P $YCSB/workloads/wl_neel -P $YCSB/props/$a.props -threads $THRD -s > $DIR/"remus-ycsb-$a-$i-LOAD"
		$YCSB/bin/ycsb run $a -P $YCSB/workloads/wl_neel  -P $YCSB/props/$a.props -threads $THRD -s > $DIR/"remus-ycsb-$a-$i-RUN"
		sudo kill -KILL $last_pid
		ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy ubuntu1204--incoming"
		sleep 15
		echo "**** Respawning Remus, finished $a $i test.... ****"
	done
done

echo HiVJbkb3 | sudo -S tar cfz /raid/backup2/security/benchmark_results/mar8_remus_ycsb_thread_logs.tar.gz $DIR

echo " ***** TADAAA! *****"
echo " ***** LOGS IN RAID! *****"

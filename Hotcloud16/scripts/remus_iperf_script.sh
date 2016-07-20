#!/bin/zsh

HOME='/home/sundarcs'
DIR='/home/sundarcs/remus_sleep_5000us/iperf_out_suse'

#INTS=(10 30 50 70 100 200)
INTS=(50)
a="iperf"

ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-0-out &"
echo -e "xentop running on nn11"
iperf -c 192.168.1.92 -P 10 -t 30 > $DIR/remus-iperf-0-OUT
ssh sundarcs@nimbnode11 "sudo pkill xentop"
echo -e "xentop killed and iperf ran"

for i in ${INTS[@]}; do
	cd $HOME
	sudo xl -vvvv remus -Fd -i $i opensuse nimbnode11 > $DIR/remus-iperf-$i 2>&1 &
	echo -e "started remus, now sleep"
	sleep 15
	tail -f $DIR/remus-iperf-$i > $DIR/remus-iperf-$i-keep &
	last_pid=$!
	echo -e "tailing remus log file"
	ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-$i-out &"
	echo -e "xentop running on nn11"
	iperf -c 192.168.1.92 -P 10 -t 30 > $DIR/remus-iperf-$i-OUT
	ssh sundarcs@nimbnode11 "sudo pkill xentop"
	echo -e "xentop killed and iperf ran"
	sudo kill -KILL $last_pid
	ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy opensuse--incoming"
	sleep 15
	echo "**** Respawning Remus, finished $a $i test.... ****"
done

#echo HiVJbkb3 | sudo -S tar cfz /raid/backup2/security/benchmark_results/mar8_remus_iperf_logs.tar.gz $DIR

echo " ***** TADAAA! *****"
echo " ***** LOGS IN RAID! *****"

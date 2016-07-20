#!/bin/zsh

a=httperf
vms=(opensuse ubuntu)
dt=$(date +"%y-%m-%d")

HOME='/home/sundarcs'

mkdir -p $HOME/Hotcloud16/exp/$dt/$a/$vms[1]
mkdir -p $HOME/Hotcloud16/exp/$dt/$a/$vms[2]

DIR=$HOME/Hotcloud16/exp/$dt/$a

INTS=(10 30 50 70 100 200)
#INTS=(50)

for vm in ${vms[@]}; do

	# Initially run $a without remus enabled
	ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-0-out &"
	echo -e "xentop running on nn11"
	$a --hog --server $vm-xen --port 80 --num-conn 100000 --num-call 100 --timeout 5 --rate 10000 > $DIR/$vm/$a-0.out
	ssh sundarcs@nimbnode11 "sudo pkill xentop"
	echo -e "xentop killed and $a ran"

	for i in ${INTS[@]}; do
		cd $HOME
		sudo xl -vvvv remus -Fd -i $i ubuntu nimbnode11 > $DIR/$vm/remus-$a-$i 2>&1 &
		echo -e "started remus, now sleep"
		sleep 15
		tail -f $DIR/$vm/remus-$a-$i > $DIR/$vm/remus-$a-$i.log &
		last_pid=$!
		echo -e "tailing remus log file"
		ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-$i-out &"
		echo -e "xentop running on nn11"
		$a --hog --server $vm-xen --port 80 --num-conn 100000 --num-call 100 --timeout 5 --rate 10000 > $DIR/$vm/$a-$i.out
		ssh sundarcs@nimbnode11 "sudo pkill xentop"
		echo -e "xentop killed and $a ran"
		sudo kill -KILL $last_pid
		ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
		sleep 15
		echo "**** Respawning Remus, finished $vm $a $i test.... ****"
	done
done

	#echo HiVJbkb3 | sudo -S tar cfz /raid/backup2/security/benchmark_results/mar8_remus_$a_logs.tar.gz $DIR

	#echo " ***** TADAAA! *****"
	#echo " ***** LOGS IN RAID! *****"

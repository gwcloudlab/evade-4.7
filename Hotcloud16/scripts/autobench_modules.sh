#!/bin/zsh

BENCH=autobench
VMS=(ubuntu)
DT=$(date +"%y-%m-%d")
#INTS=(10 30 50 70 100 200)
INTS=(30)
RATE=300
HOME='/home/sundarcs'
mkdir -p $HOME/Hotcloud16/exp/$DT/$BENCH/$VMS
ssh sundarcs@10.0.0.42 "mkdir -p $BENCH"
DIR=$HOME/Hotcloud16/exp/$DT/$BENCH/


noremus ()
{
	local vm=$1
	local i=$2
	# Initially run $BENCH with remus disabled
	echo "Running no remus"
	ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-0-xentop &"
	echo -e "xentop running on nn11"
	autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $RATE --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$BENCH-0.out
	ssh sundarcs@10.0.0.42 "sudo pkill xentop"
	echo -e "xentop killed and $BENCH ran"
}

remus-remote ()
{
	local vm=$1
	local i=$2
	echo "Running remus with netbuf enabled"
	cd $HOME
	sudo xl -vvvv remus -Fd -i $i ubuntu 10.0.0.42 > $DIR/$vm/remus-$BENCH-$i 2>&1 &
	echo -e "started remus, now sleep"
	sleep 15
	tail -f $DIR/$vm/remus-$BENCH-$i > $DIR/$vm/remus-$BENCH-$i.log &
	last_pid=$!
	echo -e "tailing remus log file"
	ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-$i-xentop &"
	echo -e "xentop running on nn11"
	autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $RATE --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$BENCH-$i.out
	ssh sundarcs@10.0.0.42 "sudo pkill xentop"
	echo -e "xentop killed and $BENCH ran"
	sudo kill -KILL $last_pid
	ssh 10.0.0.42 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
	sleep 15
}

remus-remote-nonet ()
{
	local vm=$1
	local i=$2
	echo "Running remus with netbuf disabled"
	cd $HOME
	sudo xl -vvvv remus -Fnd -i $i ubuntu 10.0.0.42 > $DIR/$vm/remus-$BENCH-$i-nonet 2>&1 &
	echo -e "started remus, now sleep"
	sleep 15
	tail -f $DIR/$vm/remus-$BENCH-$i-nonet > $DIR/$vm/remus-$BENCH-$i-nonet.log &
	last_pid=$!
	echo -e "tailing remus log file"
	ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-$i-nonet-xentop &"
	echo -e "xentop running on nn11"
	autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $RATE --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$BENCH-$i-nonet.out
	ssh sundarcs@10.0.0.42 "sudo pkill xentop"
	echo -e "xentop killed and $BENCH ran"
	sudo kill -KILL $last_pid
	ssh 10.0.0.42 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
	sleep 15
}

remus-local ()
{
	local vm=$1
	local i=$2
	echo "Running remus with netbuf enabled on localhost"
	cd $HOME
	sudo xl -vvvv remus -Fd -i $i ubuntu localhost > $DIR/$vm/remus-$BENCH-$i-local 2>&1 &
	echo -e "started remus, now sleep"
	sleep 15
	tail -f $DIR/$vm/remus-$BENCH-$i-local > $DIR/$vm/remus-$BENCH-$i-local.log &
	last_pid=$!
	echo -e "tailing remus log file"
	sudo xentop -b -d 1 > $DIR/$vm/remus-$BENCH-$i-local-xentop &
	echo -e "xentop running on localhost"
	autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $RATE --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$BENCH-$i-local.out
	sudo pkill xentop
	echo -e "xentop killed and $BENCH ran"
	sudo kill -KILL $last_pid
	sudo xl destroy ubuntu--incoming
	sleep 15
}

remus-local-nonet ()
{
	local vm=$1
	local i=$2
	echo "Running remus with netbuf disabled on localhost"
	cd $HOME
	sudo xl -vvvv remus -Fnd -i $i ubuntu localhost > $DIR/$vm/remus-$BENCH-$i-local-nonet 2>&1 &
	echo -e "started remus, now sleep"
	sleep 15
	tail -f $DIR/$vm/remus-$BENCH-$i-local-nonet > $DIR/$vm/remus-$BENCH-$i-local-nonet.log &
	last_pid=$!
	echo -e "tailing remus log file"
	sudo xentop -b -d 1 > $DIR/$vm/remus-$BENCH-$i-local-nonet-xentop &
	echo -e "xentop running on localhost"
	autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $RATE --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$BENCH-$i-local-nonet.out
	sudo pkill xentop
	echo -e "xentop killed and $BENCH ran"
	sudo kill -KILL $last_pid
	sudo xl destroy ubuntu--incoming
	sleep 15
}

plot-graph ()
{
	local vm=$1
	local i=$2
	cd $DIR/$vm/
	rm *.pdf
	bench2graph $BENCH-0.out noremus.pdf
	bench2graph $BENCH-30.out remus-remote-30.pdf
	bench2graph $BENCH-30-nonet.out remus-remote-nonet-30.pdf
	bench2graph $BENCH-30-local.out remus-local.pdf
	bench2graph $BENCH-30-local-nonet.out remus-local-nonet.pdf

	scp -r *.pdf sunny@161.253.74.130:~/Dropbox/autobench/
}

main ()
{
	for VM in ${VMS[@]}; do

		#noremus $VM

		for interval in ${INTS[@]}; do

			# Remus with netbuf enabled
			#remus-remote $VM $interval

			# Remus with netbuf disabled
			remus-remote-nonet $VM $interval

			# Remus with netbuf enabled on localhost
			remus-local $VM $interval

			# Remus with netbuf disabled on localhost
			#remus-local-nonet $VM $interval

		done
	done

plot-graph $VM $interval

}

main "$@"

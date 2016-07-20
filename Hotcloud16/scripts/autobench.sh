#!/bin/zsh

a=autobench
vms=(ubuntu)
dt=$(date +"%y-%m-%d")
#INTS=(10 30 50 70 100 200)
INTS=(30)
r=300
HOME='/home/sundarcs'
mkdir -p $HOME/Hotcloud16/exp/$dt/$a/$vms
DIR=$HOME/Hotcloud16/exp/$dt/$a/


for vm in ${vms[@]}; do
: <<'END'
	ssh sundarcs@nimbnode11 "mkdir -p $a"
	# Initially run $a with remus disabled
	echo "Running no remus"
	ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-0-xentop &"
	echo -e "xentop running on nn11"
	autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $r --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$a-0.out
	ssh sundarcs@nimbnode11 "sudo pkill xentop"
	echo -e "xentop killed and $a ran"

END
	for i in ${INTS[@]}; do
: <<'END'
		# Remus with netbuf disabled
		echo "Running remus with netbuf disabled"
		cd $HOME
		sudo xl -vvvv remus -Fnd -i $i ubuntu nimbnode11 > $DIR/$vm/remus-$a-$i-nonet 2>&1 &
		echo -e "started remus, now sleep"
		sleep 15
		tail -f $DIR/$vm/remus-$a-$i-nonet > $DIR/$vm/remus-$a-$i-nonet.log &
		last_pid=$!
		echo -e "tailing remus log file"
		ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-$i-nonet-xentop &"
		echo -e "xentop running on nn11"
		autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $r --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$a-$i-nonet.out
		ssh sundarcs@nimbnode11 "sudo pkill xentop"
		echo -e "xentop killed and $a ran"
		sudo kill -KILL $last_pid
		ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
		sleep 15
END

		# Remus with netbuf enabled
		echo "Running remus with netbuf enabled"
		cd $HOME
		sudo xl -vvvv remus -Fd -i $i ubuntu nimbnode11 > $DIR/$vm/remus-$a-$i 2>&1 &
		echo -e "started remus, now sleep"
		sleep 15
		tail -f $DIR/$vm/remus-$a-$i > $DIR/$vm/remus-$a-$i.log &
		last_pid=$!
		echo -e "tailing remus log file"
		ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-$i-xentop &"
		echo -e "xentop running on nn11"
		autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $r --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$a-$i.out
		ssh sundarcs@nimbnode11 "sudo pkill xentop"
		echo -e "xentop killed and $a ran"
		sudo kill -KILL $last_pid
		ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
		sleep 15

: <<'END'
		# Remus with netbuf enabled on localhost
		echo "Running remus with netbuf enabled on localhost"
		cd $HOME
		sudo xl -vvvv remus -Fd -i $i ubuntu localhost > $DIR/$vm/remus-$a-$i-local 2>&1 &
		echo -e "started remus, now sleep"
		sleep 15
		tail -f $DIR/$vm/remus-$a-$i-local > $DIR/$vm/remus-$a-$i-local.log &
		last_pid=$!
		echo -e "tailing remus log file"
		sudo xentop -b -d 1 > $DIR/$vm/remus-$a-$i-local-xentop &
		echo -e "xentop running on localhost"
		autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $r --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$a-$i-local.out
		sudo pkill xentop
		echo -e "xentop killed and $a ran"
		sudo kill -KILL $last_pid
		sudo xl destroy ubuntu--incoming
		sleep 15

		# Remus with netbuf enabled on localhost
		echo "Running remus with netbuf disabled on localhost"
		cd $HOME
		sudo xl -vvvv remus -Fnd -i $i ubuntu localhost > $DIR/$vm/remus-$a-$i-local-nonet 2>&1 &
		echo -e "started remus, now sleep"
		sleep 15
		tail -f $DIR/$vm/remus-$a-$i-local-nonet > $DIR/$vm/remus-$a-$i-local-nonet.log &
		last_pid=$!
		echo -e "tailing remus log file"
		sudo xentop -b -d 1 > $DIR/$vm/remus-$a-$i-local-nonet-xentop &
		echo -e "xentop running on localhost"
		autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate 20 --high_rate $r --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file $DIR/$vm/$a-$i-local-nonet.out
		sudo pkill xentop
		echo -e "xentop killed and $a ran"
		sudo kill -KILL $last_pid
		sudo xl destroy ubuntu--incoming
		sleep 15
END
	done
done

cd $DIR/$vm/
bench2graph $a-0.out noremus.ps
bench2graph $a-30.out remus-remote-30.ps
bench2graph $a-30-nonet.out remus_remote-nonet-30.ps
bench2graph $a-30-local.out remus-local.ps
bench2graph $a-30-local-nonet.out remus-local-nonet.ps

scp -r *.pdf sunny@161.253.74.130:~/Desktop/autobench/

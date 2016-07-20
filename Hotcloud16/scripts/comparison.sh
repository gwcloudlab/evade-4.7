#!/bin/zsh

a=httperf
vms=(ubuntu)
dt=$(date +"%y-%m-%d")
#INTS=(10 30 50 70 100 200)
INTS=(30)
base_rate=(150)
base_num_conn=(27000)

HOME='/home/sundarcs'

for vm in ${vms[@]}; do
	for j in `seq 1 10`; do
		r=$(expr $base_rate \* $j)
		c=$(expr $base_num_conn \* $j)
		mkdir -p $HOME/Hotcloud16/exp/$dt/$a/$j/$vms
		DIR=$HOME/Hotcloud16/exp/$dt/$a/$j
		echo "Iteration: $j. Running base rate of $r and base connection of $c"
		# Initially run $a with remus disabled
		echo "Running no remus"
		ssh sundarcs@nimbnode11 "sudo xentop -b -d 1 > $a/remus-$a-0-xentop &"
		echo -e "xentop running on nn11"
		$a --hog --server ubuntu-xen --port 80 --rate $r --num-conn $c --num-call 1 --timeout 5 > $DIR/$vm/$a-0.out
		ssh sundarcs@nimbnode11 "sudo pkill xentop"
		echo -e "xentop killed and $a ran"

		for i in ${INTS[@]}; do
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
			$a --hog --server ubuntu-xen --port 80 --rate $r --num-conn $c --num-call 1 --timeout 5 > $DIR/$vm/$a-$i-nonet.out
			ssh sundarcs@nimbnode11 "sudo pkill xentop"
			echo -e "xentop killed and $a ran"
			sudo kill -KILL $last_pid
			ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
			sleep 15

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
			$a --hog --server ubuntu-xen --port 80 --rate $r --num-conn $c --num-call 1 --timeout 5 > $DIR/$vm/$a-$i.out
			ssh sundarcs@nimbnode11 "sudo pkill xentop"
			echo -e "xentop killed and $a ran"
			sudo kill -KILL $last_pid
			ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
			sleep 15

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
			$a --hog --server ubuntu-xen --port 80 --rate $r --num-conn $c --num-call 1 --timeout 5 > $DIR/$vm/$a-$i-local.out
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
			$a --hog --server ubuntu-xen --port 80 --rate $r --num-conn $c --num-call 1 --timeout 5 > $DIR/$vm/$a-$i-local-nonet.out
			sudo pkill xentop
			echo -e "xentop killed and $a ran"
			sudo kill -KILL $last_pid
			sudo xl destroy ubuntu--incoming
			sleep 15

		done
	done
done

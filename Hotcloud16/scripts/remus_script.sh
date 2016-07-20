#!/bin/zsh

DIR='/home/sundarcs/remus_log'

INTS=(10 30 50 70 100 200)
a=(mbw)

for i in ${INTS[@]}; do
	sudo xl -vvvv remus -Fd -i $i ubuntu1204 nimbnode11 > $DIR/$a/remus_$i 2>&1 &
	sleep 15
	tail -f $DIR/$a/remus_$i > $DIR/$a/"remus-$a-$i-keep" &
	last_pid=$!
	ssh root@192.168.1.199 "mbw 400 -n 50 > /root/mbw/remus-mbw-$i"
	sudo kill -KILL $last_pid
	ssh nimbnode11 "echo HiVJbkb3 | sudo -S xl destroy ubuntu1204--incoming"
	sleep 15
	echo "Respawing remus in 15 seconds..."
done
#tail -f $DIR/remus.log > $DIR/mbw/remus_30.log &
#last_pid=$!
#ssh root@192.168.1.199 'mbw 420 -n 50 > domU_mbw_30.log'
#sudo kill -KILL $last_pid

#tail -f $DIR/remus.log > $DIR/filebench/remus_30.log &
#last_pid=$!
#ssh root@192.168.1.199 'echo 0 > /proc/sys/kernel/randomize_va_space'
#ssh root@192.168.1.199 'filebench -f /tmp/fileserver-noninteractive.f > domU_filebench_30.log'
#sudo kill -KILL $last_pid

#tail -f $DIR/remus.log > $DIR/httperf/remus_300.log &
#last_pid=$!
#ssh root@192.168.1.199 'httperf --hog --server www.google.com --uri "/" --num-conn 30000 --num-call 1 --timeout 5 --rate 500 --port 80 > tee domU_httperf_300.log'

#sudo kill -KILL $last_pid

echo "TADAAA!"

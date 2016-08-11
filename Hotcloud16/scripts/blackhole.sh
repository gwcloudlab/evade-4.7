#!/bin/zsh

BENCH=autobench
VMS=(ubuntu-blackhole)
DT=$(date +"%y-%m-%d")
HOME='/home/sundarcs'
mkdir -p $HOME/evade-4.7/Hotcloud16/exp/$DT/$BENCH/$VMS
ssh sundarcs@10.0.0.42 "mkdir -p $BENCH"
DIR=$HOME/evade-4.7/Hotcloud16/exp/$DT/$BENCH/

#INTS=(10 30 50 70 100 200)
INTS=(30)
LOW_RATE=20
HIGH_RATE=60
RATE_STEP=20
NUM_CALL=100
TOT_CONN=12000
#time taken = TOT_CONN / (RATE * NUM_CALL) seconds

noremus ()
{
    local vm=$1
    local i=$2
    # Initially run $BENCH with remus disabled
    echo "Running no remus"
    ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-0-xentop &"
    echo -e "xentop running on nn42"
    autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-0.out
    ssh sundarcs@10.0.0.42 "sudo pkill xentop"
    echo -e "xentop killed and $BENCH ran"
}

remus-remote ()
{
    local vm=$1
    local i=$2
    echo "Running remus with netbuf enabled"
    cd $HOME
    sudo xl -vvvv remus -Fdb -i $i ubuntu 10.0.0.42 > $DIR/$vm/remus-$BENCH-$i 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i > $DIR/$vm/remus-$BENCH-$i.log &
    last_pid=$!
    echo -e "tailing remus log file"
    ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-$i-xentop &"
    echo -e "xentop running on nn42"
    autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i.out
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
    sudo xl -vvvv remus -Fndb ubuntu 10.0.0.42 > $DIR/$vm/remus-$BENCH-$i-nonet 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i-nonet > $DIR/$vm/remus-$BENCH-$i-nonet.log &
    last_pid=$!
    echo -e "tailing remus log file"
    ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-$i-nonet-xentop &"
    echo -e "xentop running on nn42"
    autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i-nonet.out
    ssh sundarcs@10.0.0.42 "sudo pkill xentop"
    echo -e "xentop killed and $BENCH ran"
    sudo kill -KILL $last_pid
    ssh 10.0.0.42 "echo HiVJbkb3 | sudo -S xl destroy ubuntu--incoming"
    sleep 15
}

remus-local ()
{
    sudo rmmod ifb && sudo modprobe ifb
    sudo rmmod ifb && sudo modprobe ifb
    local vm=$1
    local i=$2
    echo "Running remus with netbuf enabled on localhost"
    cd $HOME
    sudo xl -vvvv remus -Fdb -i $i ubuntu localhost > $DIR/$vm/remus-$BENCH-$i-local 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i-local > $DIR/$vm/remus-$BENCH-$i-local.log &
    last_pid=$!
    echo -e "tailing remus log file"
    sudo xentop -b -d 1 > $DIR/$vm/remus-$BENCH-$i-local-xentop &
    echo -e "xentop running on localhost"
    autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i-local.out
    sudo pkill xentop
    echo -e "xentop killed and $BENCH ran"
    sudo kill -KILL $last_pid
    sudo pkill -USR1 xl
    sudo rmmod ifb && sudo modprobe ifb
    sudo rmmod ifb && sudo modprobe ifb
    sudo xl remus -Fdb ubuntu localhost
    sleep 15
}

remus-local-nonet ()
{
    sudo rmmod ifb && sudo modprobe ifb
    sudo rmmod ifb && sudo modprobe ifb
    local vm=$1
    local i=$2
    echo "Running remus with netbuf disabled on localhost"
    cd $HOME
    sudo xl -vvvv remus -Fndb ubuntu localhost > $DIR/$vm/remus-$BENCH-$i-local-nonet 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i-local-nonet > $DIR/$vm/remus-$BENCH-$i-local-nonet.log &
    last_pid=$!
    echo -e "tailing remus log file"
    sudo xentop -b -d 1 > $DIR/$vm/remus-$BENCH-$i-local-nonet-xentop &
    echo -e "xentop running on localhost"
    autobench --single_host --host1 ubuntu-xen --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i-local-nonet.out
    sudo pkill xentop
    echo -e "xentop killed and $BENCH ran"
    sudo kill -KILL $last_pid
    sudo pkill -USR1 xl
    sleep 15
    sudo rmmod ifb && sudo modprobe ifb
    sudo rmmod ifb && sudo modprobe ifb
    #For some reason we have to run remus again to do the network
    #teardown. The below line should print only errors and setup
    #the vm for next round of remus.
    sudo xl remus -Fndb ubuntu localhost
}

plot-graph ()
{
    local vm=$1
    cd $DIR/$vm/
    rm *.pdf
    bench2graph $BENCH-0.out noremus.pdf
    for i in ${INTS[@]}; do
        bench2graph $BENCH-$i.out remus-remote-$i.pdf
        bench2graph $BENCH-$i-nonet.out remus-remote-nonet-$i.pdf
        bench2graph $BENCH-$i-local.out remus-local-$i.pdf
        bench2graph $BENCH-$i-local-nonet.out remus-local-nonet-$i.pdf
    done

    scp -r *.pdf sunny@161.253.74.130:~/Dropbox/autobench/
}

get-remus-results ()
{
    for vm in ${VMS[@]}; do
        cd $DIR/$vm/
        echo "Results for $vm"
        for i in ${INTS[@]}; do
            echo -e "Average Statistics using $i msec remus interval" > remus-$i.txt
            echo -e "*****************************" >> remus-$i.txt
            echo -e "Avg. Suspend and send dirty time: " >> remus-$i.txt
            grep "Domain was suspended" remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Avg. Dirty page sent time: " >> remus-$i.txt
            grep dirtied_pages remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Avg. writev_exact time: " >> remus-$i.txt
            #grep writev remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'BEGIN {max = 0} {if ($1>max) max=$1} END {print max}' >> remus-$i.txt
            grep "writev_exact" remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Avg. Dirty page count: " >> remus-$i.txt
            grep Dirty remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "*****************************" >> remus-$i.txt
        done
    done
    scp -r *.txt sunny@161.253.74.130:~/Dropbox/autobench/
}

main ()
{
    for VM in ${VMS[@]}; do

        #noremus $VM

        for interval in ${INTS[@]}; do

            # Remus with netbuf enabled
            #remus-remote $VM $interval

            # Remus with netbuf disabled
            #remus-remote-nonet $VM $interval

            # Remus with netbuf enabled on localhost
            remus-local $VM $interval

            # Remus with netbuf disabled on localhost
            #remus-local-nonet $VM $interval

        done
    done

get-remus-results

plot-graph $VM $interval

}

main "$@"


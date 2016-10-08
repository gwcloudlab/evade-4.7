#!/bin/zsh

BENCH=autobench
VMS=(opensuse64)
#VMS=(ubuntu64)
DT=$(date +"%y-%m-%d")
HOME='/home/sundarcs'
mkdir -p $HOME/evade-4.7/Hotcloud16/exp/$DT/$BENCH/$VMS
ssh sundarcs@10.0.0.42 "mkdir -p $BENCH"
DIR=$HOME/evade-4.7/Hotcloud16/exp/$DT/$BENCH/

#INTS=(5 10 30 50 70 100)
#INTS=(10 30 100)
INTS=(10 20 30)
LOW_RATE=100
HIGH_RATE=1000
RATE_STEP=100
NUM_CALL=10
TOT_CONN=100000
#time taken = TOT_CONN / (RATE * NUM_CALL) seconds

noremus ()
{
    local vm=$1
    # Initially run $BENCH with remus disabled
    echo "Running no remus"
    autobench --single_host --host1 $vm --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-0.out
}

remus-remote ()
{
    local vm=$1
    local i=$2
    echo "Running remus with netbuf enabled"
    cd $HOME
    sudo xl -vvvv remus -Fd -i $i $vm 10.0.0.42 > $DIR/$vm/remus-$BENCH-$i 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i > $DIR/$vm/remus-$BENCH-$i.log &
    last_pid=$!
    echo -e "tailing remus log file"
    ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-$i-xentop &"
    echo -e "xentop running on nn42"
    autobench --single_host --host1 $vm --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i.out
    ssh sundarcs@10.0.0.42 "sudo pkill xentop"
    echo -e "xentop killed and $BENCH ran"
    sudo kill -KILL $last_pid
    ssh 10.0.0.42 "echo HiVJbkb3 | sudo -S xl destroy $vm--incoming"
    sleep 15
}

remus-remote-nonet ()
{
    local vm=$1
    local i=$2
    echo "Running remus with netbuf disabled"
    cd $HOME
    sudo xl -vvvv remus -Fnd $vm 10.0.0.42 > $DIR/$vm/remus-$BENCH-$i-nonet 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i-nonet > $DIR/$vm/remus-$BENCH-$i-nonet.log &
    last_pid=$!
    echo -e "tailing remus log file"
    ssh sundarcs@10.0.0.42 "sudo xentop -b -d 1 > $BENCH/remus-$BENCH-$i-nonet-xentop &"
    echo -e "xentop running on nn42"
    autobench --single_host --host1 $vm --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i-nonet.out
    ssh sundarcs@10.0.0.42 "sudo pkill xentop"
    echo -e "xentop killed and $BENCH ran"
    sudo kill -KILL $last_pid
    ssh 10.0.0.42 "echo HiVJbkb3 | sudo -S xl destroy $vm--incoming"
    sleep 15
}

remus-local ()
{
    local vm=$1
    local i=$2
    echo "Running remus with netbuf enabled on localhost"
    cd $HOME
    sudo xl -vvvv remus -Fd -i $i $vm localhost > $DIR/$vm/remus-$BENCH-$i-local 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i-local > $DIR/$vm/remus-$BENCH-$i-local.log &
    last_pid=$!
    echo -e "tailing remus log file"
    sudo xentop -b -d 1 > $DIR/$vm/remus-$BENCH-$i-local-xentop &
    echo -e "xentop running on localhost"
    autobench --single_host --host1 $vm --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i-local.out
    sudo pkill xentop
    echo -e "xentop killed and $BENCH ran"
    sudo kill -KILL $last_pid
    sudo xl destroy $vm--incoming
    #sudo pkill -USR1 xl
    sudo rmmod ifb && sudo modprobe ifb
    sudo rmmod ifb && sudo modprobe ifb
    sleep 15
}

remus-local-nonet ()
{
    local vm=$1
    local i=$2
    echo "Running remus with netbuf disabled on localhost"
    cd $HOME
    sudo xl -vvvv remus -Fd ubuntu localhost > $DIR/$vm/remus-$BENCH-$i-local-nonet 2>&1 &
    echo -e "started remus, now sleep"
    sleep 15
    tail -f $DIR/$vm/remus-$BENCH-$i-local-nonet > $DIR/$vm/remus-$BENCH-$i-local-nonet.log &
    last_pid=$!
    echo -e "tailing remus log file"
    sudo xentop -b -d 1 > $DIR/$vm/remus-$BENCH-$i-local-nonet-xentop &
    echo -e "xentop running on localhost"
    autobench --single_host --host1 $vm --uri1 /10K --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$vm/$BENCH-$i-local-nonet.out
    sudo pkill xentop
    echo -e "xentop killed and $BENCH ran"
    sudo kill -KILL $last_pid
    sudo xl destroy $vm--incoming
    sleep 15
}

plot-graph ()
{
    local vm=$1
    cd $DIR/$vm/
    rm *.pdf
    bench2graph $BENCH-0.out noremus.pdf 2 5 8
    for i in ${INTS[@]}; do
        bench2graph $BENCH-$i.out remus-remote-$i.pdf 2 5 8
        bench2graph $BENCH-$i-nonet.out remus-remote-nonet-$i.pdf 2 5 8
        bench2graph $BENCH-$i-local.out remus-local-$i.pdf 2 5 8
        bench2graph $BENCH-$i-local-nonet.out remus-local-nonet-$i.pdf 2 5 8
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
            echo -e "Total time VM was suspended: " >> remus-$i.txt
            grep "Domain was suspended" remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Suspend_domain function call time: " >> remus-$i.txt
            grep "suspend_domain" remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Resume function call time: " >> remus-$i.txt
            grep "postcopy" remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Dirty page sent time: " >> remus-$i.txt
            grep dirtied_pages remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Writev_exact time: " >> remus-$i.txt
            #grep writev remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'BEGIN {max = 0} {if ($1>max) max=$1} END {print max}' >> remus-$i.txt
            grep "writev_exact" remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "Avg. Dirty page count: " >> remus-$i.txt
            grep Dirty remus-$BENCH-$i-local.log | awk '{print $8}' | awk 'NR>2 {sum=sum+$1} END {print sum/NR}' >> remus-$i.txt
            echo -e "*****************************" >> remus-$i.txt
        done
    done
    scp -r *.txt sunny@161.253.74.130:~/Dropbox/autobench/
    scp -r *.out sunny@161.253.74.130:~/Dropbox/autobench/
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

#!/usr/bin/env bash

usage ()
{
    cat <<-END >&2
USAGE: remusperf [-d <netbuf|nonet>] [-s <localhost|remote>] [-n VM hostname] [-b bench] [-i interval(s)] [-t seconds]
                 -d netbuf       # Enable netbuf on remus
                 -s host         # Run remus on localhost or remote
                 -n name         # VM to run the tests on
                 -b bench        # Benchmark to run
                 -i interval     # Remus interval to run
                 -t seconds      # benchmark time to run (only if benchmark supports it)
                 -h help         # Display usage message
  eg,
       ./remusperf.sh -d netbuf -s localhost -n suse-web -b wrk -i 20 -t 20
END
    exit
}

die ()
{
    echo >&2 "$@"
    exit 1
}

edie ()
{
    # die with a quiet end()
    echo >&2 "$@"
    exec >/dev/null 2>&1
    end
    exit 1
}

run-autobench ()
{
    local interval=$1

    LOW_RATE=100
    HIGH_RATE=100
    RATE_STEP=100
    NUM_CALL=100
    TOT_CONN=1000
    #time taken = TOT_CONN / (RATE * NUM_CALL) seconds
    #URI1='/php/overdue.php\?num_times\=100'
    URI1='/'

    echo -e "Running autobench"
    autobench --single_host --host1 $VM --uri1 $URI1 --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $DIR/$BENCH-$interval-$host-$net.out
}

run-wrk ()
{
    echo -e "Running wrk"
    wrk -c 24 -t 24 -d $DURATION http://$VM > $DIR/$BENCH-$interval-$host-$net.out
}

run-remus ()
{
    local interval=$1
    echo $interval $VM $host $net
    if [ "$net" == "netbuf" ]
    then
        sudo xl -vvvv remus -Fd -i $interval $VM $host > $DIR/$BENCH-$interval-$host-$net.log 2>&1 &
    else
        sudo xl -vvvv remus -Fnd -i $interval $VM $host > $DIR/$BENCH-$interval-$host-$net.log 2>&1 &
    fi
    # Let remus finish live migration before starting the benchmark
    sleep 15
    echo -e "started remus"
    #sudo xentop -b -d 1 > $DIR/remus-$BENCH-$interval-$host-$net.xentop &
    run-$BENCH $interval
    #sudo pkill xentop
    echo -e "xentop killed and $BENCH ran"
    sudo xl destroy machine--incoming
    #sudo pkill -USR1 xl
    sudo rmmod ifb && sudo modprobe ifb
    sleep 5
}

plot-graph ()
{
    #bench2graph $BENCH-0.out noremus.pdf 2 5 8
    for interval in ${INTS[@]}; do
        bench2graph $DIR/$BENCH-$interval-$host.out $DIR/$host-$net-$interval.pdf 2 5 8
    done
}

get-remus-results ()
{
    for interval in ${INTS[@]}; do
        python print_statistics.py $DIR/$BENCH-$interval-$host-$net.log >> $DIR/remus-$interval.txt
    done
}

scp-all-results ()
{
    scp $DIR/{*.txt,*.out,*.pdf} sunnyraj@laptop:~/Dropbox/autobench/nn42/
}

while getopts ":d:s:n:b:i:t:" opt
do
    case $opt in
        n)  VM=$OPTARG ;;
        b)  BENCH=$OPTARG ;;
        i)  INTS+=($OPTARG) ;;
        t)  DURATION=$OPTARG ;;
        d)  net=$OPTARG
            (($net == "netbuf" || $net == "nonet")) || usage ;;
        s)  host=$OPTARG
            (($host == "localhost" || $host == "remote")) || usage ;;
        *)    usage ;;
    esac
done
shift $(( $OPTIND - 1 ))
(( $# )) && usage

DT=$(date +"%y-%m-%d")
HOME='/home/sundarcs'
mkdir -p $HOME/evade-4.7/Hotcloud16/exp/$DT/$VM
#ssh sundarcs@10.0.0.42 "mkdir -p $BENCH"
DIR=$HOME/evade-4.7/Hotcloud16/exp/$DT/$VM


for interval in "${INTS[@]}"; do
    run-remus $interval
done

if [ $BENCH == "autobench" ]
then
    plot-graph
fi

get-remus-results

scp-all-results

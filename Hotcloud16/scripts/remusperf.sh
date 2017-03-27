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

    LOW_RATE=10
    HIGH_RATE=150
    RATE_STEP=20
    NUM_CALL=100
    TOT_CONN=1000
    #time taken = TOT_CONN / (RATE * NUM_CALL) seconds
    #URI1='/php/overdue.php\?num_times\=100'
    #URI1='/php/overdue.php'
    URI1='/'

    echo -e "Running autobench"
    autobench --single_host --host1 $VM --uri1 $URI1 --quiet --low_rate $LOW_RATE --high_rate $HIGH_RATE --rate_step $RATE_STEP --num_call $NUM_CALL --num_conn $TOT_CONN --timeout 5 --file $run.out
}

run-wrk ()
{
    echo -e "Running wrk"
    for i in `seq 1 20`;
    do
        con=$(( $i*500 ))
        wrk -c $con -t 24 -d $DURATION http://$VM > $run$con.out
    done
}

run-remus ()
{
    local interval=$1
    echo $interval $VM $host $net
    if [ "$net" == "netbuf" ]
    then
        sudo xl -vvvv remus -Fd -i $interval $VM $host > $run.log 2>&1 &
    else
        sudo xl -vvvv remus -Fnd -i $interval $VM $host > $run.log 2>&1 &
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
    bench2graph $run.out $run.pdf 2 5 8
}

get-remus-results ()
{
    python print_statistics.py $run.log >> $run.txt
}

scp-all-results ()
{
    scp $DIR/$BENCH-{*.txt,*.out,*.pdf} sunnyraj@laptop:~/Dropbox/autobench/nn42/
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

    run=$DIR/$BENCH-$interval-$host-$net

    run-remus $interval

    get-remus-results

    if [ $BENCH == "autobench" ]
    then
        rm -f $run.pdf
        plot-graph
    fi

done

scp-all-results

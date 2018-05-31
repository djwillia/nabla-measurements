#!/bin/bash

RUNTIME=$1
CONTAINER=$2
DIR=$3
IP=172.17.0.2

# make output directory
mkdir -p $DIR

# set up kernel ftrace parameters
echo "function_graph" > /sys/kernel/debug/tracing/current_tracer
echo "function-fork" > /sys/kernel/debug/tracing/trace_options
echo "noirq-info" > /sys/kernel/debug/tracing/trace_options
echo "context-info" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-irqs" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-overhead" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-duration" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-tail" > /sys/kernel/debug/tracing/trace_options
echo "funcgraph-proc" > /sys/kernel/debug/tracing/trace_options
echo "0" > /sys/kernel/debug/tracing/tracing_on
echo "" > /sys/kernel/debug/tracing/trace
echo "## set up kernel ftrace parameters"

# run service
case $RUNTIME in
    "runc")
        docker run -d --rm --name=tracetest $CONTAINER 
        ;;
    "runsc")
        docker run -d --rm --runtime=runsc --name=tracetest $CONTAINER
        ;;
esac
echo "## running $CONTAINER on $RUNTIME"

sleep 5

# set pids to trace
PSROOT=`pstree -a -p --long \
     | grep "\-runtime\-root /var/run/docker/runtime\-$RUNTIME$" \
     | cut -f 2 -d ',' \
     | cut -f 1 -d ' '`
pstree -a -p $PSROOT \
    | cut -f 2 -d ',' \
    | cut -f 1 -d ' ' \
    |sed s/\)//g \
    |tee $DIR/pids > /sys/kernel/debug/tracing/set_ftrace_pid
echo "## tracing pids under $PSROOT"

# start the trace
echo "1" > /sys/kernel/debug/tracing/tracing_on
echo "## started tracing"

# offer load
case $CONTAINER in
    "python_tornado")
        for ((i=0;i<30;i++)); do
            sleep .1
            curl $IP:5000
        done
        ;;
    "redis_test")
        for ((i=0;i<30;i++)); do
            sleep .1
            redis-cli -h $IP -p 6379 set foo$i bar$i
        done
        ;;
    "node_auth")
        for ((i=0;i<30;i++)); do
            sleep .1
            curl $IP:9083/auth
        done
        ;;
esac
echo "## finished offering load"

# stop tracing and copy trace to directory
echo "0" > /sys/kernel/debug/tracing/tracing_on
cat /sys/kernel/debug/tracing/trace > $DIR/trace
echo "## copied trace to directory"

# kill the container
docker kill tracetest
echo "## killed container"

# process the data
for p in `cat $DIR/pids`; do
    cat $DIR/trace \
        | grep $p \
        | grep -v "=>" \
        | tee $DIR/$p.raw \
        | cut -f 2 -d '|' \
        | filters/filter \
        | tee $DIR/$p.filt \
        | filters/filter-errors \
        | tee $DIR/$p.filt2 \
        | sort | uniq \
        | grep -v "}" \
        | cut -f 1 -d '(' \
        | awk '{print $1}' \
        | uniq \
        | tee $DIR/$p.list
done | sort |uniq > $DIR/trace.list
echo "## processed data"
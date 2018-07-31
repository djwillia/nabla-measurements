#!/bin/bash

APPS="node-express redis-test python-tornado"
SYSTEMS="kata runc runsc runnc runsck"

for SUFFIX in list listi listu listz; do 

    echo -n "# test " > results/summary-complexity.$SUFFIX.dat
    echo -n "[sum: N min max sum mean stddev]" >> results/summary-complexity.$SUFFIX.dat
    echo -n "[max: N min max sum mean stddev]" >> results/summary-complexity.$SUFFIX.dat
    echo -n "[mean: N min max sum mean stddev]" >> results/summary-complexity.$SUFFIX.dat
    echo    "[unknown: N min max sum mean stddev]" >> results/summary-complexity.$SUFFIX.dat
    for a in $APPS; do
        for s in $SYSTEMS; do
            echo -n "$s-$a ";
            # sum
            for h in results/$s-$a*/complexity.$SUFFIX; do
                cat $h | grep -v "^#" | cut -f 4 -d ' '
            done | st --no-header -d ' ' | tr '\n' ' ';
            # max
            for h in results/$s-$a*/complexity.$SUFFIX; do
                cat $h | grep -v "^#" | cut -f 3 -d ' '
            done | st --no-header -d ' ' | tr '\n' ' ';
            #  mean
            for h in results/$s-$a*/complexity.$SUFFIX; do
                cat $h | grep -v "^#" | cut -f 5 -d ' '
            done | st --no-header -d ' ' | tr '\n' ' ';
            # unknown sum
            for h in results/$s-$a*/complexity.$SUFFIX; do
                cat $h | grep -v "^#" | cut -f 7 -d ' '
            done | st --no-header -d ' ';
        done;
    done | sort >> results/summary-complexity.$SUFFIX.dat
    for g in $SYSTEMS; do
        cat results/summary-complexity.$SUFFIX.dat | grep $g- > results/summary-complexity-$SUFFIX-$g.dat
    done
done
    

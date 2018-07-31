#!/bin/bash


for d in `find results/ -type d |tail -n +2`; do
    for f in $d/trace.listi $d/trace.listu $d/trace.listz $d/trace.list; do
        echo "# n min max sum mean stddev unknown" > ${f/trace/complexity}
        echo 0 > /tmp/u
        for g in `cat $f`; do
            C=`grep $g complexity`
            if [ "x$C" == "x" ]; then
                #echo "couldn't find complexity for $g"
                U=`cat /tmp/u`
                echo $((U+1)) > /tmp/u
            else
                echo $C | cut -f 1 -d ' '
            fi
        done | st --no-header -d ' ' | tr -d '\n' >> ${f/trace/complexity}
        echo " `cat /tmp/u`" >> ${f/trace/complexity}
        #echo "just wrote ${f/trace/complexity} (`cat /tmp/u`)"
    done
done

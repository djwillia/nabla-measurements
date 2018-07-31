# Copyright (c) 2018 Contributors as noted in the AUTHORS file
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose with or without fee is hereby granted, provided
# that the above copyright notice and this permission notice appear
# in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
# OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

reset
set terminal png
set output 'graph-functions.png'
set multiplot layout 1,2

set key top center outside

set bmargin 5

set style line 81 lt 0  # dashed
set style line 81 lt rgb '#808080'  # grey
#set grid back linestyle 81
set grid ytics back linestyle 81

set style line 1 lt 2
set style line 1 lt rgb '#A00000' ps 1 pt 5 lw 1
set style line 2 lt 1 pt 6 lc rgb '#008000'
set style line 3 lt 1 pt 4 lc rgb '#0000A0'
set style line 4 lt 1 pt 0 lc rgb '#000000'

set style fill solid 1 border lc rgb '#000000'

set boxwidth .4
set yrange [0:*]
set xrange [-.5:*]
set xtics ("node-express" 0, "redis-test" 1, "python-tornado" 2, "node-express" 4, "redis-test" 5, "python-tornado" 6) rotate by -30


set ylabel "Unique syscalls accessed"
plot \
'results/summary-syscalls-runc.dat' using ($0-.2):6 with boxes title "docker" lc rgb "#d73027" axes x1y1, \
'results/summary-syscalls-runc.dat' using ($0-.2):6:($6-$7):($6+$7) with errorbars ls 4 notitle axes x1y1, \
'results/summary-syscalls-runnc.dat' using ($0+.2):6 with boxes title "nabla" lc rgb "#91bfdb" axes x1y1, \
'results/summary-syscalls-runnc.dat' using ($0+.2):6:($6-$7):($6+$7) with errorbars ls 4 notitle axes x1y1,

set ylabel "Unique kernel functions accessed"
set xrange [3.5:*]

plot \
'results/summary-ftrace-runc.dat' using ($0+4-.2):6 with boxes notitle lc rgb "#d73027" axes x1y1, \
'results/summary-ftrace-runc.dat' using ($0+4-.2):6:($6-$7):($6+$7) with errorbars ls 4 notitle axes x1y1, \
'results/summary-ftrace-runnc.dat' using ($0+4+.2):6 with boxes notitle lc rgb "#91bfdb" axes x1y1, \
'results/summary-ftrace-runnc.dat' using ($0+4+.2):6:($6-$7):($6+$7) with errorbars ls 4 notitle axes x1y1


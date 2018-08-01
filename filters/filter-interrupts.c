/* 
 * Copyright (c) 2018 Contributors as noted in the AUTHORS file
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear
 * in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
 * OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <stdio.h>
#include <string.h>

#define BUFLEN 4096
char buf[BUFLEN];

int check_for_interrupts(char *line) {
    return (strstr(line, "smp_irq_work_interrupt")
            || strstr(line, "smp_apic_timer_interrupt")
            || strstr(line, "smp_reschedule_interrupt")
            || strstr(line, "smp_call_function_single_interrupt")
            || strstr(line, "do_softirq")
            );
}

int main(int argc, char **argv) {
    int filtering = 0;
    int filtering_indent = 0;
    char *line;

    while ((line = fgets(buf, BUFLEN, stdin)) != NULL) {

        /* checking for brackets (e.g., { ... } ) is a bit fragile
         * because ftrace can mislabel one.  However, ftrace's
         * indentation is more reliable. */
        int indent = -1;
        while(line[++indent] == ' ')
            ;

        if (!filtering) {
            if (check_for_interrupts(line)) {
                filtering = 1;
                filtering_indent = indent;
                continue;
            }
        }

        if (filtering) {
            if (indent == filtering_indent)
                filtering = 0;
            if (indent >= filtering_indent)
                continue;
        }

        printf("%s", line);
    }
    
    return 0;
}

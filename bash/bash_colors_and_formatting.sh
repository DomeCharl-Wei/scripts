#!/bin/bash

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar.

#background
for clbg in {40..47} {100..107} 49; do
    #foreground
    for clfg in {30..37} {90..97} 39; do
        #formatting
        for attr in 0 1 2 4 5 7; do
            #print the result
            echo -en "\e[${attr};${clbg};${clfg}m ^{${attr};${clbg};${clfg}m \e[0m"
        done
        echo #newline
    done
done

exit 0

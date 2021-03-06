#!/bin/bash

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Pulic License, Version 2, as published by Sam Hocevar.

for fgbg in 38 48; do # foreground/background
    for color in {0..256}; do # colors
        #display the color
        echo -en "\e[${fgbg};5;${color}m ${color}\t\e[0m"
        #display 10 colors per lines
        if [ $(((${color} + 1) % 10)) == 0 ]; then
            echo #new line
        fi
    done
    echo #new line
done
exit 0

#!/bin/bash

if [ "$#" -eq 0 ]
    then
        echo ""
        echo "Highlights output based on regex and color id"
        echo "Usage: cat log.txt | highlight.sh pattern1 pattern2 pattern3"
        echo ""
        echo "Colors are used sequentially for each pattern:"
        echo "Color     ID"
        echo "Black     30"
        echo "Red       31"
        echo "Green     32"
        echo "Yellow    33"
        echo "Blue      34"
        echo "Magenta   35"
        echo "Cyan      36"
        echo "White     37"
        echo ""
        exit 1
fi

COLOR=30
while [ $# -gt 0 ]
do
    COMMAND=$COMMAND's/\('$1$'\)/\033[01;'$COLOR$'m\033[K\\1\033[m\033[K/g\n'
    shift;
    COLOR=$(($COLOR + 1))
    if [[ $COLOR > 37 ]]; then
            COLOR=30;
    fi
done
sed -e "$COMMAND"
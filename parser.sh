#!/bin/bash

PIPED_INPUT=""

while IFS= read line; do
    # echo "Line: ${line}"
    PIPED_INPUT+=$line$'\n'
done

# echo "$PIPED_INPUT"

KEY_LINES=$( echo "$PIPED_INPUT" | grep -E 'Interface|PortID|SysName|------')
# trim whitespaces
KEY_LINES=$( echo "$KEY_LINES" | sed -e 's/^[ \t]*//')
# echo "$KEY_LINES"

# echo "$KEY_LINES" | grep -E '(--)+' 
echo "$KEY_LINES" | uniq

# an a
FLEX_LINES=()


NODE_DATA=""
IFS=$'\n'
for var in $KEY_LINES
do
#   FLEX_LINES+=$var
    if [ "$var" = "-------------------------------------------------------------------------------" ]; then
        FLEX_LINES+=($NODE_DATA)
        # NODE_DATA=()
    else
        echo "Is this a node we want to have $var"
        # $var = (sed -e '^')
        # NODE_DATA+=("$var||")
        NODE_DATA+="$var||"
        echo "${#NODE_DATA[@]}"
    fi
done

echo "*********"

for node in ${FLEX_LINES[@]}; do
    echo "$node"
done

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

#!/bin/bash

# The fields to look for in our output
FIELDS=("Interface" "PortID" "SysName" "TTL")

PIPED_INPUT=""

# read all the lines of piped input
while IFS= read line; do
    PIPED_INPUT+=$line$'\n'
done


FIELDS_REGEX=""
for FIELD_NAME in ${FIELDS[@]}; do
    FIELDS_REGEX+="$FIELD_NAME|"
done

KEY_LINES=$( echo "$PIPED_INPUT" | grep -E "$FIELDS_REGEX------")
# trim whitespaces
KEY_LINES=$( echo "$KEY_LINES" | sed -e 's/^[ \t]*//')

# an a
FLEX_LINES=()

IFS=$'\n'
for LINE in $KEY_LINES
do
#   FLEX_LINES+=$var
    if [ "$LINE" == "-------------------------------------------------------------------------------" ]; then
        LINE_VALUES=""
        for FIELD_NAME in ${FIELDS[@]}; do
            LINE_VALUES+=${!FIELD_NAME}"||"
        done
        FLEX_LINES+=($LINE_VALUES)
        # NODE_DATA=()
        # reset all variables
        for FIELD_NAME in ${FIELDS[@]}; do
            eval "$FIELD_NAME=\"\""
        done
    else
        for FIELD_NAME in ${FIELDS[@]}; do
            VALID_FIELD=$(echo "$LINE" | grep -E "^\s*$FIELD_NAME:")
            if [ ! -z "$VALID_FIELD" -a "$VALID_FIELD" ]; then
                LINE_VALUE=$(echo "$LINE" | sed -E "s/^[ ]*$FIELD_NAME:[ ]+(.*)/\1/")
                eval "$FIELD_NAME=\"$LINE_VALUE\""
             fi
        done
    fi
done

######
# OUTPUT THE FORMATTED DATA
#####

# Print out the header fields
HEADERS=$(printf "||%s" "${FIELDS[@]}")
echo ${HEADERS:2}

# Print out the body for flex parsing
for node in ${FLEX_LINES[@]}; do
    # output the values trimming the last divider characters
    if echo "$node" | grep -qE "^[|]"; then
        # do nothing
        N=1
    else
        echo "${node%??}"
    fi
done

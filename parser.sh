#!/bin/bash

# The fields to look for in our output
FIELDS=("Interface" "PortID" "SysName" "TTL")
# the dividing line between entities/nodes
ENTITY_DIVIDER="-------------------------------------------------------------------------------"
# field divider string
FIELD_DIVIDER="||"

PIPED_INPUT=""


# read all the lines of piped input
while IFS= read line; do
    PIPED_INPUT+=$line$'\n'
done

# add a guaranteed final entity divider so the last node can be captured
PIPED_INPUT+=$ENTITY_DIVIDER$'\n'


FIELDS_REGEX=""
for FIELD_NAME in ${FIELDS[@]}; do
    FIELDS_REGEX+="$FIELD_NAME|"
done

# only process lines we care about, drop the rest
KEY_LINES=$( echo "$PIPED_INPUT" | grep -E "$FIELDS_REGEX------")
# trim whitespaces
KEY_LINES=$( echo "$KEY_LINES" | sed -e 's/^[ \t]*//')

# a variable to store our flex-friendly entries
FLEX_LINES=()

IFS=$'\n'
for LINE in $KEY_LINES
do
    if [ "$LINE" == "$ENTITY_DIVIDER" ]; then
        # variable to store our concatinated string values
        LINE_VALUES=""
        for FIELD_NAME in ${FIELDS[@]}; do
            LINE_VALUES+=${!FIELD_NAME}"$FIELD_DIVIDER"
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
HEADERS=$(printf "$FIELD_DIVIDER%s" "${FIELDS[@]}")
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

#!/usr/bin/awk -f
{
    key=$1
    if (key=="Interface:") 
        for (i=2; i<NF; i++)
            print $i
}
## AWK

cat lldpctl.txt | ./awk.awk


## GREP

grep -E 'Interface|PortID|SysName|------' lldpctl-show-neighbors.txt

## Shell Script
KEY_LINES=$(grep -E 'Interface|PortID|SysName|------' lldpctl-show-neighbors.txt)
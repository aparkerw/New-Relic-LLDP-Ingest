
## Usage

The `parse.sh` script is there to accept piped input and to parse out the needed information for FLEX to use.

Don't forget to add execution priveldges to the `parse.sh` file with `chmod +x parse.sh`

## AWK

cat lldpctl.txt | ./awk.awk


## GREP

grep -E 'Interface|PortID|SysName|------' lldpctl-show-neighbors.txt

## Shell Script
cat lldpctl-show-neighbors.txt | ./parser.sh
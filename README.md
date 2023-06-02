
## Usage

The `parse.sh` script is there to accept piped input and to parse out the needed information for FLEX to use.

Don't forget to add execution priveldges to the `parse.sh` file with `chmod +x parse.sh`

## AWK

cat lldpctl.txt | ./awk.awk


## GREP

grep -E 'Interface|PortID|SysName|------' lldpctl-show-neighbors.txt

## Shell Script
cat lldpctl-show-neighbors.txt | ./parser.sh


# FLEX INTEGRATION

Once the infrastructure agent is active you can copy the `integration.yaml` file to `/etc/newrelic-infra/integrations.d/`.

To add logging you can update `/etc/newrelic-infra.yml` and add:

```
log:
  level: debug
  file: /nr-logfile.log
```

### restarting the service

To pick up the logs you will need to restart the service `sudo systemctl restart newrelic-infra`
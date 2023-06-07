# LLDP Integration with New Relic

The purpose of this repository is to provide an aproach to incorporating LLDP data alongside your other telemetry data using the `nri-flex` script.

The processing of data is done by piping the output of `lldp-ctl` into the `parser.sh` that will format the output so it can be ingested into new relic via `flex`.

```
lldpctl -> parser.sh -> FLEX -> NRDB
```

## Quick Setup

```
echo "Downloading the parser"
curl https://raw.githubusercontent.com/aparkerw/New-Relic-LLDP-Ingest/main/parser.sh > parser.sh 
chmod +x parser.sh

echo "Downloading the New Relic Infra Agent"

```


## Usage

The host with LLDP data will need two components to be installed: 
- the LLDP parser located in this file 
- the `nri-flex` binaries

### THe LLDP Parser

The `parse.sh` script is there to accept piped input and to parse out the needed information for FLEX to use.

Don't forget to add execution priveldges to the `parse.sh` file with `chmod +x parse.sh`

#### Obtaining the Parser

```
curl https://raw.githubusercontent.com/aparkerw/New-Relic-LLDP-Ingest/main/parser.sh > parser.sh 
```

#### Grant Exectution Permissions

```
chmod +x parser.sh
```

### The NRI-Flex Binaries

The flex binaries are installed along with the infrastructure agent.  You can find out more here [https://github.com/newrelic/nri-flex](https://github.com/newrelic/nri-flex).

For instructions on installing nri-flex in a kubernetes environment please read here: [https://github.com/newrelic/nri-flex/blob/master/docs/basics/k8s_configure.md](https://github.com/newrelic/nri-flex/blob/master/docs/basics/k8s_configure.md)


## Shell Script
cat lldpctl-show-neighbors.txt | ./parser.sh


# FLEX INTEGRATION

Once the infrastructure agent is active you can copy the `integration.yaml` file to `/etc/newrelic-infra/integrations.d/`.

### Debugging Flex within the Infrastructure Agent

To add logging you can update `/etc/newrelic-infra.yml` and add:

```
log:
  level: debug
  file: /nr-logfile.log
```

### restarting the service

To pick up the logs you will need to restart the service 
```
sudo systemctl restart newrelic-infra
```
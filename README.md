# LLDP Integration with New Relic

The purpose of this repository is to provide an aproach to incorporating LLDP data alongside your other telemetry data using the `nri-flex` script.

The processing of data is done by piping the output of `lldp-ctl` into the `parser.sh` that will format the output so it can be ingested into new relic via `flex`.

```
lldpctl -> parser.sh -> FLEX -> NRDB
```

## Quick Setup

```
echo "Downloading the parser:"
curl -o /etc/newrelic-infra/lldp/parser.sh --create-dirs https://raw.githubusercontent.com/aparkerw/New-Relic-LLDP-Ingest/main/parser.sh
chmod +x /etc/newrelic-infra/lldp/parser.sh

echo "Downloading the Flex configuration file:"
curl -o /etc/newrelic-infra/lldp/parser.sh --create-dirs https://raw.githubusercontent.com/aparkerw/New-Relic-LLDP-Ingest/main/parser.sh

```


## Usage

The host with LLDP data will need two components to be installed: 
- the LLDP parser located in this file 
- the `nri-flex` binaries

### The LLDP Parser

The `parse.sh` script is there to accept piped input and to parse out the needed information for FLEX to use. You can obtain the parser on github here:

```
curl -o /etc/newrelic-infra/lldp/parser.sh --create-dirs https://raw.githubusercontent.com/aparkerw/New-Relic-LLDP-Ingest/main/parser.sh
```

Don't forget to add execution priveldges to the `parse.sh` file with:

```
chmod +x /etc/newrelic-infra/lldp/parser.sh
```


### The NRI-Flex Binaries

The flex binaries are installed along with the infrastructure agent.  You can find out more here [https://github.com/newrelic/nri-flex](https://github.com/newrelic/nri-flex).

For instructions on installing nri-flex in a kubernetes environment please read here: [https://github.com/newrelic/nri-flex/blob/master/docs/basics/k8s_configure.md](https://github.com/newrelic/nri-flex/blob/master/docs/basics/k8s_configure.md)

If the infrastructure agent is running flex will run every 30 seconds.

To run Flex manually you can execute the following:

```
sudo /var/db/newrelic-infra/newrelic-integrations/bin/nri-flex -config_path /etc/newrelic-infra/integrations.d/integration.yaml -verbose -insights_url https://insights-collector.newrelic.com/v1/accounts/<YOUR_NR_ACCOUNT_ID>/events -insights_api_key <YOUR_NR_API_KEY>
```

It will be ideal to run this as a CRON job.


## Testing The Parser

You can test the parser in several ways.  First you can parse the included sample output:

```
cat LLDPCtl-Output/lldpctl-show-neighbors.txt | ./parser.sh
```

Second you can manually run `lldp-ctl` and send that to the parser:

```
lldpcli show neighbors | ./parser.sh
```


# FLEX INTEGRATION

Once the infrastructure agent is active you can copy the `integration.yaml` file to `/etc/newrelic-infra/integrations.d/`.

The `integration.yaml` file tells Flex what script to run and how to process the output for sending to New Relic

```
curl -o /etc/newrelic-infra/integrations.d/integration.yaml --create-dirs https://raw.githubusercontent.com/aparkerw/New-Relic-LLDP-Ingest/main/integration.yaml
```

# Configuration

By default the configuration included here will take the standard lldp-ctl output and will extract the following fields: `Interface, PortID, SysName, TTL`

If you want to expand this, for example to include the `MgmtIp` you would need to make 3 changes.

In the parser you need to look for this new field:

```
#!/bin/bash

# The fields to look for in our output
FIELDS=("Interface" "PortID" "SysName" "TTL", "MgmtIP")
# the dividing line between entities/nodes
```

And in the Integration.yaml file you'll need to expand the regex and add the column header (in the same position as your previous parser update)

```
            - run: 'lldpcli show neighbors | /etc/newrelic-infra/lldp/parser.sh'
              split: horizontal
              regex_match: true
              split_by: ^([^|]*)[|]{2,}([^|]*)[|]{2,}([^|]*)[|]{2,}([^|]*)[|]{2,}([^|]*)
              row_start: 1
              set_header: [Interface, PortId, SysName, TTL, MgmtIP]

```

Then your next ingest will capture the data:

![Enhanced data in New Relic](images/NRQL-Output-Modified-Ingest.png?raw=true)


# Querying your LLDP Data

Once you've successfully installed the parser, configured flex, and executed flex either manually or automatically, then your data should be in NRDB for you to query.

Here is a sample NRQL query for once you've inserted data:

```
FROM LLDPSample SELECT * SINCE 1 hour ago
```

And you will see your data:

![LLDP Data in New Relic](images/NRQL-Output.png?raw=true)


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

## Current Limitations

- if your output has any `|` characters it will break the regex in the `integration.yaml` file
- if your file has multiple fields for a node, for example an IPv4 and IPv6 address in the MgmtIP rows, then the script will only grab the last one it sees
#!/bin/bash
if [ "$(ls -A $INSPECTIT_CONFIG_HOME)" ]; then
	echo "Using existing inspectIT configuration..."
else
	if ([ -z $INSPECTIT_CMR_ADDR ] || [ -z $INSPECTIT_CMR_PORT ]) && ([ -z $CMR_PORT_9070_TCP_ADDR ] || [ -z $CMR_PORT_9070_TCP_PORT ]); then
                echo "No inspectIT CMR configured! Please read our README"
                exit 1
        fi

	echo "No custom inspectIT configuration found, using default one..."
	cp -r $INSPECTIT_CONFIG_HOME/../config/* $INSPECTIT_CONFIG_HOME
	CMR_ADDR=${INSPECTIT_CMR_ADDR:-cmr}
	CMR_PORT=${INSPECTIT_CMR_PORT:-9070}

	AGENT_NAME=${AGENT_NAME:-$HOSTNAME}
	sed -i "s/^\(repository\) .*/\1 $CMR_ADDR $CMR_PORT $AGENT_NAME/" $INSPECTIT_CONFIG_HOME/inspectit-agent.cfg
	echo "Done. Remember to modify the configuration for your needs. You find the configuration in the mapped volume $INSPECTIT_CONFIG_HOME." 
fi

exec jetty.sh run

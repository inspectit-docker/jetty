#!/bin/bash

CMR_ADDR=${INSPECTIT_CMR_ADDR:-cmr}
CMR_PORT=${INSPECTIT_CMR_PORT:-9070}

if [ "$(ls -A $INSPECTIT_CONFIG_HOME)" ]; then
	echo "[INFO] Using existing inspectIT configuration..."
else
	if ([ -z $INSPECTIT_CMR_ADDR ] || [ -z $INSPECTIT_CMR_PORT ]) && ([ -z $CMR_PORT_9070_TCP_ADDR ] || [ -z $CMR_PORT_9070_TCP_PORT ]); then
                echo "[ERROR] No inspectIT CMR configured! Please read our README"
                exit 1
        fi

	echo "[INFO] No custom inspectIT configuration found, using default one..."
	cp -r $INSPECTIT_CONFIG_HOME/../config/* $INSPECTIT_CONFIG_HOME

	AGENT_NAME=${AGENT_NAME:-$HOSTNAME}
	sed -i "s/^\(repository\) .*/\1 $CMR_ADDR $CMR_PORT $AGENT_NAME/" $INSPECTIT_CONFIG_HOME/inspectit-agent.cfg
	echo "[INFO] Done. Remember to modify the configuration for your needs. You find the configuration in the mapped volume $INSPECTIT_CONFIG_HOME." 
fi

# Version check
if ([[ -n $INSPECTIT_VERSION && -n $CMR_ENV_INSPECTIT_VERSION && $INSPECTIT_VERSION != $CMR_ENV_INSPECTIT_VERSION ]]); then
	echo "[ERROR] Version of inspectIT CMR and agent do not match:"
	echo "[ERROR] Agent: $INSPECTIT_VERSION"
	echo "[ERROR] CMR: $CMR_ENV_INSPECTIT_VERSION"
	echo "[ERROR] You have to use the same version for CMR and agent."
	exit 1
elif ([ -z $CMR_ENV_INSPECTIT_VERSION ]); then
	CMR_REST_VERSION=$(wget http://$CMR_ADDR:8182/rest/cmr/version -qO-)
	if ([ $? -eq 0 ]);then
		if ([ $INSPECTIT_VERSION != $CMR_REST_VERSION ]); then
			echo "[ERROR] Version of inspectIT CMR and agent do not match:"
			echo "[ERROR] Agent: $INSPECTIT_VERSION"
			echo "[ERROR] CMR: $CMR_REST_VERSION"
			echo "[ERROR] You have to use the same version for CMR and agent."
			exit 1
		fi
	else
		echo "[INFO] Running inspectIT with version $INSPECTIT_VERSION"
		echo "[INFO] Make sure your CMR has the same version"
	fi
fi

exec jetty.sh run

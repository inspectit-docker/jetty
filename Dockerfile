FROM jetty:latest

ENV INSPECTIT_VERSION 1.6.7.79

RUN wget https://github.com/inspectIT/inspectIT/releases/download/${INSPECTIT_VERSION}/inspectit-agent-sun1.5.zip -q \
      && unzip inspectit-agent-sun1.5.zip -d /opt \
      && rm -f inspectit-agent-sun1.5.zip

ENV INSPECTIT_AGENT_HOME /opt/agent
ENV INSPECTIT_CONFIG_HOME /opt/agent/active-config
ENV JAVA_OPTIONS -Xbootclasspath/p:${INSPECTIT_AGENT_HOME}/inspectit-agent.jar -javaagent:${INSPECTIT_AGENT_HOME}/inspectit-agent.jar -Dinspectit.config=${INSPECTIT_CONFIG_HOME}

COPY run-with-inspectit.sh /run-with-inspectit.sh
VOLUME /opt/agent/active-config

CMD /run-with-inspectit.sh

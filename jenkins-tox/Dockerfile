FROM jenkins:latest
USER root
RUN apt-get  update && \
	apt-get -y install \
	python-pip \
	python-virtualenv && \
	rm -rf /var/lib/apt/lists/

# Upgrade pip & tox. This can be done in the entrypoint.
RUN pip install -U pip tox 

# The downloaded plugins will be extracted by jenkins.sh
RUN mkdir -p /usr/share/jenkins/ref/plugins
WORKDIR /usr/share/jenkins/ref/plugins

RUN wget -q http://updates.jenkins-ci.org/download/plugins/shiningpanda/0.22/shiningpanda.hpi  -O shiningpanda.hpi
RUN for PLUGIN in shiningpanda.hpi token-macro.hpi plain-credentials.hpi ssh-credentials.hpi scm-api.hpi git.hpi git-client.hpi github.hpi github-api.hpi; do \
	wget -q http://updates.jenkins-ci.org/latest/$PLUGIN -O $PLUGIN; done

WORKDIR /
USER jenkins

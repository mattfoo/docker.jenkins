FROM java:8-jre

MAINTAINER Matt Foo <foo.matt@googlemail.com>

ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.7.1}

ARG JENKINS_SHA
ENV JENKINS_SHA ${JENKINS_SHA:-12d820574c8f586f7d441986dd53bcfe72b95453}

RUN apt-get update && \
    apt-get install -y wget git curl zip && \
    rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Jenkins is ran with user `jenkins`, uid = 1000 If you bind mount a volume
# from host/volume from a data container, ensure you use same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

COPY ./assets/packages/dumb-init_1.1.1_amd64.deb /tmp

RUN dpkg -i /tmp/dumb-init_1.1.1_amd64.deb && \
    rm /tmp/dumb-init_1.1.1_amd64.deb

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

COPY ./assets/build/scripts/*.groovy       /usr/share/jenkins/ref/init.groovy.d/

# could use ADD but this one does not check Last-Modified header
# see https://github.com/docker/docker/issues/8331
RUN curl -# -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war \
  && echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -

ENV JENKINS_UC https://updates.jenkins-ci.org
RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# 8443:  for main web interface:
# 50000: will be used by attached slave agents:
EXPOSE 8443 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# install additional plugins
COPY ./assets/build/etc/plugins.txt /usr/share/jenkins/ref/
COPY ./assets/build/scripts/plugins.sh /usr/local/bin/plugins.sh
RUN   /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

# theme
COPY ./assets/build/etc/org.codefirst.SimpleThemeDecorator.xml "$JENKINS_HOME"

USER jenkins

COPY ./assets/build/scripts/jenkins.sh /usr/local/bin/jenkins.sh

# Jenkins home directoy is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME [ "/var/lib/jenkins", "/usr/share/jenkins" ]

ENTRYPOINT [ "dumb-init", "-v", "/usr/local/bin/jenkins.sh" ]

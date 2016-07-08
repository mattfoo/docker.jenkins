#! /bin/bash

set -e

# Set admin user and password according to our env variables
if [ -f /usr/share/jenkins/ref/init.groovy.d/admin.groovy ]; then
    sed -i "s/%ADMIN_USER%/${ADMIN_USER}/g" /usr/share/jenkins/ref/init.groovy.d/admin.groovy
    sed -i "s/%ADMIN_PASS%/${ADMIN_PASS}/g" /usr/share/jenkins/ref/init.groovy.d/admin.groovy
fi
# Set mail related stuff based on our env variables
if [ -f /usr/share/jenkins/ref/init.groovy.d/admin_mail.groovy ]; then
    sed -i "s/%MAIL_FROM%/${MAIL_FROM}/g" /usr/share/jenkins/ref/init.groovy.d/admin_mail.groovy
fi
if [ -f /usr/share/jenkins/ref/init.groovy.d/email.groovy ]; then
    sed -i "s/%MAIL_FROM%/${MAIL_FROM}/g"     /usr/share/jenkins/ref/init.groovy.d/email.groovy
    sed -i "s/%MAIL_SERVER%/${MAIL_SERVER}/g" /usr/share/jenkins/ref/init.groovy.d/email.groovy
fi
# Set ldap related stuff basend on our env variables
if [ -f /usr/share/jenkins/ref/init.groovy.d/ldap.groovy ]; then
    if [ ${USE_LDAP} == "true" ]; then
	    sed -i "s/%LDAP_GROUP_SEARCH_BASE%/${LDAP_GROUP_SEARCH_BASE}/g"     /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
	    sed -i "s/%LDAP_GROUP_SEARCH_FILTER%/${LDAP_GROUP_SEARCH_FILTER}/g" /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
	    sed -i "s/%LDAP_ROOT_DN%/${LDAP_ROOT_DN}/g"                         /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
	    sed -i "s/%LDAP_SERVER%/${LDAP_SERVER}/g"                           /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
	    sed -i "s/%LDAP_USER_SEARCH%/${LDAP_USER_SEARCH}/g"                 /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
	    sed -i "s/%LDAP_USER_SEARCH_BASE%/${LDAP_USER_SEARCH_BASE}/g"       /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
	    sed -i "s/%LDAP_MANAGER_DN%/${LDAP_MANAGER_DN}/g"                   /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
	    sed -i "s/%LDAP_MANAGER_PASS%/${LDAP_MANAGER_PASS}/g"               /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
    else
        # remove ldap.groovy when USE_LDAP is false, or we get some java errors
        echo "[INFO] LDAP disabled!"
        rm -f /usr/share/jenkins/ref/init.groovy.d/ldap.groovy
    fi
fi


# Set up SSL certificates
echo "[INFO] Checking for Tomcat SSL Certificate..."
if [ ! -f /var/lib/jenkins/cert/.keystore ]; then
    echo "[INFO] Creating keystore file for TLS encryption..."
    mkdir -p /var/lib/jenkins/cert/
    keystorePass=$(openssl rand -base64 22)
    echo "$keystorePass" > /var/lib/jenkins/cert/.keystore.pass
    keytool -genkey -alias jenkins -keyalg EC -validity $VALIDITY \
            -keystore /var/lib/jenkins/cert/.keystore -keypass "$keystorePass" \
            -storepass "$keystorePass" -dname "$DNAME"
    chmod 0640 /var/lib/jenkins/cert/.keystore
    chmod 0640 /var/lib/jenkins/cert/.keystore.pass
    chown jenkins:jenkins /var/lib/jenkins/cert/.keystore
    chown jenkins:jenkins /var/lib/jenkins/cert/.keystore.pass
fi

# $keystorePass="$(cat /var/lib/jenkins/cert/.keystore.pass)"
JENKINS_OPTS="$JENKINS_OPTS --httpsPort=8443 --httpPort=-1 --httpsKeyStore=/var/lib/jenkins/cert/.keystore --httpsKeyStorePassword=$(cat /var/lib/jenkins/cert/.keystore.pass)"

# Copy files from /usr/share/jenkins/ref into /var/jenkins So the initial
# JENKINS-HOME is set with expected content.  Don't override, as this is just a
# reference setup, and use from UI can then change this, upgrade plugins, etc.
copy_reference_file() {
	f=${1%/}
	echo "$f" >> $COPY_REFERENCE_FILE_LOG
    rel=${f:23}
    dir=$(dirname ${f})
    echo " $f -> $rel" >> $COPY_REFERENCE_FILE_LOG
	if [[ ! -e /var/lib/jenkins/${rel} ]]
	then
		echo "copy $rel to jenkins" >> $COPY_REFERENCE_FILE_LOG
		mkdir -p /var/lib/jenkins/${dir:23}
		cp -r /usr/share/jenkins/ref/${rel} /var/lib/jenkins/${rel};
		# pin plugins on initial copy
		[[ ${rel} == plugins/*.jpi ]] && touch /var/lib/jenkins/${rel}.pinned
	fi;
}
export -f copy_reference_file
echo "--- Copying files at $(date)" >> $COPY_REFERENCE_FILE_LOG
find /usr/share/jenkins/ref/ -type f -exec bash -c "copy_reference_file '{}'" \;

# if `docker run` first argument start with `--` the user is passing jenkins
# launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   exec java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for
# sample a `bash` shell to explore this image
exec "$@"


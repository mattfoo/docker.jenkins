import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.*

String groupSearchBase     = %LDAP_GROUP_SEARCH_BASE%
String groupSearchFilter   = %LDAP_GROUP_SEARCH_FILTER%
String managerDN           = %LDAP_MANAGER_DN%
String managerPassword     = %LDAP_MANAGER_PASS%
String rootDN              = %LDAP_ROOT_DN%
String server              = %LDAP_SERVER%
String userSearch          = %LDAP_USER_SEARCH%
String userSearchBase      = %LDAP_USER_SEARCH_BASE%
boolean inhibitInferRootDN = false

SecurityRealm ldap_realm = new LDAPSecurityRealm(server, rootDN, userSearchBase, userSearch, groupSearchBase, managerDN, managerPassword, inhibitInferRootDN)
Jenkins.instance.setSecurityRealm(ldap_realm)
Jenkins.instance.save()

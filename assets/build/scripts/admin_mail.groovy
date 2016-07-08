import jenkins.model.*

def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()

jenkinsLocationConfiguration.setAdminAddress("<%MAIL_FROM%>")

jenkinsLocationConfiguration.save()

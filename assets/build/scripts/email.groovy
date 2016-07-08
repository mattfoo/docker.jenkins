import jenkins.model.*

def inst = Jenkins.getInstance()

def desc = inst.getDescriptor("hudson.tasks.Mailer")

desc.setReplyToAddress("%MAIL_FROM%")
desc.setSmtpHost("%MAIL_SERVER%")
desc.setUseSsl(false)
desc.setSmtpPort("25")
desc.setCharset("UTF-8")

desc.save()

#!/bin/bash
yum remove java-1.7.0-openjdk -y
yum install java-1.8.0 -y
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum install jenkins -y

sed -i s/'-Djava.awt.headless=true'/'-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false'/ /etc/sysconfig/jenkins

mkdir /var/lib/jenkins/init.groovy.d
test='
#!groovy\n
\n
import jenkins.model.*\n
import hudson.util.*;\n
import jenkins.install.*;\n
import hudson.security.*;\n

def instance = Jenkins.getInstance()\n

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)\n

instance.setSecurityRealm(new HudsonPrivateSecurityRealm(false))\n
def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()\n
strategy.setAllowAnonymousRead(false)\n
instance.setAuthorizationStrategy(strategy)\n

def user = instance.getSecurityRealm().createAccount("admin", "admin-pass")\n
user.save()\n
instance.save()\n
'

echo -e $test > /var/lib/jenkins/init.groovy.d/basic-security.groovy

service jenkins start
service jenkins enable

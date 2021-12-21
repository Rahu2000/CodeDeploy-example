#################################################
#
# CodeDeploy agent installer
#
# caution: sudo permission required
#           or must be run as root
#################################################
#!/bin/bash

## Variable setting
REGION=ap-northeast-2               # S3 bucket's region for CodeDeploy agent
REVISIONS=2                         # default: 5
ENABLE_PRIVATE_ENDPOINT=false       # When to use NAT: false

## Install dependencies
sudo yum update
sudo yum install ruby -y
sudo yum install wget -y

## Uninstall old codedeploy agent version
CODEDEPLOY_BIN="/opt/codedeploy-agent/bin/codedeploy-agent"
if [[ -d ${CODEDEPLOY_BIN} ]]; then
    $CODEDEPLOY_BIN stop
    sudo yum erase codedeploy-agent -y 2>dev/null
fi

## Download CodeDeploy agent's installer
cd ~/
wget https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install

## install
chmod +x ./install
sudo ./install auto

## configuration change
sudo sed -i "s/:max_revisions: 5/:max_revisions: ${REVISIONS}/g" /etc/codedeploy-agent/conf/codedeployagent.yml

if [[ "true" == ${ENABLE_PRIVATE_ENDPOINT} ]]; then
    echo -e ":enable_auth_policy: true" | sudo tee -a /etc/codedeploy-agent/conf/codedeployagent.yml
fi

## restart codedeploy-agent service
sudo service codedeploy-agent restart

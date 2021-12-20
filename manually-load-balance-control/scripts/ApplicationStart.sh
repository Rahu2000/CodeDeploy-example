###############################################
# exmaple ApplicationStart.sh
###############################################
#!/bin/bash

## Set Codedeploy agent script base dir
BASE_DIR="/opt/codedeploy-agent/deployment-root/${DEPLOYMENT_GROUP_ID}/${DEPLOYMENT_ID}/deployment-archive"

## Export deployment environments
source "${BASE_DIR}/deployment.conf"

LOG_DATE=`(date '+%Y-%m-%d')`

## Restart service
systemctl restart <TargetServcie>

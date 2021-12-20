###############################################
# exmaple BeforeInstall.sh
###############################################
#!/bin/bash

## Set Codedeploy agent script base dir
BASE_DIR="/opt/codedeploy-agent/deployment-root/${DEPLOYMENT_GROUP_ID}/${DEPLOYMENT_ID}/deployment-archive"

## export deployment environments
source "${BASE_DIR}/deployment.conf"

## get current instacne id
if [[ "true" == ${USE_ELB} ]]; then
  INSTANCE_ID=`(curl http://169.254.169.254/latest/meta-data/instance-id)` | echo -e "INSTANCE_ID=$INSTANCE_ID" | tee -a "${BASE_DIR}/deployment.conf"
fi

## Backup
BACKUP_TIME=`(date '+%Y%m%d%H%M%S')` | echo -e "BACKUP_TIME=${BACKUP_TIME}" | tee -a "${BASE_DIR}"/deployment.conf
cp -rp ${APP_PATH}/${APP_NAME} ${APP_PATH}/${APP_NAME}_${BACKUP_TIME}

## Stop Service
systemctl stop <TargetServcie>

## Deregister instance from LB
if [[ "true" == ${USE_ELB} ]]; then
  aws elbv2 deregister-targets \
      --target-group-arn "${TG_ARN}" \
      --targets Id="${INSTANCE_ID}"
fi

###############################################
# exmaple ValidateService.sh
###############################################
#!/bin/bash

## Set Codedeploy agent script base dir
BASE_DIR="/opt/codedeploy-agent/deployment-root/${DEPLOYMENT_GROUP_ID}/${DEPLOYMENT_ID}/deployment-archive"

## Export deployment environments
source "${BASE_DIR}/deployment.conf"

LOG_DATE=`(date '+%Y-%m-%d')`

## e.g. validate service healthy
while true;
do
  EVAL= $(cat "${LOG_PATH}/${LOG_FILE_PREFIX}-${LOG_DATE}.0.log" 2> /dev/null | grep "${VERSION}" )
  if [ -z ${EVAL} ]; then
    sleep 1
  else
    echo "The service has been restarted."
    exit 0
  fi
done

## Register instance to LB
if [[ "true" == ${USE_ELB} ]]; then
  aws elbv2 register-targets \
      --target-group-arn "${TG_ARN}" \
      --targets Id="${INSTANCE_ID}",Port=${TG_PORT}
fi
###############################################
# exmaple AfterInstall.sh
###############################################
#!/bin/bash

## Convert array to string
function arrayToString {
  STR=""
  for N in "$@"; do
    STR="$STR $N"
  done
  echo $STR
}

## Set variables
S3_UPLOAD_INSTANCE_ID=""          # S3 sync only on specific instances
WAS_HOME=""                       # Service Home e.g. Tomcat
REGION="ap-northeast-2"           # Default Region
DISTRIBUTION_ID=""                # CloudFront distibution id
S3_BUCKET=""                      # S3 bucket for CloudFront
AWS_CLI="/usr/local/bin/aws"      # AWS cmd binary path of EC2 instance
BASE_DIR="/opt/codedeploy-agent/deployment-root/${DEPLOYMENT_GROUP_ID}/${DEPLOYMENT_ID}/deployment-archive"     # CodeDeploy agent Home

## Stop target service
service tomcat stop

## validate service healthy
while true; do
  EVAL=$(ps -ef | grep tomcat | grep Bootstrap 2>/dev/null)
  if [[ -z ${EVAL} ]]; then
    sleep 1
  else
    echo "Deployment complete"
    break
  fi
done

# eval specific instances
CURRENT_INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
if [[ ${S3_UPLOAD_INSTANCE_ID} != ${CURRENT_INSTANCE_ID} ]]; then
  exit 0
fi

## Wait for WAS_HOME is unpacked
while true; do
  if [[ -d ${WAS_HOME} ]]; then
    break
  else
    sleep 1
  fi
done

## Sync files between local and S3
${AWS_CLI} s3 sync ${WAS_HOME} s3://${S3_BUCKET}/static/ --delete --region $REGION \
  --exclude "favicon.ico" --exclude "META-INF/*" --exclude "WEB-INF/*" --exclude "index.jsp" \
  --size-only >${BASE_DIR}/sync_files

# CloudFront invalidation
unset EVAL
SYNCED_FILES=$(tr -d '\r' <${BASE_DIR}/sync_files | grep 's3://' | grep -Ev '\.do|\.jsp' | awk -F "s3://${S3_BUCKET}/static" '{print $2}')
PATHS_STR=$(arrayToString ${SYNCED_FILES})

if [[ -n "${PATHS_STR}" ]]; then
  ID=$(${AWS_CLI} cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths ${PATHS_STR} --region ${REGION} --query 'Invalidation.Id' | tr -d '"')

  ## Validate create-invalidation progress
  while true; do
    EVAL=$(${AWS_CLI} cloudfront get-invalidation --id ${ID} --distribution-id ${DISTRIBUTION_ID} | grep "Completed")
    if [[ -z ${EVAL} ]]; then
      sleep 1
    else
      echo "CloudFront invalidation completed"
      break
    fi
  done
fi

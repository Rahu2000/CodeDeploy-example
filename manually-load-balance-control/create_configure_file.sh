###############################################
# Before calling Codedeploy,
# you must create a deployment.conf file.
#
# e.g.
#   Codebuild or Jenkins can create the file
###############################################
#!/bin/bash

VERSION=`cat ./ver | awk -F 'V' '{print $2}'`                         # Example of getting application version

## Create deployment.conf for scripts
echo 'APP_NAME=<Deploy target app file>' > deployment.conf            # mandatory : Application Binary file name
echo 'APP_PATH=<Deploy target app directory>' >> deployment.conf      # mandatory : Application home directory
echo 'VERSION='"${VERSION}" >> deployment.conf                        # mandatory : application version
echo 'LOG_PATH=<App log path>' >> deployment.conf                     # mandatory : Log file directory for health check
echo 'LOG_FILE_PREFIX=<Log file name prefix>' >> deployment.conf      # mandatory : Log file name prefix
echo 'USE_ELB=' >> deployment.conf                                    # Optional : boolean, Flag for elb target deregister
echo 'TG_ARN=' >> deployment.conf                                     # Optional : string, ELB Target group ARN
echo 'TG_PORT=' >> deployment.conf                                    # Optional : number, ELB Target port

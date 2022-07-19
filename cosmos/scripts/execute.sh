#!/bin/sh

cloud-init status --wait
echo "##########CUSTOM_SCRIPT_URL###########: $CUSTOM_SCRIPT_URL"
echo "##########DEPLOYMENT_NAME###########: $DEPLOYMENT_NAME"
whoami
pwd
# Running below commands in background, arm template completion wont wait on this
# stdout and stderr logs will go in <$HOME>/<$DEPLOYMENT_NAME>.out and <$HOME>/<$DEPLOYMENT_NAME>.err
curl -o custom-script.sh $CUSTOM_SCRIPT_URL
echo "/home/${ADMIN_USER_NAME}/${DEPLOYMENT_NAME}.out"
echo "/home/${ADMIN_USER_NAME}/${DEPLOYMENT_NAME}.err"
nohup bash custom-script.sh > "/home/${ADMIN_USER_NAME}/${DEPLOYMENT_NAME}.out" 2> "/home/${ADMIN_USER_NAME}/${DEPLOYMENT_NAME}.err" &

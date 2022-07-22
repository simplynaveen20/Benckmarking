#!/bin/sh

cloud-init status --wait
echo "##########CUSTOM_SCRIPT_URL###########: $CUSTOM_SCRIPT_URL"
echo "##########DEPLOYMENT_NAME###########: $DEPLOYMENT_NAME"
# Running custom-script in background, arm template completion wont wait on this
# stdout and stderr will be logged in <$HOME>/<$DEPLOYMENT_NAME>.out and <$HOME>/<$DEPLOYMENT_NAME>.err
curl -o custom-script.sh $CUSTOM_SCRIPT_URL
nohup bash custom-script.sh > "/home/${ADMIN_USER_NAME}/${DEPLOYMENT_NAME}.out" 2> "/home/${ADMIN_USER_NAME}/${DEPLOYMENT_NAME}.err" &

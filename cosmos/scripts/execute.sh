#!/bin/sh

cloud-init status --wait
echo "##########CUSTOM_SCRIPT_URL###########: $CUSTOM_SCRIPT_URL"
# Running below commands in background, arm template completion wont wait on this
# stdout and stderr logs will go in <$HOME>/<$DEPLOYMENT_NAME>.out and <$HOME>/<$DEPLOYMENT_NAME>.err
curl -o custom-script.sh $CUSTOM_SCRIPT_URL
nohup bash custom-script.sh > "${HOME}/${DEPLOYMENT_NAME}.out" 2> "${HOME}/${DEPLOYMENT_NAME}.err" &

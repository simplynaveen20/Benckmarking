#!/bin/sh

cloud-init status --wait

# Running below commands in background, arm template completion wont wait on this
# stdout and stderr logs will go in <$HOME>/<$DEPLOYMENT_NAME>.out and <$HOME>/<$DEPLOYMENT_NAME>.err
curl -o custom-script.sh CUSTOM_SCRIPT_URL
nohub bash custom-script.sh > "${HOME}/${DEPLOYMENT_NAME}.out" 2> "${HOME}/${DEPLOYMENT_NAME}.err" &

#!/bin/bash
# based on https://github.com/ffeldhaus/docker-xpra-html5-gpu-minimal/blob/master/docker-entrypoint.sh

XPRA_USER=xpra
SCRIPT_PATH=./scripts

$SCRIPT_PATH/check-dri.sh $CARD
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/fix-video-groups.sh $CARD $XPRA_USER
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

$SCRIPT_PATH/fix-audio-groups.sh $XPRA_USER
retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

# make the socket accessible to HIP apps
chmod -R 1777 /tmp/.X11-unix/
# remove a previous lock, if it exists
rm -rf /tmp/.X80-lock

# start xpra as $XPRA_USER
#CMD="XPRA_PASSWORD=$XPRA_PASSWORD /usr/bin/xpra start --daemon=no --start-child='$@'"
#runuser -l $XPRA_USER -c "pulseaudio --start; pulseaudio --kill; xpra start :80 --bind-tcp=0.0.0.0:8080,auth=password:value=mysecret --html=on --no-daemon --start='xhost +' -d auth"
#runuser -l $XPRA_USER -c 'sleep 1000000000000'
if [ $XPRA_KEYCLOAK_AUTH = "yes" ]; then
  AUTH=",auth=keycloak"
fi

runuser -l $XPRA_USER -c "pulseaudio --start; pulseaudio --kill; XPRA_KEYCLOAK_SERVER_URL=$XPRA_KEYCLOAK_SERVER_URL XPRA_KEYCLOAK_REALM_NAME=$XPRA_KEYCLOAK_REALM_NAME XPRA_KEYCLOAK_CLIENT_ID=$XPRA_KEYCLOAK_CLIENT_ID XPRA_KEYCLOAK_CLIENT_SECRET_KEY=$XPRA_KEYCLOAK_CLIENT_SECRET_KEY XPRA_KEYCLOAK_REDIRECT_URI=$XPRA_KEYCLOAK_REDIRECT_URI XPRA_KEYCLOAK_SCOPE=$XPRA_KEYCLOAK_SCOPE XPRA_KEYCLOAK_GRANT_TYPE=$XPRA_KEYCLOAK_GRANT_TYPE xpra start :80 --bind-tcp=0.0.0.0:8080$AUTH --html=on --no-daemon --start='xhost +' -d auth"
#runuser -l $XPRA_USER -c "pulseaudio --start; pulseaudio --kill; XPRA_KEYCLOAK_SERVER_URL=$XPRA_KEYCLOAK_SERVER_URL XPRA_KEYCLOAK_REALM_NAME=$XPRA_KEYCLOAK_REALM_NAME XPRA_KEYCLOAK_CLIENT_ID=$XPRA_KEYCLOAK_CLIENT_ID XPRA_KEYCLOAK_CLIENT_SECRET_KEY=$XPRA_KEYCLOAK_CLIENT_SECRET_KEY XPRA_KEYCLOAK_REDIRECT_URI=$XPRA_KEYCLOAK_REDIRECT_URI XPRA_KEYCLOAK_SCOPE=$XPRA_KEYCLOAK_SCOPE XPRA_KEYCLOAK_GRANT_TYPE=$XPRA_KEYCLOAK_GRANT_TYPE xpra start :80 --bind-tcp=0.0.0.0:8080$AUTH --html=on --no-daemon --start='xhost +'"

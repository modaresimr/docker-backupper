PING_URL=$(curl https://${HC_HOST:-hc-ping.com}/api/v3/checks/?tag=$BACKUP_NAME --header "X-Api-Key: ${HC_API_KEY}"     |jq -r .checks[0].ping_url)

if [ $PING_URL == "null" ];then
     PING_URL=$(curl https://${HC_HOST:-hc-ping.com}/api/v3/checks/ --header "X-Api-Key: ${HC_API_KEY}" \
        --data '{"name": "${BACKUP_NAME}", "tags": "${BACKUP_NAME}", "grace": 3600, "schedule": "${VOLUMERIZE_JOBBER_TIME}", "channels": "*" }' \
        |jq -r .checks[0].ping_url)
fi
curl https://${PING_URL}/start

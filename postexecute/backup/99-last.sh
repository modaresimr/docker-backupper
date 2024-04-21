NAME="${BACKUP_PREFIX}_${BACKUP_NAME}"
PING_URL=$(curl https://${HC_HOST:-hc-ping.com}/api/v3/checks/?tag="${NAME}" --header "X-Api-Key: ${HC_API_KEY}"     |jq -r .checks[0].ping_url)

curl $PING_URL 

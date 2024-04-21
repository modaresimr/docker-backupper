NAME="${BACKUP_PREFIX}_${BACKUP_NAME}"
PING_URL=$(curl https://${HC_HOST:-hc-ping.com}/api/v3/checks/?tag=${NAME} --header "X-Api-Key: ${HC_API_KEY}"     |jq -r .checks[0].ping_url)

if [ "$PING_URL" == "null" ] || [ "$PING_URL" == "" ];then
payload=$(cat <<EOF
{
  "name": "${NAME}",
  "tags": "${NAME}",
  "grace": 3600,
  "schedule": "${VOLUMERIZE_JOBBER_TIME}",
  "channels": "*"
}
EOF
)

        PING_URL=$(curl "https://${HC_HOST:-hc-ping.com}/api/v3/checks/" \
                --header "X-Api-Key: ${HC_API_KEY}" \
                --data "$payload" | jq -r '.ping_url')
fi
curl https://${PING_URL}/start

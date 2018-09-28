# certbot godaddy dns cleanup hook
# @aravindanve

# env variables
# CERTBOT_DOMAIN
# CERTBOT_VALIDATION
# DNS_CREDENTIALS_FILE

# strip wildcard prefix
domain=`expr match "${CERTBOT_DOMAIN}" '\*\?\.\?\(.*\)'`

# output
echo "deleting _acme-challenge TXT record for ${domain} ..."

# options
api_url="https://api.godaddy.com"
api_key=`expr match "$(cat "${DNS_CREDENTIALS_FILE}" | grep API_KEY)" 'API_KEY=\(.*\)'`
api_secret=`expr match "$(cat "${DNS_CREDENTIALS_FILE}" | grep API_SECRET)" 'API_SECRET=\(.*\)'`

# validate credentials
if [ -z $api_key ] || [ -z $api_secret ]; then
  echo "API_KEY and API_SECRET must be present in ${DNS_CREDENTIALS_FILE}"
  exit 1;
fi

# delete record
curl \
  -X PUT "${api_url}/v1/domains/${domain}/records/TXT/_acme-challenge" \
  -H "Authorization: sso-key ${api_key}:${api_secret}" \
  -H 'Content-Type: application/json' \
  -d "[]"

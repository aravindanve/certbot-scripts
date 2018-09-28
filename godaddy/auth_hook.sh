# certbot godaddy dns auth hook
# @aravindanve

# env variables
# CERTBOT_DOMAIN
# CERTBOT_VALIDATION
# DNS_CREDENTIALS_FILE

# strip wildcard prefix
domain=`expr match "${CERTBOT_DOMAIN}" '\*\?\.\?\(.*\)'`

# output
echo "adding _acme-challenge TXT record for ${domain} ..."

# options
api_url="https://api.godaddy.com"
api_key=`expr match "$(cat "${DNS_CREDENTIALS_FILE}" | grep API_KEY)" 'API_KEY=\(.*\)'`
api_secret=`expr match "$(cat "${DNS_CREDENTIALS_FILE}" | grep API_SECRET)" 'API_SECRET=\(.*\)'`

# validate credentials
if [ -z $api_key ] || [ -z $api_secret ]; then
  echo "API_KEY and API_SECRET must be present in ${DNS_CREDENTIALS_FILE}"
  exit 1;
fi

# add record
curl \
  -X PATCH "${api_url}/v1/domains/${domain}/records" \
  -H "Authorization: sso-key ${api_key}:${api_secret}" \
  -H 'Content-Type: application/json' \
  -d "[\
    {\
      \"type\": \"TXT\",
      \"name\": \"_acme-challenge\",
      \"data\": \"${CERTBOT_VALIDATION}\",
      \"ttl\": 3600\
    }\
  ]"

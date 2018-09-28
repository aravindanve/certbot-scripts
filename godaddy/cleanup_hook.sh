#!/bin/bash
# certbot godaddy dns cleanup hook
# @aravindanve

# env variables
# CERTBOT_DOMAIN
# CERTBOT_VALIDATION

# set base path (hooks are called from their own directory)
base_path="$(dirname `which "$0"`)/.."

# options
dns_credentials_file=$1
domain=$2

# strip wildcard prefix
record_name=`expr match "${CERTBOT_DOMAIN}" '\*\?\.\?\(.*\)'`

# strip domain part and add challenge prefix
record_name="_acme-challenge.${record_name/\.${domain}/}"

# output
echo "adding ${record_name} TXT record for domain ${domain} ..."

# options
api_url=`expr match "$(cat "${dns_credentials_file}" | grep API_URL)" 'API_URL=\(.*\)'`
api_key=`expr match "$(cat "${dns_credentials_file}" | grep API_KEY)" 'API_KEY=\(.*\)'`
api_secret=`expr match "$(cat "${dns_credentials_file}" | grep API_SECRET)" 'API_SECRET=\(.*\)'`

# validate credentials
if [ -z $api_url ] || [ -z $api_key ] || [ -z $api_secret ]; then
  echo "API_URL, API_KEY and API_SECRET must be present in ${dns_credentials_file}"
  exit 1;
fi

# delete record
curl \
  -X PUT "${api_url}/v1/domains/${domain}/records/TXT/${record_name}" \
  -H "Authorization: sso-key ${api_key}:${api_secret}" \
  -H 'Content-Type: application/json' \
  -d "[]"

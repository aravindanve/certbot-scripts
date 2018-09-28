# certbot certonly with dns challenge
# @aravindanve
# usage: ./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <DOMAINS>

# TODO: update auto-renew cron command

# set base path
base_path=$(dirname `which "$0"`)

# options
dns=$1
dns_credentials_file=$2
email=$3
domains=$4
server="https://acme-v02.api.letsencrypt.org/directory"

# validate dns
if [ 'godaddy' = "${dns}" ]; then
  auth_hook=$base_path/godaddy/auth_hook.sh
  cleanup_hook=$base_path/godaddy/cleanup_hook.sh

elif [ 'azure' = "${dns}" ]; then
  echo "Support for ${dns} not implemented"
  exit 1

else
  echo "DNS must be either godaddy or azure"
  echo "usage: ./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <DOMAINS>"
  exit 1
fi

# validate credentials file
if [ -f $dns_credentials_file ]; then
  echo "Credentials file ${dns_credentials_file} not found"
  exit 1
fi

# options
api_url=`expr match "$(cat "${DNS_CREDENTIALS_FILE}" | grep API_URL)" 'API_URL=\(.*\)'`
api_key=`expr match "$(cat "${DNS_CREDENTIALS_FILE}" | grep API_KEY)" 'API_KEY=\(.*\)'`
api_secret=`expr match "$(cat "${DNS_CREDENTIALS_FILE}" | grep API_SECRET)" 'API_SECRET=\(.*\)'`

# validate credentials
if [ -z $api_url ] || [ -z $api_key ] || [ -z $api_secret ]; then
  echo "API_URL, API_KEY and API_SECRET must be present in ${DNS_CREDENTIALS_FILE}"
  exit 1;
fi

# validate options
if [ -z $email ]; then
  echo "Email is required"
  echo "usage: ./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <DOMAINS>"
  exit 1
fi

if [ -z $domains ]; then
  echo "Comma separated list of domains are required"
  echo "usage: ./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <DOMAINS>"
  exit 1
fi

# renew certs
(
  export DNS_CREDENTIALS_FILE=$dns_credentials_file;
  sudo certbot certonly \
    --manual \
    --manual-auth-hook "$auth_hook" \
    --manual-cleanup-hook "$cleanup_hook" \
    --preferred-challenges dns-01 \
    --agree-tos \
    -n \
    --server "$server" \
    --email "$email" \
    -d "$domains"
)

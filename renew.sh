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
if [ dns = 'godaddy' ]; then
  auth_hook=$base_path/godaddy/auth_hook.sh
  cleanup_hook=$base_path/godaddy/cleanup_hook.sh

else if [ dns = 'azure' ]; then
  echo "Support for $dns not implemented"
  exit 1

else
  echo "Support for $dns not implemented"
  exit 1
fi

# validate credentials file
if [ ! -f $dns_credentials_file ]; then
  echo "Credentials file ${dns_credentials_file} not found"
  exit 1;
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

#!/bin/bash
# certbot certonly with dns challenge
# @aravindanve
# usage: ./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <ZONE> <DOMAINS>
# example: ./renew.sh godaddy ~/.credentials/godaddy michael@dundermifflin.com example.com sub.example.com,sub.sub.example.com,*.sub.sub.example.com

# TODO: update auto-renew cron command

# set base path
base_path=$(dirname `which "$0"`)

# help
help_usage="USAGE: ./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <ZONE> <DOMAINS>"
help_example="EXAMPLE: ./renew.sh godaddy ~/.credentials/godaddy michael@dundermifflin.com example.com sub.example.com,sub.sub.example.com,*.sub.sub.example.com"

# options
dns=$1
dns_credentials_file=$2
email=$3
zone=$4
domains=$5
server="https://acme-v02.api.letsencrypt.org/directory"

# validate dns
if [ 'godaddy' = "${dns}" ]; then
  auth_hook=$base_path/godaddy/auth_hook.sh
  cleanup_hook=$base_path/godaddy/cleanup_hook.sh

elif [ 'azure' = "${dns}" ]; then
  echo "support for ${dns} not implemented"
  exit 1

else
  echo "DNS must be either godaddy or azure"
  echo -e "${help_usage}\n${help_example}"
  exit 1
fi

# make sure $dns_credentials_file is an absolute path
if [[ "${dns_credentials_file:0:1}" != / && "${dns_credentials_file:0:2}" != ~[/a-z] ]]; then
    dns_credentials_file="${PWD}/${dns_credentials_file}"
fi

# validate credentials file
if [ ! -f $dns_credentials_file ]; then
  echo "credentials file ${dns_credentials_file} not found"
  exit 1
fi

# options
api_url=`expr match "$(cat "${dns_credentials_file}" | grep API_URL)" 'API_URL=\(.*\)'`
api_key=`expr match "$(cat "${dns_credentials_file}" | grep API_KEY)" 'API_KEY=\(.*\)'`
api_secret=`expr match "$(cat "${dns_credentials_file}" | grep API_SECRET)" 'API_SECRET=\(.*\)'`

# validate credentials
if [ -z $api_url ] || [ -z $api_key ] || [ -z $api_secret ]; then
  echo "API_URL, API_KEY and API_SECRET must be present in ${dns_credentials_file}"
  exit 1;
fi

# validate options
if [ -z $email ]; then
  echo "email is required"
  echo -e "${help_usage}\n${help_example}"
  exit 1
fi

if [ -z $zone ]; then
  echo "zone is required"
  echo -e "${help_usage}\n${help_example}"
  exit 1
fi

if [ -z $domains ]; then
  echo "comma separated list of domains are required"
  echo -e "${help_usage}\n${help_example}"
  exit 1
fi

# renew certs
sudo certbot certonly \
  --manual \
  --manual-auth-hook "$auth_hook $dns_credentials_file $zone" \
  --manual-cleanup-hook "$cleanup_hook $dns_credentials_file $zone" \
  --preferred-challenges dns-01 \
  --agree-tos \
  --manual-public-ip-logging-ok \
  -n \
  --server "$server" \
  --email "$email" \
  -d "$domains"

# Certbot Scripts

## Wildcard DNS Verification

```bash
./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <ZONE> <DOMAINS>
```

## Example

```bash
# renew ssl certs for subdomain.example.com and *.subdomain.example.com
sudo ./renew.sh godaddy ~/.credentials/godaddy me@example.com example.com subdomain.example.com,*.subdomain.vvents.com
```

## GoDaddy Credentials File Examples

### OTE

```bash
# ~/.credentials/godaddy
API_URL=https://api.ote-godaddy.com
API_KEY=YOUR_API_KEY
API_SECRET=YOUR_API_SECRET
```

### Production

```bash
# ~/.credentials/godaddy
API_URL=https://api.godaddy.com
API_KEY=YOUR_API_KEY
API_SECRET=YOUR_API_SECRET
```

# Certbot Scripts

## Wildcard DNS Verification

```bash
./renew.sh <DNS:godaddy|azure> <DNS_CREDENTIALS_FILE> <EMAIL> <DOMAINS>
```

## GoDaddy Credentials File Examples

### OTE
```
API_URL=https://api.ote-godaddy.com
API_KEY=YOUR_API_KEY
API_SECRET=YOUR_API_SECRET
```

### Production
```
API_URL=https://api.godaddy.com
API_KEY=YOUR_API_KEY
API_SECRET=YOUR_API_SECRET
```

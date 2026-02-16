---
title: Technitium DNS Setup Guide
date: 2025-01-12 18:00:00
categories:
  - how-to
tags:
  - documentation
  - dns
  - network
  - letsencrypt
  - doh
  - dot
  - self-host
---
# 📃 Technitium DNS Server Setup Guide

This guide documents how to set up Technitium DNS Server on Ubuntu with nginx reverse proxy, Let's Encrypt SSL certificates, and DNS-over-HTTPS (DoH) / DNS-over-TLS (DoT) support.

## Prerequisites

- Ubuntu server (tested on Ubuntu 24)
- Domain registered with Cloudflare (for DNS management and cert automation)
- Root/sudo access

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     YOUR VPS (Ubuntu)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Port 443 (HTTPS)          Port 853 (DoT)     Port 53 (DNS)    │
│         │                         │                  │          │
│         ▼                         │                  │          │
│   ┌──────────┐                    │                  │          │
│   │  NGINX   │                    │                  │          │
│   │ (TLS     │                    │                  │          │
│   │ Termination)                  │                  │          │
│   └────┬─────┘                    │                  │          │
│        │                          │                  │          │
│        ▼                          ▼                  ▼          │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                  TECHNITIUM DNS SERVER                  │   │
│   ├─────────────────────────────────────────────────────────┤   │
│   │  Port 5380  - Web UI (proxied via nginx)                │   │
│   │  Port 8053  - DNS-over-HTTP (proxied via nginx)         │   │
│   │  Port 853   - DNS-over-TLS (native)                     │   │
│   │  Port 53    - Standard DNS (native)                     │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Traffic Flow:**
- `https://dns.yourdomain.com` → nginx (443) → Technitium Web UI (5380)
- `https://dns.yourdomain.com/dns-query` → nginx (443) → Technitium DoH (8053)
- `dns.yourdomain.com:853` → Technitium DoT (853) directly
- `dns.yourdomain.com:53` → Technitium DNS (53) directly

---

## Part 1: Install Technitium DNS Server

### Ubuntu Installation

```bash
# Download and run the installer
curl -sSL https://download.technitium.com/dns/install.sh | sudo bash
```

The installer creates a systemd service. Verify it's running:

```bash
sudo systemctl status technitium-dns-server
# or depending on your setup:
sudo systemctl status dns
```

Check what ports Technitium is listening on:

```bash
sudo ss -tlnp | grep dotnet
```

Expected output:
```
LISTEN 0      100          0.0.0.0:853       0.0.0.0:*    users:(("dotnet",...))
LISTEN 0      100          0.0.0.0:53        0.0.0.0:*    users:(("dotnet",...))
LISTEN 0      512                *:5380            *:*    users:(("dotnet",...))
```

Access the Web UI at `http://YOUR_SERVER_IP:5380` to complete initial setup.

---

## Part 2: Install and Configure Nginx

### Install Nginx

```bash
sudo apt update
sudo apt install nginx
```

### Configure Nginx as Reverse Proxy

Create the configuration file:

```bash
sudo nano /etc/nginx/sites-available/dns.conf
```

Add this configuration (replace `yourdomain.com` with your actual domain):

```nginx
server {
    listen 80;
    server_name dns.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name dns.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/yourdomain.com/chain.pem;

    access_log /var/log/nginx/dns-access.log;
    error_log /var/log/nginx/dns-error.log;

    # DoH endpoint
    location = /dns-query {
        proxy_pass http://127.0.0.1:8053/dns-query;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Technitium Web UI (everything else)
    location / {
        proxy_pass http://127.0.0.1:5380;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/dns.conf /etc/nginx/sites-enabled/
sudo nginx -t
```

> ⚠️ **Don't start nginx yet** - we need SSL certificates first.

---

## Part 3: SSL Certificates with Let's Encrypt

### Install Certbot with Cloudflare Plugin

```bash
sudo apt install certbot python3-certbot-dns-cloudflare
# If on a redhat system like fedora also enable the service:
sudo systemctl enable --now certbot-renew.timer
```

### Create Cloudflare API Credentials

1. Go to Cloudflare Dashboard → My Profile → API Tokens
2. Create Token → Use "Edit zone DNS" template
3. Zone Resources: Include → Specific zone → yourdomain.com
4. Create and copy the token

Create the credentials file:

```bash
sudo mkdir -p /etc/letsencrypt/cloudflare
sudo nano /etc/letsencrypt/cloudflare/credentials.ini
```

Add:

```ini
dns_cloudflare_api_token = YOUR_API_TOKEN_HERE
```

Secure the file:

```bash
sudo chmod 600 /etc/letsencrypt/cloudflare/credentials.ini
```

### Obtain Wildcard Certificate

```bash
sudo certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials /etc/letsencrypt/cloudflare/credentials.ini \
    -d "*.yourdomain.com" \
    -d "yourdomain.com"
```

### Verify Auto-Renewal

```bash
sudo certbot renew --dry-run
```

Check the timer is enabled:

```bash
sudo systemctl status certbot.timer
```

---

## Part 4: Configure Technitium for Nginx Proxy

### Critical: Port Conflict Resolution

By default, Technitium's web service may try to use port 443 for HTTPS, which conflicts with nginx.

**Access Technitium UI** (temporarily if needed):

```bash
# If nginx isn't running yet, access directly:
http://YOUR_SERVER_IP:5380

# Or use SSH tunnel from your local machine:
ssh -L 5380:127.0.0.1:5380 user@YOUR_SERVER_IP
# Then browse to http://localhost:5380
```

### Web Service Settings

Go to **Settings → Web Service**:

1. **Enable HTTPS**: Uncheck (nginx handles TLS)
2. **Web Service HTTPS Port**: Change from 443 to 8443 (or any unused port)
3. **Real IP Header**: Set to `X-Real-IP`

### Optional Protocols Settings

Go to **Settings → Optional Protocols**:

1. **Enable DNS-over-HTTP**: ✅ Check
2. **DNS-over-HTTP Port**: 8053
3. **Enable DNS-over-TLS**: ✅ Check
4. **DNS-over-TLS Port**: 853
5. **Enable DNS-over-HTTPS**: ✅ Check (optional, for direct access)
6. **DNS-over-HTTPS Port**: 8443 (not 443!)
7. **Reverse Proxy Network ACL**: Add `127.0.0.1` and `::1`

> ⚠️ **Important**: The Reverse Proxy Network ACL must include `127.0.0.1` for nginx to proxy requests successfully.

Save settings and restart Technitium:

```bash
sudo systemctl restart dns  # or technitium-dns-server
```

Verify ports:

```bash
sudo ss -tlnp | grep dotnet
```

Expected:
```
LISTEN 0      100          0.0.0.0:853       0.0.0.0:*    users:(("dotnet",...))
LISTEN 0      100          0.0.0.0:53        0.0.0.0:*    users:(("dotnet",...))
LISTEN 0      512                *:8053            *:*    users:(("dotnet",...))
LISTEN 0      512                *:5380            *:*    users:(("dotnet",...))
LISTEN 0      512                *:8443            *:*    users:(("dotnet",...))
```

---

## Part 5: Start Services and Configure DNS

### Start Nginx

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

### Cloudflare DNS Records

In Cloudflare DNS management, add:

| Type | Name | Content | Proxy Status |
|------|------|---------|--------------|
| A | dns | YOUR_VPS_IP | DNS only (grey cloud) |
| AAAA | dns | YOUR_VPS_IPv6 | DNS only (grey cloud) |

> ⚠️ **Important**: Use "DNS only" (grey cloud), not "Proxied" (orange cloud). Cloudflare's proxy interferes with DoH/DoT and serves its own certificate.

---

## Part 6: Testing

### Test Web UI

```bash
curl -I https://dns.yourdomain.com
```

Expected: `HTTP/2 200`

### Test DoH Endpoint

> ⚠️ **Known Issue**: Technitium's DoH only accepts POST requests with binary DNS messages. GET requests with query parameters return a 302 redirect.

**This does NOT work:**
```bash
# GET request returns 302 redirect
curl -H "accept: application/dns-json" "https://dns.yourdomain.com/dns-query?name=google.com&type=A"
```

**This WORKS:**
```bash
# Create binary DNS query
echo -n "AAABAAABAAAAAAAAB2dvb2dsZQNjb20AAAEAAQ" | base64 -d > /tmp/dns-query.bin

# POST request with binary DNS message
curl -X POST \
    -H "content-type: application/dns-message" \
    --data-binary @/tmp/dns-query.bin \
    https://dns.yourdomain.com/dns-query
```

Expected: Binary response (HTTP 200 with `content-type: application/dns-message`)

### Test DoT

```bash
# Using kdig (install: apt install knot-dnsutils)
kdig @dns.yourdomain.com +tls google.com
```

### Test Standard DNS

```bash
dig @dns.yourdomain.com google.com
```

---

## Part 7: Client Configuration

### DoH URL

```
https://dns.yourdomain.com/dns-query
```

### DoT Server

```
dns.yourdomain.com:853
```

### DNS Stamp Generator

For devices that require DNS stamps (like Ubiquiti), use: https://dnscrypt.info/stamps

---

## Troubleshooting

### Port 443 Already in Use

**Symptom:**
```
nginx: [emerg] bind() to 0.0.0.0:443 failed (98: Address already in use)
```

**Cause:** Technitium is using port 443 for its own HTTPS.

**Fix:**
1. Stop both services: `sudo systemctl stop nginx dns`
2. In Technitium UI → Settings → Web Service, change HTTPS port to 8443 or disable HTTPS
3. Start Technitium: `sudo systemctl start dns`
4. Start nginx: `sudo systemctl start nginx`

### DoH Returns 502 Bad Gateway

**Symptom:** `/dns-query` returns 502 error

**Cause:** Technitium's DNS-over-HTTP service isn't running on port 8053.

**Fix:**
1. Check if port 8053 is listening: `sudo ss -tlnp | grep 8053`
2. In Technitium UI → Settings → Optional Protocols, enable "DNS-over-HTTP" on port 8053
3. Restart Technitium

### DoH Returns 302 Redirect

**Symptom:** DoH requests redirect to root URL

**Cause:** Two possible issues:
1. Reverse Proxy Network ACL doesn't include `127.0.0.1`
2. Using GET instead of POST

**Fix:**
1. Add `127.0.0.1` to Reverse Proxy Network ACL in Technitium
2. Use POST requests with binary DNS messages (not GET with query params)

### SSL Certificate Mismatch

**Symptom:**
```
SSL: no alternative certificate subject name matches target host name
```

**Cause:** Certificate doesn't cover the subdomain, or Cloudflare proxy is on.

**Fix:**
1. Verify cert covers the domain: `sudo openssl x509 -in /etc/letsencrypt/live/yourdomain.com/fullchain.pem -text -noout | grep -A1 "Subject Alternative Name"`
2. Ensure Cloudflare DNS record is "DNS only" (grey cloud), not "Proxied"
3. Update nginx config to use correct certificate path

### Testing Locally (Bypass DNS/Cloudflare)

To test nginx directly, bypassing DNS resolution:

```bash
curl -I --resolve dns.yourdomain.com:443:127.0.0.1 https://dns.yourdomain.com
```

---

## Maintenance

### Certificate Renewal

Certificates auto-renew via certbot timer. Test renewal:

```bash
sudo certbot renew --dry-run
```

### Logs

```bash
# Nginx access log
sudo tail -f /var/log/nginx/dns-access.log

# Nginx error log
sudo tail -f /var/log/nginx/dns-error.log

# Technitium logs
ls /etc/dns/logs/
```

### Service Management

```bash
# Restart services
sudo systemctl restart nginx
sudo systemctl restart dns

# Check status
sudo systemctl status nginx
sudo systemctl status dns

# View ports in use
sudo ss -tlnp | grep -E '(nginx|dotnet)'
```

---

## Summary

| Service | URL/Port |
|---------|----------|
| Web UI | `https://dns.yourdomain.com` |
| DoH | `https://dns.yourdomain.com/dns-query` (POST only) |
| DoT | `dns.yourdomain.com:853` |
| DNS | `dns.yourdomain.com:53` |

---

## References

- [Technitium DNS Server Documentation](https://technitium.com/dns/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Certbot Cloudflare Plugin](https://certbot-dns-cloudflare.readthedocs.io/)
- [DNS Stamp Generator](https://dnscrypt.info/stamps)

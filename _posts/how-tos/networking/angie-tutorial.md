---
title: Angie Set-up Guide
date: 2025-12-31 00:00:00 -0700
categories:
  - how-to
tags:
  - linux
  - networking
  - proxy
---

# Angie Web Server Tutorial: Installation & ACME Configuration

## Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
  - [Debian/Ubuntu](#debianubuntu)
  - [Fedora](#fedora)
  - [Arch Linux](#arch-linux)
  - [macOS](#macos)
- [Basic Configuration](#basic-configuration)
- [ACME Setup for Automatic SSL/TLS](#acme-setup-for-automatic-ssltls)
  - [HTTP-01 Challenge](#http-01-challenge-recommended)
  - [DNS-01 Challenge](#dns-01-challenge)
  - [ALPN Challenge](#alpn-challenge)
- [Advanced ACME Features](#advanced-acme-features)
- [Troubleshooting](#troubleshooting)
- [Migration from nginx](#migration-from-nginx)

---

## Introduction

**Angie** (pronounced /ˈendʒi/) is a high-performance web server forked from nginx by former core nginx developers. It serves as a drop-in replacement for nginx with several enhancements:

- **Built-in ACME module** for automatic SSL/TLS certificate management (no Certbot needed!)
- HTTP/3 support for both client and proxy connections
- RESTful API for server monitoring and metrics
- Prometheus-compatible statistics export
- Enhanced configuration flexibility
- Active development by the original nginx team members

### Why Angie for Kubernetes?

While nginx has become deprecated in some Kubernetes deployments, Angie offers:
- Native ACME support without sidecars or init containers
- Better integration with modern cloud-native architectures
- Active maintenance and feature development

---

## Installation

### Debian/Ubuntu

#### Step 1: Add the Angie Repository

```bash
# Add the repository to sources list
echo "deb https://download.angie.software/angie/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/ $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/angie.list > /dev/null
```

#### Step 2: Add GPG Key

```bash
# Download and add the signing key
sudo curl -o /etc/apt/trusted.gpg.d/angie-signing.gpg \
https://angie.software/keys/angie-signing.gpg
```

#### Step 3: Install Angie

```bash
# Update package list
sudo apt update

# Install Angie
sudo apt install -y angie
```

#### Step 4: Start and Enable Service

```bash
# Start the service
sudo systemctl start angie

# Enable to start on boot
sudo systemctl enable angie

# Check status
sudo systemctl status angie
```

#### Verify Installation

```bash
# Check version
angie -v

# Test configuration
sudo angie -t
```

---

### Fedora

**Note**: Fedora uses `dnf` as its package manager (since Fedora 22). If you see documentation mentioning `yum`, replace it with `dnf`.

**Important**: Repository configuration files are still stored in `/etc/yum.repos.d/` even though Fedora uses `dnf`. This is for backward compatibility and is completely normal.

#### Step 1: Add the Angie Repository

**Method 1: Official Angie Repository**

```bash
# Create repository file
sudo tee /etc/yum.repos.d/angie.repo > /dev/null <<EOF
[angie]
name=Angie repo
baseurl=https://download.angie.software/angie/fedora/\$releasever/
gpgcheck=1
enabled=1
gpgkey=https://angie.software/keys/angie-signing.gpg.asc
EOF
```

**Method 2: GetPageSpeed Repository** (recommended for production - includes SELinux-compatible packages)

```bash
# Install GetPageSpeed repository
sudo dnf install -y https://extras.getpagespeed.com/release-latest.rpm

# Install dnf-plugins-core if not already installed
sudo dnf install -y dnf-plugins-core

# Enable the Angie repository
sudo dnf config-manager --enable getpagespeed-extras-angie
```

#### Step 2: Install Angie

```bash
# Update repository metadata
sudo dnf check-update

# Install Angie
sudo dnf install -y angie
```

#### Step 3: Configure Firewall

```bash
# Allow HTTP and HTTPS traffic
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

#### Step 4: Start and Enable Service

```bash
# Start the service
sudo systemctl start angie

# Enable to start on boot
sudo systemctl enable angie

# Check status
sudo systemctl status angie
```

---

### Arch Linux

Angie is available in the AUR (Arch User Repository). You can install it using an AUR helper like `yay` or manually.

#### Method 1: Using yay (Recommended)

First, ensure you have `yay` installed. If not:

```bash
# Install base-devel and git
sudo pacman -S --needed base-devel git

# Clone yay repository
git clone https://aur.archlinux.org/yay.git
cd yay

# Build and install yay
makepkg -si
```

Now install Angie:

```bash
# Install Angie from AUR
yay -S angie

# Or use the binary package version
yay -S angie-bin
```

#### Method 2: Manual Installation from AUR

```bash
# Ensure base-devel is installed
sudo pacman -S --needed base-devel git

# Clone the Angie AUR package
git clone https://aur.archlinux.org/angie.git
cd angie

# Review the PKGBUILD (IMPORTANT: always check before building)
less PKGBUILD

# Build and install
makepkg -si
```

#### Start and Enable Service

```bash
# Start the service
sudo systemctl start angie

# Enable to start on boot
sudo systemctl enable angie

# Check status
sudo systemctl status angie
```

**Note**: The Angie package creates compatibility symlinks so you can use either `angie` or `nginx` commands.

---

### macOS

Currently, there are no official Angie packages for macOS. However, you have several options:

#### Option 1: Build from Source

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install openssl pcre2 zlib

# Clone Angie repository
git clone https://github.com/webserver-llc/angie.git
cd angie

# Configure build
./configure \
  --prefix=/usr/local/angie \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-http_v3_module \
  --with-http_acme_module \
  --with-openssl=/usr/local/opt/openssl@3 \
  --with-pcre2 \
  --with-cc-opt="-I/usr/local/opt/openssl@3/include" \
  --with-ld-opt="-L/usr/local/opt/openssl@3/lib"

# Build and install
make
sudo make install
```

#### Option 2: Use Docker

```bash
# Pull the latest Angie image
docker pull docker.angie.software/angie:latest

# Run Angie container
docker run -d \
  --name angie \
  -p 80:80 \
  -p 443:443 \
  -v $(pwd)/angie.conf:/etc/angie/angie.conf:ro \
  docker.angie.software/angie:latest
```

#### Option 3: Use nginx with ACME Module (Temporary Alternative)

Since Angie isn't officially packaged for macOS yet, you might consider using nginx with the ACME module for development:

```bash
# Install nginx with ACME support (when available)
# Or use acme.sh with nginx as an alternative
brew install nginx
```

---

## Basic Configuration

### Configuration Files

Angie uses the same configuration structure as nginx:

- **Main config**: `/etc/angie/angie.conf`
- **Site configs**: `/etc/angie/conf.d/*.conf`
- **Logs**: `/var/log/angie/`

### Basic Server Block

Create a simple configuration file:

```bash
sudo nano /etc/angie/conf.d/example.conf
```

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    
    root /var/www/example.com;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    access_log /var/log/angie/example.com-access.log;
    error_log /var/log/angie/example.com-error.log;
}
```

Test and reload:

```bash
# Test configuration
sudo angie -t

# Reload if successful
sudo systemctl reload angie
```

---

## ACME Setup for Automatic SSL/TLS

This is where Angie shines! The built-in ACME module eliminates the need for Certbot or similar tools.

### Prerequisites

1. Domain name pointing to your server
2. Port 80 and 443 accessible
3. DNS configured correctly

### Main Configuration Setup

Edit the main config file:

```bash
sudo nano /etc/angie/angie.conf
```

Add resolver (required for ACME):

```nginx
http {
    # DNS resolver (use your preferred DNS server)
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    
    # ACME shared memory zone
    acme_shared_zone zone=acme:10m;
    
    # Define ACME client
    acme_client letsencrypt {
        directory https://acme-v02.api.letsencrypt.org/directory;
        
        # For testing, use staging:
        # directory https://acme-staging-v02.api.letsencrypt.org/directory;
        
        account_key /var/lib/angie/acme/account.key auto;
        challenge http;
        contact mailto:admin@example.com;
    }
    
    # Include site configs
    include /etc/angie/conf.d/*.conf;
}
```

---

### HTTP-01 Challenge (Recommended)

This is the most common and easiest method. It requires port 80 to be accessible.

#### Step 1: Create the ACME Configuration

```bash
sudo nano /etc/angie/conf.d/example.com.conf
```

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    
    # ACME challenge handling (required for HTTP-01)
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    # ACME certificate configuration
    acme_certificate letsencrypt;
    
    # SSL certificate paths (using ACME variables)
    ssl_certificate $acme_certificate;
    ssl_certificate_key $acme_certificate_key;
    
    # Optional: Cache certificates in memory
    ssl_certificate_cache max=2;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Your website configuration
    root /var/www/example.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### Step 2: Test and Reload

```bash
# Test configuration
sudo angie -t

# Reload Angie
sudo systemctl reload angie
```

Angie will automatically:
1. Request a certificate from Let's Encrypt
2. Handle the HTTP-01 challenge
3. Install the certificate
4. Auto-renew before expiration

#### Step 3: Verify Certificate

```bash
# Check certificate
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates
```

---

### DNS-01 Challenge

DNS challenge is useful for wildcard certificates or when port 80 is not available.

#### Configuration

```nginx
http {
    resolver 8.8.8.8;
    
    acme_shared_zone zone=acme:10m;
    acme_dns_port 8053;  # Port for DNS validation
    
    acme_client letsencrypt {
        directory https://acme-v02.api.letsencrypt.org/directory;
        account_key /var/lib/angie/acme/account.key auto;
        challenge dns;
        contact mailto:admin@example.com;
    }
}

server {
    listen 443 ssl http2;
    server_name *.example.com example.com;
    
    acme_certificate letsencrypt;
    ssl_certificate $acme_certificate;
    ssl_certificate_key $acme_certificate_key;
    
    # Rest of configuration...
}
```

**Note**: DNS challenge requires you to configure your DNS provider to respond to ACME validation requests. This typically involves setting up a DNS server or using an external validation hook.

---

### ALPN Challenge

ALPN (Application-Layer Protocol Negotiation) challenge works over TLS on port 443.

#### Configuration

```nginx
http {
    resolver 8.8.8.8;
    acme_shared_zone zone=acme:10m;
    
    acme_client letsencrypt {
        directory https://acme-v02.api.letsencrypt.org/directory;
        account_key /var/lib/angie/acme/account.key auto;
        challenge alpn;
        contact mailto:admin@example.com;
    }
}

server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    acme_certificate letsencrypt;
    ssl_certificate $acme_certificate;
    ssl_certificate_key $acme_certificate_key;
    
    # Configuration continues...
}
```

---

## Advanced ACME Features

### Multiple Domains with One Certificate

```nginx
server {
    listen 443 ssl http2;
    server_name example.com www.example.com blog.example.com;
    
    acme_certificate letsencrypt;
    ssl_certificate $acme_certificate;
    ssl_certificate_key $acme_certificate_key;
    
    # Single certificate will cover all domains
}
```

### Using Staging Environment for Testing

```nginx
acme_client letsencrypt-staging {
    directory https://acme-staging-v02.api.letsencrypt.org/directory;
    account_key /var/lib/angie/acme/staging-account.key auto;
    challenge http;
    contact mailto:admin@example.com;
}

server {
    listen 443 ssl;
    server_name test.example.com;
    
    # Use staging client for testing
    acme_certificate letsencrypt-staging;
    ssl_certificate $acme_certificate;
    ssl_certificate_key $acme_certificate_key;
}
```

### Custom ACME Hooks

For advanced DNS or HTTP validation:

```nginx
http {
    acme_client letsencrypt {
        directory https://acme-v02.api.letsencrypt.org/directory;
        account_key /var/lib/angie/acme/account.key auto;
        challenge http;
        contact mailto:admin@example.com;
    }
    
    # Define hook for external validation
    location ~ ^/acme_hook/(?<hook_name>[^/]+)$ {
        acme_hook example uri=/acme_hook/$acme_hook_name?domain=$acme_hook_domain&key=$acme_hook_keyauth;
        fastcgi_pass unix:/var/run/acme-handler.sock;
    }
}
```

### Monitoring ACME Status

Angie exposes ACME status through its API:

```nginx
server {
    listen 127.0.0.1:8080;
    
    location /api {
        api /api;
        allow 127.0.0.1;
        deny all;
    }
}
```

Check ACME status:

```bash
curl http://127.0.0.1:8080/api/acme/clients
```

---

## Troubleshooting

### Check ACME Logs

```bash
# View Angie error log
sudo tail -f /var/log/angie/error.log

# For more detail, enable debug logging
sudo nano /etc/angie/angie.conf
```

Add debug directive:

```nginx
error_log /var/log/angie/error.log debug;
```

### Common Issues

#### 1. Certificate Not Issued

**Symptoms**: Site shows nginx default page or certificate errors

**Solutions**:
```bash
# Check if ACME module is loaded
angie -V 2>&1 | grep acme

# Verify domain DNS
dig example.com

# Check port 80 accessibility
sudo netstat -tlnp | grep :80

# Review debug logs
sudo grep -i acme /var/log/angie/error.log
```

#### 2. HTTP-01 Challenge Fails

**Symptoms**: ACME validation errors in logs

**Solutions**:
- Ensure port 80 is open and accessible from the internet
- Check firewall rules
- Verify no other service is using port 80
- Ensure DNS points to correct IP

```bash
# Test from external location
curl -I http://example.com/.well-known/acme-challenge/test
```

#### 3. Rate Limiting

Let's Encrypt has rate limits. If you hit them:

```nginx
# Use staging environment for testing
acme_client letsencrypt-staging {
    directory https://acme-staging-v02.api.letsencrypt.org/directory;
    # ...
}
```

#### 4. Certificate Not Renewing

Angie automatically renews certificates. Check:

```bash
# Verify certificate expiry
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates

# Check ACME client status
sudo ls -lah /var/lib/angie/acme/

# Force reload to trigger renewal check
sudo systemctl reload angie
```

### Debug Mode

Enable comprehensive debugging:

```nginx
error_log /var/log/angie/error.log debug;

# Check specific ACME events
grep "acme" /var/log/angie/error.log
```

---

## Migration from nginx

Angie is designed as a drop-in replacement for nginx. Migration is straightforward:

### Step 1: Backup Current Configuration

```bash
# Backup nginx configuration
sudo cp -r /etc/nginx /etc/nginx.backup
sudo tar -czf nginx-backup-$(date +%Y%m%d).tar.gz /etc/nginx
```

### Step 2: Install Angie

Follow the installation steps for your distribution above.

### Step 3: Copy Configuration

```bash
# Copy nginx config to angie
sudo cp -r /etc/nginx/* /etc/angie/

# Update any hardcoded paths
sudo sed -i 's/\/etc\/nginx/\/etc\/angie/g' /etc/angie/angie.conf
sudo sed -i 's/\/var\/log\/nginx/\/var\/log\/angie/g' /etc/angie/angie.conf
```

### Step 4: Update ACME Configuration

If you're using Certbot, replace it with Angie's built-in ACME:

```nginx
# Old Certbot config
# ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

# New Angie ACME config
acme_certificate letsencrypt;
ssl_certificate $acme_certificate;
ssl_certificate_key $acme_certificate_key;
```

### Step 5: Test Configuration

```bash
# Test Angie configuration
sudo angie -t

# If successful, stop nginx and start angie
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo systemctl start angie
sudo systemctl enable angie
```

### Step 6: Remove Old Certbot (Optional)

```bash
# Stop certbot renewal timer
sudo systemctl stop certbot.timer
sudo systemctl disable certbot.timer

# Remove certbot (optional)
sudo apt remove certbot  # Debian/Ubuntu
sudo dnf remove certbot  # Fedora
sudo pacman -R certbot   # Arch Linux
```

### Compatibility Notes

- Most nginx directives work as-is in Angie
- Third-party nginx modules may require recompilation for Angie
- Check Angie documentation for new features and enhancements

---

## Additional Resources

- **Official Documentation**: https://en.angie.software/angie/docs/
- **ACME Module Docs**: https://en.angie.software/angie/docs/configuration/modules/http/http_acme/
- **ACME Configuration Guide**: https://en.angie.software/angie/docs/configuration/acme/
- **GitHub Repository**: https://github.com/webserver-llc/angie
- **Community Support**: Check the project's GitHub issues

---

## Quick Reference

### Essential Commands

```bash
# Test configuration
sudo angie -t

# Reload configuration
sudo systemctl reload angie

# Restart service
sudo systemctl restart angie

# View logs
sudo tail -f /var/log/angie/error.log
sudo tail -f /var/log/angie/access.log

# Check version and modules
angie -V
```

### File Locations

```
Configuration:    /etc/angie/angie.conf
Site configs:     /etc/angie/conf.d/
ACME data:        /var/lib/angie/acme/
Logs:             /var/log/angie/
PID file:         /var/run/angie.pid
```

---

## Conclusion

Angie provides a modern, feature-rich alternative to nginx with built-in ACME support that eliminates the need for external certificate management tools. The automatic SSL/TLS certificate provisioning and renewal make it an excellent choice for production deployments, especially in containerized and cloud-native environments.

Happy serving! 🚀

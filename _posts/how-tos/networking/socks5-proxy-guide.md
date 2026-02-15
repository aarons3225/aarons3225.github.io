---
title: "SOCKS5 Set-up Guide"
date: 2025-03-14 00:00:00 -0700
categories: how-to
tags:
- linux
- networking
- proxy
---
# SOCKS5 Proxy Complete Guide

## Table of Contents
- [What is a SOCKS5 Proxy?](#what-is-a-socks5-proxy)
- [How SOCKS5 Works](#how-socks5-works)
- [Benefits of SOCKS5](#benefits-of-socks5)
- [SOCKS5 vs Other Proxies](#socks5-vs-other-proxies)
- [Use Cases](#use-cases)
- [Setting Up a SOCKS5 Proxy Server](#setting-up-a-socks5-proxy-server)
- [Client Configuration](#client-configuration)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

---

## What is a SOCKS5 Proxy?

**SOCKS** stands for **Socket Secure**. It's a protocol that routes network packets between a client and server through a proxy server. SOCKS5 is the latest version of the SOCKS protocol.

### Key Characteristics:

- **Protocol-agnostic**: Works with HTTP, HTTPS, FTP, SMTP, torrents, and virtually any TCP/UDP protocol
- **Layer 5 (Session Layer)**: Operates at a lower level than HTTP proxies
- **Transparent**: Applications see the SOCKS proxy as the network gateway
- **Authentication support**: Can require username/password authentication
- **UDP support**: Unlike SOCKS4, SOCKS5 supports UDP traffic (useful for DNS, gaming, VoIP)

### Simple Analogy:

Think of SOCKS5 as a **mail forwarding service**:
- You send packages (network packets) to the forwarding service (SOCKS5 proxy)
- The service forwards them with their return address (proxy's IP)
- Responses come back to the forwarding service, which sends them to you
- The recipient only sees the forwarding service's address, not yours

---

## How SOCKS5 Works

### Connection Flow:

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Your PC   │────────▶│SOCKS5 Proxy │────────▶│ Destination │
│ (Arizona)   │         │(Netherlands)│         │  (Website)  │
└─────────────┘         └─────────────┘         └─────────────┘
     │                        │                        │
     │  1. Connect to proxy   │                        │
     │───────────────────────▶│                        │
     │                        │                        │
     │  2. Send destination   │                        │
     │───────────────────────▶│                        │
     │                        │  3. Connect to site    │
     │                        │───────────────────────▶│
     │                        │                        │
     │                        │  4. Forward data       │
     │                        │◀──────────────────────│
     │  5. Receive data       │                        │
     │◀───────────────────────│                        │
```

### What Happens:

1. **Handshake**: Your client connects to the SOCKS5 proxy and authenticates (if required)
2. **Request**: Your client tells the proxy where to connect (domain or IP + port)
3. **Connection**: The proxy establishes a connection to the destination
4. **Relay**: The proxy relays all traffic between you and the destination
5. **Transparency**: The destination sees the proxy's IP, not yours

---

## Benefits of SOCKS5

### 1. **Protocol Flexibility**
Unlike HTTP proxies that only handle HTTP/HTTPS, SOCKS5 works with:
- Web browsing (HTTP/HTTPS)
- Email (SMTP, IMAP, POP3)
- File transfers (FTP)
- BitTorrent and P2P
- SSH connections
- Gaming traffic
- VoIP and video calls

### 2. **Better Performance**
- **No data interpretation**: SOCKS5 doesn't parse or modify packets (unlike HTTP proxies)
- **Lower overhead**: Simple packet forwarding means less CPU usage
- **UDP support**: Faster for DNS lookups, gaming, streaming

### 3. **Bypassing Restrictions**
- Circumvent geo-blocking (like your Arizona age verification example)
- Access region-locked content
- Bypass firewall restrictions
- Hide your real IP address

### 4. **Authentication Support**
- Username/password protection
- IP whitelisting
- Prevents unauthorized proxy usage

### 5. **Simpler Than VPNs**
- No OS-level configuration needed
- Application-specific (only proxy specific apps)
- Easier to set up and manage
- Less network overhead than VPN tunneling

---

## SOCKS5 vs Other Proxies

### SOCKS5 vs HTTP Proxy

| Feature | SOCKS5 | HTTP Proxy |
|---------|---------|------------|
| **Protocol Support** | Any TCP/UDP | HTTP/HTTPS only |
| **Layer** | Session (Layer 5) | Application (Layer 7) |
| **Speed** | Faster (no parsing) | Slower (interprets HTTP) |
| **UDP Support** | Yes | No |
| **Caching** | No | Yes (can cache web content) |
| **Use Case** | General purpose | Web browsing only |

**When to use HTTP Proxy:**
- Web browsing with caching benefits
- Content filtering needed
- HTTP header modification required

**When to use SOCKS5:**
- Torrenting
- Gaming
- Non-HTTP protocols
- Maximum speed
- Application diversity

### SOCKS5 vs HAProxy

| Feature | SOCKS5 | HAProxy |
|---------|---------|---------|
| **Purpose** | Forward proxy (client-side) | Reverse proxy / Load balancer (server-side) |
| **Direction** | Outbound connections | Inbound connections |
| **Use Case** | Hide client location | Distribute server load |
| **Configuration** | Client configures | Server configures |
| **Protocol** | SOCKS protocol | HTTP, TCP, any protocol |
| **Load Balancing** | No | Yes (primary feature) |

**HAProxy Example:**
```
Multiple Clients ──▶ HAProxy ──▶ Server 1
                             ├──▶ Server 2
                             └──▶ Server 3
```
HAProxy distributes incoming requests across multiple backend servers.

**SOCKS5 Example:**
```
Client ──▶ SOCKS5 Proxy ──▶ Internet
```
SOCKS5 forwards your outbound requests through a different IP.

### SOCKS5 vs VPN

| Feature | SOCKS5 | VPN |
|---------|---------|-----|
| **Encryption** | No (unless tunneled) | Yes (built-in) |
| **Scope** | Per-application | System-wide |
| **Speed** | Faster | Slower (encryption overhead) |
| **Setup Complexity** | Simple | Moderate |
| **Security** | Basic IP masking | Full traffic encryption |
| **DNS Leaks** | Possible | Usually prevented |
| **Use Case** | Speed-critical tasks | Security-critical tasks |

**When to use VPN instead:**
- Need encryption (public WiFi, sensitive data)
- Want all traffic routed
- Need DNS leak protection
- Security is paramount

**When to use SOCKS5 instead:**
- Speed matters (streaming, gaming)
- Only need specific apps proxied
- Simpler setup
- Lower latency requirements

### SOCKS5 vs Squid Proxy

**Squid** is an HTTP caching proxy (similar to HTTP proxy above).

| Feature | SOCKS5 | Squid |
|---------|---------|-------|
| **Caching** | No | Yes (web content) |
| **Protocol** | Any TCP/UDP | HTTP/HTTPS/FTP |
| **Best For** | Torrenting, gaming | Corporate web filtering |
| **Content Filtering** | No | Yes (ACLs, blocking) |
| **Bandwidth Savings** | No | Yes (caching) |

---

## Use Cases

### 1. **Bypassing Geo-Restrictions**
```
You (Arizona) ──▶ SOCKS5 (Netherlands) ──▶ Pornhub
                                            ├─ Sees Netherlands IP
                                            └─ No age verification
```

### 2. **Torrenting Safely**
- Hide your real IP from torrent swarms
- Avoid ISP throttling
- Access region-locked torrents

### 3. **Gaming with Lower Latency**
- Connect to game servers through closer proxy
- Reduce ping times
- Access region-locked game servers

### 4. **Web Scraping**
- Rotate IPs to avoid rate limiting
- Bypass IP-based blocks
- Access geo-restricted data

### 5. **Testing Geo-Specific Content**
- Test how your website looks from different countries
- Verify CDN routing
- Debug location-based features

### 6. **Privacy Enhancement**
- Hide browsing activity from ISP (not encrypted though!)
- Mask IP address from websites
- Combine with HTTPS for better privacy

---

## Setting Up a SOCKS5 Proxy Server

We'll use **Dante**, a popular open-source SOCKS proxy server.

### Prerequisites

- A VPS (like your Hetzner server in Netherlands)
- SSH access with sudo privileges
- Basic firewall knowledge
- Ubuntu/Debian-based system (adaptable to others)

---

### Installation

#### Step 1: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

#### Step 2: Install Dante

```bash
sudo apt install dante-server -y
```

#### Step 3: Verify Installation

```bash
danted -v
```

You should see the Dante version information.

---

### Configuration

#### Step 4: Backup Default Config

```bash
sudo cp /etc/danted.conf /etc/danted.conf.backup
```

#### Step 5: Create Basic Configuration

Open the config file:

```bash
sudo nano /etc/danted.conf
```

**Basic Configuration (No Authentication):**

```conf
# Logging
logoutput: syslog /var/log/danted.log
debug: 0

# Network interfaces
# Replace 'eth0' with your interface name (find with: ip link show)
internal: eth0 port = 1080
external: eth0

# Authentication methods
# 'none' means no authentication required
clientmethod: none
socksmethod: none

# Access control - Allow specific IP
client pass {
    from: YOUR_HOME_IP/32 to: 0.0.0.0/0
    log: connect disconnect error
}

# Allow all outbound connections
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    command: bind connect udpassociate
    log: connect disconnect error
}

# Block everything else
socks block {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect error
}
```

**Replace `YOUR_HOME_IP` with your actual home IP:**

```bash
# Find your home IP
curl ifconfig.me
```

Then replace in the config:
```conf
client pass {
    from: 123.45.67.89/32 to: 0.0.0.0/0
    log: connect disconnect error
}
```

#### Step 6: Configuration with Authentication

For added security, use username/password authentication:

```conf
# Logging
logoutput: syslog /var/log/danted.log

# Network interfaces
internal: eth0 port = 1080
external: eth0

# Authentication methods
# 'username' requires system user authentication
clientmethod: none
socksmethod: username

# Allow connections from anywhere (auth required)
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

# Allow authenticated users
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    command: bind connect udpassociate
    log: connect disconnect error
    socksmethod: username
}

# Block everything else
socks block {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect error
}
```

**Create a SOCKS user:**

```bash
# Create a user without shell access
sudo useradd -r -s /bin/false socksuser

# Set password
sudo passwd socksuser
```

---

### Firewall Configuration

#### Step 7: Allow SOCKS5 Port

**UFW (Ubuntu Firewall):**

```bash
# Check UFW status
sudo ufw status

# Allow SOCKS5 port from your IP only (recommended)
sudo ufw allow from YOUR_HOME_IP to any port 1080

# Or allow from anywhere (less secure)
sudo ufw allow 1080/tcp

# Enable UFW if not already
sudo ufw enable
```

**iptables (alternative):**

```bash
# Allow from specific IP
sudo iptables -A INPUT -p tcp -s YOUR_HOME_IP --dport 1080 -j ACCEPT

# Save rules
sudo netfilter-persistent save
```

---

### Starting the Service

#### Step 8: Start Dante

```bash
# Start the service
sudo systemctl start danted

# Enable on boot
sudo systemctl enable danted

# Check status
sudo systemctl status danted
```

You should see:
```
● danted.service - SOCKS (v4 and v5) proxy daemon (danted)
   Loaded: loaded (/lib/systemd/system/danted.service; enabled)
   Active: active (running)
```

#### Step 9: Verify It's Listening

```bash
# Check if port 1080 is open
sudo ss -tlnp | grep 1080
```

Should show:
```
LISTEN  0  128  0.0.0.0:1080  0.0.0.0:*  users:(("danted",pid=1234,fd=5))
```

---

### Testing the Proxy

#### Step 10: Test from Your Local Machine

**Using curl:**

```bash
# Test without proxy (shows your real IP)
curl ifconfig.me

# Test with SOCKS5 proxy (should show VPS IP)
curl --socks5 YOUR_VPS_IP:1080 ifconfig.me

# With authentication
curl --socks5 socksuser:password@YOUR_VPS_IP:1080 ifconfig.me
```

**Check geolocation:**

```bash
# Your real location
curl https://ipapi.co/json/

# Through proxy (should show Netherlands)
curl --socks5 YOUR_VPS_IP:1080 https://ipapi.co/json/
```

**Test with specific site:**

```bash
# Test the Pornhub scenario
curl --socks5 YOUR_VPS_IP:1080 -I https://www.pornhub.com | grep location
```

---

## Client Configuration

### Firefox

Firefox has built-in SOCKS5 support:

1. Open Firefox Settings
2. Scroll to **Network Settings** → Click "Settings"
3. Select **Manual proxy configuration**
4. Configure:
   - **SOCKS Host:** `YOUR_VPS_IP`
   - **Port:** `1080`
   - **SOCKS v5:** ✓ (checked)
   - **Proxy DNS when using SOCKS v5:** ✓ (checked - important!)

5. Click OK

**Test it:**
- Visit https://ifconfig.me (should show VPS IP)
- Visit https://ipapi.co (should show Netherlands)

### Chrome/Chromium

Chrome uses system proxy settings, but you can launch with specific proxy:

**Linux/Mac:**
```bash
google-chrome --proxy-server="socks5://YOUR_VPS_IP:1080"
```

**Windows:**
```cmd
"C:\Program Files\Google\Chrome\Application\chrome.exe" --proxy-server="socks5://YOUR_VPS_IP:1080"
```

### System-Wide (Linux)

**GNOME/Ubuntu:**
```bash
# Set environment variables
export all_proxy="socks5://YOUR_VPS_IP:1080"
export ALL_PROXY="socks5://YOUR_VPS_IP:1080"

# Add to ~/.bashrc for persistence
echo 'export all_proxy="socks5://YOUR_VPS_IP:1080"' >> ~/.bashrc
```

**KDE/Plasma:**
- System Settings → Network → Proxy
- Select "Manually specify the proxy settings"
- SOCKS Proxy: `YOUR_VPS_IP:1080`

### macOS System-Wide

1. System Preferences → Network
2. Select your connection → Advanced
3. Proxies tab
4. Check **SOCKS Proxy**
5. Server: `YOUR_VPS_IP`
6. Port: `1080`

### Windows System-Wide

1. Settings → Network & Internet → Proxy
2. Manual proxy setup
3. Use a proxy server: **On**
4. Address: `socks5://YOUR_VPS_IP`
5. Port: `1080`

### SSH Tunnel (Alternative)

You can create a SOCKS5 proxy using just SSH:

```bash
# Create SOCKS5 proxy on port 8080
ssh -D 8080 -C -N user@YOUR_VPS_IP

# -D 8080: Dynamic port forwarding (SOCKS5)
# -C: Compression
# -N: Don't execute remote command
```

Then configure your browser to use `localhost:8080` as SOCKS5 proxy.

### Proxychains (Linux)

For CLI tools, use proxychains:

```bash
# Install
sudo apt install proxychains4

# Configure
sudo nano /etc/proxychains4.conf

# Add at the end:
socks5 YOUR_VPS_IP 1080

# Use with any command
proxychains4 curl ifconfig.me
proxychains4 wget https://example.com
proxychains4 ssh user@example.com
```

---

## Security Considerations

### 1. **No Encryption by Default**

SOCKS5 does **NOT encrypt** traffic. Your ISP can still see:
- What websites you visit (unless using HTTPS)
- DNS queries (if not proxied)
- Traffic content (if not using HTTPS)

**Solutions:**
- Always use HTTPS websites
- Enable "Proxy DNS when using SOCKS v5"
- Tunnel SOCKS through SSH for encryption:
  ```bash
  ssh -D 8080 -C -N user@YOUR_VPS_IP
  ```

### 2. **Authentication**

Always use authentication or IP whitelisting:

```conf
# Good: IP whitelist
client pass {
    from: YOUR_IP/32 to: 0.0.0.0/0
}

# Or: Username authentication
socksmethod: username
```

**Never** leave it open to the internet:
```conf
# BAD - Don't do this!
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}
clientmethod: none
```

### 3. **Firewall Rules**

Restrict access to known IPs:

```bash
# Only allow from your home IP
sudo ufw allow from YOUR_HOME_IP to any port 1080

# Block everything else (default)
sudo ufw default deny incoming
```

### 4. **Monitoring**

Watch for abuse:

```bash
# Monitor connections
sudo tail -f /var/log/danted.log

# Check active connections
sudo ss -tnp | grep :1080

# Monitor bandwidth
sudo iftop -i eth0
```

### 5. **Rate Limiting**

Prevent abuse with connection limits:

```conf
# In danted.conf
client pass {
    from: YOUR_IP/32 to: 0.0.0.0/0
    maxconnections: 10
}
```

### 6. **DNS Leaks**

Even with SOCKS5, DNS queries might bypass the proxy:

**Prevention:**
- Enable "Proxy DNS when using SOCKS v5" in Firefox
- Use a DNS server on your VPS
- Test for leaks: https://www.dnsleaktest.com

### 7. **Logging**

Log for security auditing:

```conf
logoutput: syslog /var/log/danted.log
log: connect disconnect error
```

Review logs regularly:
```bash
sudo tail -f /var/log/danted.log
```

---

## Advanced Configuration

### Multiple Users with Different Permissions

```conf
# User 1: Full access
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    socksmethod: username
    user: fulluser
}

# User 2: Limited access (no torrenting ports)
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0 port != 6881-6999
    socksmethod: username
    user: limiteduser
}
```

### Block Specific Destinations

```conf
# Block access to specific sites
socks block {
    from: 0.0.0.0/0 to: evil.com
    log: error
}

# Block Tor exit nodes
socks block {
    from: 0.0.0.0/0 to: TOR_NODE_IP/32
    log: error
}
```

### Bandwidth Limiting

```conf
# Limit bandwidth per user
client pass {
    from: YOUR_IP/32 to: 0.0.0.0/0
    bandwidth: 1024 # KB/s
}
```

### Multiple Listening Ports

```conf
# Port 1080 for general use
internal: eth0 port = 1080

# Port 1081 for authenticated users
internal: eth0 port = 1081
```

---

## Troubleshooting

### Connection Refused

**Symptom:**
```
curl: (7) Failed to connect to VPS_IP port 1080: Connection refused
```

**Solutions:**

1. **Check if Dante is running:**
   ```bash
   sudo systemctl status danted
   ```

2. **Check if port is listening:**
   ```bash
   sudo ss -tlnp | grep 1080
   ```

3. **Check firewall:**
   ```bash
   sudo ufw status
   # Allow port if blocked
   sudo ufw allow from YOUR_IP to any port 1080
   ```

4. **Check Dante config:**
   ```bash
   sudo danted -V  # Verify config syntax
   ```

### Authentication Fails

**Symptom:**
```
curl: (97) No authentication method was acceptable
```

**Solutions:**

1. **Verify user exists:**
   ```bash
   id socksuser
   ```

2. **Check config allows username auth:**
   ```conf
   socksmethod: username
   ```

3. **Test without auth first:**
   ```conf
   socksmethod: none  # Temporarily
   ```

### DNS Not Working

**Symptom:**
- Can access IPs but not domains through proxy

**Solutions:**

1. **Enable DNS proxy in client:**
   - Firefox: Check "Proxy DNS when using SOCKS v5"

2. **Check if UDP is allowed:**
   ```conf
   socks pass {
       protocol: tcp udp  # UDP needed for DNS
   }
   ```

3. **Test DNS resolution:**
   ```bash
   # Should work
   curl --socks5 VPS:1080 https://example.com
   ```

### Slow Performance

**Causes & Solutions:**

1. **VPS location too far:**
   - Use closer VPS
   - Check latency: `ping YOUR_VPS_IP`

2. **Bandwidth limits:**
   - Remove/increase bandwidth limits in config
   - Check VPS bandwidth allocation

3. **DNS lookups slow:**
   - Ensure DNS is proxied through SOCKS5
   - Use faster DNS on VPS

4. **CPU bottleneck:**
   - Check CPU usage: `top`
   - Consider upgrading VPS

### Logs Show Errors

**Check logs:**
```bash
sudo tail -f /var/log/danted.log
sudo journalctl -u danted -f
```

**Common errors:**

1. **"error: unable to find 'internal' interface"**
   - Wrong interface name in config
   - Fix: `ip link show` to find correct name

2. **"error: bind() failed"**
   - Port already in use
   - Fix: Change port or stop conflicting service

3. **"alert: accept() failed"**
   - Too many connections
   - Fix: Increase `maxconnections` in config

---

## Performance Tuning

### Optimize Dante Config

```conf
# Increase connection limits
client pass {
    from: YOUR_IP/32 to: 0.0.0.0/0
    maxconnections: 100
}

# Adjust timeout values
timeout.connect: 30      # seconds
timeout.io: 86400        # 24 hours for long connections
```

### System-Level Tuning

```bash
# Increase file descriptors
sudo nano /etc/security/limits.conf

# Add:
*  soft  nofile  65535
*  hard  nofile  65535

# Increase network buffers
sudo nano /etc/sysctl.conf

# Add:
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Apply changes
sudo sysctl -p
```

---

## Useful Scripts

### Auto-Restart on Failure

Create systemd override:

```bash
sudo systemctl edit danted
```

Add:
```ini
[Service]
Restart=always
RestartSec=10
```

### Monitor Connection Count

```bash
#!/bin/bash
# save as monitor-socks.sh

while true; do
    COUNT=$(sudo ss -tn | grep :1080 | wc -l)
    echo "$(date): $COUNT active connections"
    sleep 60
done
```

### Rotate Logs

```bash
# /etc/logrotate.d/danted
/var/log/danted.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 640 root adm
    sharedscripts
    postrotate
        systemctl reload danted > /dev/null 2>&1 || true
    endscript
}
```

---

## Comparison Summary

| Feature | SOCKS5 | HTTP Proxy | HAProxy | VPN | Squid |
|---------|--------|------------|---------|-----|-------|
| **Protocol Support** | Any TCP/UDP | HTTP/HTTPS | Any | Any | HTTP/HTTPS/FTP |
| **Direction** | Forward | Forward | Reverse | Both | Forward |
| **Encryption** | No | No | No | Yes | No |
| **Speed** | Fast | Medium | Fast | Slow | Medium |
| **Caching** | No | Limited | No | No | Yes |
| **Load Balancing** | No | No | Yes | No | Limited |
| **Setup Difficulty** | Easy | Easy | Medium | Medium | Medium |
| **Best Use** | General proxy | Web only | Load balancing | Security | Corporate filtering |

---

## Additional Resources

### Documentation
- **Dante Manual:** https://www.inet.no/dante/doc/
- **SOCKS5 RFC:** https://www.rfc-editor.org/rfc/rfc1928
- **Testing Tools:** https://www.dnsleaktest.com

### Alternative SOCKS5 Servers
- **Dante** (what we used) - Full-featured, production-ready
- **Shadowsocks** - Lightweight, designed for censorship circumvention
- **Microsocks** - Minimal, under 100KB, no authentication
- **3proxy** - Tiny proxy server supporting SOCKS4/5, HTTP

### SSH SOCKS5 Alternative

If you just need quick SOCKS5 without installing anything:

```bash
# Creates SOCKS5 proxy through SSH
ssh -D 8080 -C -N user@your-vps

# Use localhost:8080 as SOCKS5 proxy in your apps
```

This gives you encrypted SOCKS5 instantly!

---

## Conclusion

SOCKS5 proxies are incredibly versatile tools for:
- Bypassing geo-restrictions (like your Arizona example)
- Privacy enhancement (IP masking)
- Protocol flexibility (torrents, gaming, etc.)
- Testing location-specific features

Combined with your Hetzner VPS running Technitium DNS, you now have:
1. **Custom DNS resolution** (Technitium)
2. **Traffic routing through Netherlands** (SOCKS5)
3. **Complete control** over your network path

This is exactly the kind of setup that makes homelabbing so rewarding - you learn the fundamentals while building practical tools!

---

## Quick Reference Card

```bash
# Start/Stop/Restart
sudo systemctl start danted
sudo systemctl stop danted
sudo systemctl restart danted
sudo systemctl status danted

# Check connections
sudo ss -tnp | grep :1080

# View logs
sudo tail -f /var/log/danted.log

# Test proxy
curl --socks5 VPS_IP:1080 ifconfig.me

# Test with auth
curl --socks5 user:pass@VPS_IP:1080 ifconfig.me

# Firewall
sudo ufw allow from YOUR_IP to any port 1080
sudo ufw status

# Config location
/etc/danted.conf
```

---

**Happy proxying! 🚀**

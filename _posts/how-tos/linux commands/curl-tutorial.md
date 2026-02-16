---
title: 'curl: Guide to Using "curl"'
date: 2024-08-31 00:00:00 -0700
categories:
  - How-To
tags:
  - linux
---
# A Comprehensive Guide to curl

## Background

`curl` (short for "Client URL") is a powerful command-line tool for transferring data to or from servers using various network protocols. Created by Daniel Stenberg in 1997, it has become an essential utility for developers, system administrators, and anyone working with web services.

### What Makes curl Special?

- **Protocol Support**: HTTP, HTTPS, FTP, SFTP, SCP, TFTP, and many more
- **Cross-Platform**: Available on macOS, Windows, Linux, and virtually every Unix-like system
- **Automation-Friendly**: Perfect for scripts, cron jobs, and CI/CD pipelines
- **Powerful**: Supports authentication, cookies, headers, proxies, SSL/TLS, and more
- **Lightweight**: No GUI needed—pure command-line efficiency

## Installation

Most systems come with curl pre-installed. Check if you have it:

```bash
curl --version
```

If not installed:

- **macOS**: Already included, or `brew install curl`
- **Ubuntu/Debian**: `sudo apt install curl`
- **Arch Linux**: `sudo pacman -S curl`
- **Windows**: Included in Windows 10+ or download from [curl.se](https://curl.se)

## Basic Usage

The simplest form of curl is:

```bash
curl [options] [URL]
```

### Common Options

| Option | Purpose |
|--------|---------|
| `-o <file>` | Save output to a file |
| `-O` | Save with the original filename |
| `-L` | Follow redirects |
| `-I` | Fetch headers only |
| `-X <method>` | Specify HTTP method (GET, POST, PUT, DELETE) |
| `-H <header>` | Add custom header |
| `-d <data>` | Send data in POST request |
| `-u <user:pass>` | Authentication credentials |
| `-v` | Verbose mode (useful for debugging) |
| `-s` | Silent mode (no progress bar) |
| `-i` | Include response headers in output |

## Practical Examples

### Example 1: Basic GET Request

Fetch a webpage's content:

```bash
curl https://example.com
```

This displays the HTML content directly in your terminal.

### Example 2: Download a File

Save a file with its original name:

```bash
curl -O https://example.com/file.zip
```

Or specify a custom filename:

```bash
curl -o myfile.zip https://example.com/file.zip
```

### Example 3: Follow Redirects

Many URLs redirect to other locations. Use `-L` to follow them:

```bash
curl -L https://github.com
```

Without `-L`, you'd only see the redirect response instead of the final page.

### Example 4: View Response Headers

Check headers without downloading the full content:

```bash
curl -I https://example.com
```

This shows HTTP status codes, content type, server information, and more.

### Example 5: POST Data to an API

Send JSON data to a REST API:

```bash
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Aaron","role":"IT Consultant"}'
```

Or send form data:

```bash
curl -X POST https://example.com/login \
  -d "username=aaron" \
  -d "password=secretpass"
```

### Example 6: Download with Authentication

Access protected resources:

```bash
curl -u username:password https://example.com/private/file.txt
```

### Example 7: Verbose Debugging

Troubleshoot connection issues:

```bash
curl -v https://example.com
```

This shows the complete request/response cycle, SSL handshake, headers, and more—invaluable for debugging.

### Example 8: Upload a File

Send a file via POST:

```bash
curl -X POST https://example.com/upload \
  -F "file=@/path/to/localfile.txt"
```

### Example 9: Using curl in Scripts

Download and pipe content to other commands:

```bash
# Check if a website is responding
if curl -s -o /dev/null -w "%{http_code}" https://example.com | grep -q "200"; then
  echo "Site is up!"
else
  echo "Site is down!"
fi
```

### Example 10: Rate Limiting and Retries

Implement retry logic for unreliable connections:

```bash
curl --retry 5 --retry-delay 3 https://example.com/data.json
```

## Tips for Homelab Usage

Since you're running a homelab with various services:

- **Test local services**: `curl http://localhost:8080/api/status`
- **Check Docker containers**: `curl http://container-name:port`
- **Monitor APIs**: Use curl in scripts with cron for uptime monitoring
- **Troubleshoot reverse proxies**: `-v` flag helps debug Nginx/Traefik issues
- **Download configs**: Quickly grab dotfiles or scripts from your GitHub

## Next Steps

- Explore `man curl` for the complete manual
- Try `curl --help` for a quick reference
- Experiment with your homelab services
- Combine curl with `jq` for JSON parsing: `curl https://api.example.com | jq`

---

**Remember**: curl is just a client—it follows the server's rules. Understanding HTTP methods, status codes, and headers will make you much more effective with this tool.

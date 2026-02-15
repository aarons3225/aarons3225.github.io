---
title: "Apprise: A Notification Tool"
date: 2025-06-20 00:00:00 -0700
categories: how-to
tags:
- linux
---

# Apprise on macOS: Complete Setup and Configuration Guide

Apprise is a powerful, lightweight Python library and CLI tool that lets you send notifications to over 100 different services using a simple, unified URL syntax. This guide covers installation, configuration, and practical examples for macOS.

---

## Table of Contents

1. [Installation](#installation)
2. [Basic Usage](#basic-usage)
3. [Notification Services Examples](#notification-services-examples)
   - [macOS Desktop Notifications](#macos-desktop-notifications)
   - [Discord](#discord)
   - [Pushover](#pushover)
   - [ntfy](#ntfy)
   - [Gotify](#gotify)
   - [Slack](#slack)
   - [Telegram](#telegram)
4. [Configuration Files](#configuration-files)
5. [Using Apprise in Scripts](#using-apprise-in-scripts)
6. [Python API Usage](#python-api-usage)
7. [Tips and Troubleshooting](#tips-and-troubleshooting)

---

## Installation

### Method 1: Homebrew (Recommended)

```bash
brew install apprise
```

### Method 2: pip

```bash
pip3 install apprise
```

### Method 3: pip with virtual environment

```bash
# Create a virtual environment
python3 -m venv ~/apprise-env

# Activate it
source ~/apprise-env/bin/activate

# Install apprise
pip install apprise
```

### Verify Installation

```bash
apprise --version
```

### Additional Dependency for macOS Desktop Notifications

To use native macOS desktop notifications, you need `terminal-notifier`:

```bash
brew install terminal-notifier
```

---

## Basic Usage

The basic syntax for sending a notification is:

```bash
apprise -t "Title" -b "Body message" "SERVICE_URL"
```

### Common Flags

| Flag | Description |
|------|-------------|
| `-t`, `--title` | Notification title |
| `-b`, `--body` | Notification body/message |
| `-v` | Verbose output |
| `-vv` | Very verbose (debug) output |
| `-c`, `--config` | Path to configuration file |
| `-g`, `--tag` | Filter notifications by tag |
| `-n`, `--notification-type` | Type: `info`, `success`, `warning`, `failure` |
| `-i`, `--input-format` | Input format: `text`, `html`, `markdown` |
| `-a`, `--attach` | Attach a file |

### Quick Test

```bash
# Simple test (will fail gracefully if no valid URL)
apprise -vv -t "Hello" -b "World" "json://localhost"
```

---

## Notification Services Examples

### macOS Desktop Notifications

Native macOS Notification Center alerts. Requires `terminal-notifier`.

**URL Syntax:**
```
macosx://
macosx://_/?sound=default
```

**Examples:**

```bash
# Basic desktop notification
apprise -vv -t "Task Complete" -b "Your backup has finished" \
   "macosx://"

# With sound
apprise -vv -t "Alert!" -b "Something needs attention" \
   "macosx://_/?sound=default"

# With custom sound (use sounds from System Preferences > Sound)
apprise -vv -t "Reminder" -b "Meeting in 5 minutes" \
   "macosx://_/?sound=Ping"
```

**Available Parameters:**

| Parameter | Description |
|-----------|-------------|
| `sound` | Sound name from System Preferences (e.g., `default`, `Ping`, `Basso`) |
| `image` | Associate an image (`yes`/`no`, default: `yes`) |

---

### Discord

Send notifications to Discord channels via webhooks.

**Setup:**
1. Go to your Discord server
2. Click the gear icon (Settings) on your channel
3. Go to **Integrations** → **Webhooks** → **New Webhook**
4. Copy the webhook URL

Your webhook URL looks like:
```
https://discord.com/api/webhooks/1234567890/abcdefghijklmnop
```

This breaks down to:
- **WebhookID**: `1234567890`
- **WebhookToken**: `abcdefghijklmnop`

**URL Syntax:**
```
discord://WebhookID/WebhookToken
discord://BotName@WebhookID/WebhookToken
```

**Examples:**

```bash
# Basic Discord notification
apprise -vv -t "Server Alert" -b "CPU usage is high!" \
   "discord://1234567890/abcdefghijklmnop"

# With custom bot name
apprise -vv -t "Deploy Complete" -b "Version 2.0 is live" \
   "discord://DeployBot@1234567890/abcdefghijklmnop"

# With custom avatar
apprise -vv -t "Backup Status" -b "Backup completed successfully" \
   "discord://1234567890/abcdefghijklmnop?avatar_url=https://example.com/icon.png"

# Using the full Discord URL directly (also works!)
apprise -vv -t "Test" -b "Message" \
   "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

# Ping @everyone
apprise -vv -t "Important" -b "Attention @everyone: Server maintenance tonight" \
   "discord://1234567890/abcdefghijklmnop"

# With markdown formatting
cat << 'EOF' | apprise -vv "discord://1234567890/abcdefghijklmnop?format=markdown"
# Status Update

- **Server**: Online
- **Load**: Normal
- **Uptime**: 99.9%
EOF
```

**Available Parameters:**

| Parameter | Description |
|-----------|-------------|
| `tts` | Text-to-speech (`yes`/`no`, default: `no`) |
| `avatar` | Use notification type avatar (`yes`/`no`, default: `yes`) |
| `avatar_url` | Custom avatar URL |
| `footer` | Include footer (`yes`/`no`, default: `no`) |
| `image` | Include type image (`yes`/`no`, default: `yes`) |
| `format` | `text` or `markdown` |
| `thread` | Thread ID for thread-specific messages |

---

### Pushover

Mobile push notifications for iOS and Android.

**Setup:**
1. Create account at [pushover.net](https://pushover.net)
2. Note your **User Key** from the dashboard
3. Create an Application and get the **API Token**

**URL Syntax:**
```
pover://UserKey@APIToken
pover://UserKey@APIToken/Device
```

**Examples:**

```bash
# Basic notification
apprise -vv -t "Alert" -b "Something happened" \
   "pover://uQiRzpo4DXghDmr9QZgGZN4t@aB3cD4eF5gH6iJ7kL8mN9oP0q"

# High priority
apprise -vv -t "URGENT" -b "Server is down!" \
   "pover://uQiRzpo4DXghDmr9QZgGZN4t@aB3cD4eF5gH6iJ7kL8mN9oP0q?priority=high"

# Emergency priority (repeats until acknowledged)
apprise -vv -t "CRITICAL" -b "Database failure!" \
   "pover://uQiRzpo4DXghDmr9QZgGZN4t@aB3cD4eF5gH6iJ7kL8mN9oP0q?priority=emergency&retry=60&expire=3600"

# With custom sound
apprise -vv -t "New Message" -b "You have mail" \
   "pover://uQiRzpo4DXghDmr9QZgGZN4t@aB3cD4eF5gH6iJ7kL8mN9oP0q?sound=magic"

# To specific device
apprise -vv -t "Test" -b "Device-specific" \
   "pover://uQiRzpo4DXghDmr9QZgGZN4t@aB3cD4eF5gH6iJ7kL8mN9oP0q/iphone"
```

**Available Parameters:**

| Parameter | Description |
|-----------|-------------|
| `priority` | `low`, `moderate`, `normal`, `high`, `emergency` |
| `sound` | `pushover`, `bike`, `bugle`, `cashregister`, `cosmic`, etc. |
| `retry` | Seconds between retries for emergency (min: 30) |
| `expire` | Seconds until emergency stops (max: 10800) |
| `url` | Supplementary URL to include |
| `url_title` | Title for supplementary URL |

---

### ntfy

Self-hosted or public push notification service.

**Setup (Public ntfy.sh):**
No setup needed! Just pick a unique topic name.

**Setup (Self-hosted):**
Deploy your own ntfy server and use your hostname.

**URL Syntax:**
```
ntfy://topic                              # Public ntfy.sh
ntfy://hostname/topic                     # Self-hosted (HTTP)
ntfys://hostname/topic                    # Self-hosted (HTTPS)
ntfy://user:password@hostname/topic       # With authentication
ntfy://:token@hostname/topic              # With access token
```

**Examples:**

```bash
# Public ntfy.sh (pick a unique topic!)
apprise -vv -t "Backup Complete" -b "All files backed up" \
   "ntfy://my-unique-homelab-topic"

# Self-hosted server
apprise -vv -t "Alert" -b "Something happened" \
   "ntfy://ntfy.myserver.com/alerts"

# Self-hosted with HTTPS
apprise -vv -t "Secure Alert" -b "Encrypted notification" \
   "ntfys://ntfy.myserver.com/alerts"

# With authentication (access token)
apprise -vv -t "Private" -b "Authenticated message" \
   "ntfy://:tk_myaccesstoken@ntfy.myserver.com/private-topic"

# With priority
apprise -vv -t "High Priority" -b "Needs attention" \
   "ntfy://my-topic?priority=high"

# With tags (emojis)
apprise -vv -t "Success" -b "Deployment complete" \
   "ntfy://my-topic?tags=white_check_mark,rocket"

# With click action
apprise -vv -t "New Issue" -b "Check GitHub" \
   "ntfy://my-topic?click=https://github.com/myrepo/issues"

# With markdown formatting
apprise -vv -t "Report" -b "# Header\n- Item 1\n- Item 2" \
   "ntfy://my-topic?format=markdown"
```

**Available Parameters:**

| Parameter | Description |
|-----------|-------------|
| `priority` | `min`, `low`, `default`, `high`, `max` |
| `tags` | Comma-separated emoji tags |
| `click` | URL to open on click |
| `attach` | URL of attachment |
| `filename` | Custom filename for attachment |
| `delay` | Delay delivery (e.g., `30m`, `1h`) |
| `email` | Email address for email notification |

---

### Gotify

Self-hosted push notification server.

**Setup:**
1. Deploy Gotify server (Docker or binary)
2. Create an Application in Gotify web UI
3. Copy the application token

**URL Syntax:**
```
gotify://hostname/token
gotifys://hostname/token         # HTTPS
gotify://hostname/path/token     # With custom path
```

**Examples:**

```bash
# Basic notification
apprise -vv -t "Server Status" -b "All systems operational" \
   "gotify://gotify.myserver.com/AaBbCcDdEeFf"

# HTTPS
apprise -vv -t "Secure Alert" -b "Important message" \
   "gotifys://gotify.myserver.com/AaBbCcDdEeFf"

# With priority (1-10)
apprise -vv -t "High Priority" -b "Needs attention" \
   "gotify://gotify.myserver.com/AaBbCcDdEeFf?priority=8"

# With markdown
apprise -vv -t "Report" -b "**Bold** and *italic*" \
   "gotify://gotify.myserver.com/AaBbCcDdEeFf?format=markdown"
```

---

### Slack

Send notifications to Slack channels.

**Setup:**
1. Go to [api.slack.com/apps](https://api.slack.com/apps)
2. Create a new app → Incoming Webhooks
3. Copy the webhook URL

**URL Syntax:**
```
slack://TokenA/TokenB/TokenC
slack://botname@TokenA/TokenB/TokenC
```

From webhook URL: `https://hooks.slack.com/services/T00/B00/XXX`
- TokenA = `T00`
- TokenB = `B00`  
- TokenC = `XXX`

**Examples:**

```bash
# Basic notification
apprise -vv -t "Deploy" -b "Version 2.0 deployed" \
   "slack://T00000000/B00000000/XXXXXXXXXXXXXXXX"

# With custom bot name
apprise -vv -t "Build Status" -b "Build #123 passed" \
   "slack://BuildBot@T00000000/B00000000/XXXXXXXXXXXXXXXX"

# To specific channel
apprise -vv -t "Alert" -b "Check the logs" \
   "slack://T00000000/B00000000/XXXXXXXXXXXXXXXX/#devops"
```

---

### Telegram

Send notifications via Telegram bot.

**Setup:**
1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Create a new bot and get the **Bot Token**
3. Get your **Chat ID** (message your bot, then check `https://api.telegram.org/bot<TOKEN>/getUpdates`)

**URL Syntax:**
```
tgram://BotToken/ChatID
tgram://BotToken/ChatID1/ChatID2
```

**Examples:**

```bash
# Basic notification
apprise -vv -t "Alert" -b "Something happened" \
   "tgram://123456789:ABCdefGHIjklMNOpqrSTUvwxYZ/987654321"

# With markdown
apprise -vv -t "Status" -b "*Bold* and _italic_" \
   "tgram://123456789:ABCdefGHIjklMNOpqrSTUvwxYZ/987654321?format=markdown"

# Silent notification
apprise -vv -t "Info" -b "Non-urgent update" \
   "tgram://123456789:ABCdefGHIjklMNOpqrSTUvwxYZ/987654321?silent=yes"
```

---

## Configuration Files

Instead of specifying URLs on the command line, you can use configuration files.

### YAML Configuration (Recommended)

Create `~/.config/apprise/apprise.yml`:

```yaml
# Apprise Configuration File
version: 1

urls:
  # Desktop notifications (always)
  - macosx://:
      - tag: desktop

  # Discord for general alerts
  - discord://1234567890/abcdefghijklmnop:
      - tag: discord, chat

  # Pushover for mobile
  - pover://userkey@apitoken:
      - tag: mobile, push

  # ntfy for homelab
  - ntfy://ntfy.myserver.com/homelab:
      - tag: homelab

  # High priority alerts (multiple services)
  - pover://userkey@apitoken?priority=high:
      - tag: urgent
  - discord://1234567890/abcdefghijklmnop:
      - tag: urgent
```

### Text Configuration (Simple)

Create `~/.config/apprise/apprise.txt`:

```
# Simple text-based config

# One URL per line
macosx://
discord://1234567890/abcdefghijklmnop
pover://userkey@apitoken

# With tags (prefix with tag=)
ntfy://homelab-alerts tag=homelab
discord://1234567890/abcdefghijklmnop tag=discord,urgent
```

### Using Configuration Files

```bash
# Use default config location
apprise -t "Test" -b "Message"

# Specify config file
apprise -c ~/.config/apprise/apprise.yml -t "Test" -b "Message"

# Filter by tag
apprise -c apprise.yml -g mobile -t "Mobile Only" -b "This goes to mobile"

# Multiple tags (OR logic)
apprise -c apprise.yml -g mobile -g desktop -t "Test" -b "Mobile OR Desktop"

# Multiple tags (AND logic - comma separated)
apprise -c apprise.yml -g "urgent,mobile" -t "Test" -b "Urgent AND Mobile"
```

---

## Using Apprise in Scripts

### Bash Script Examples

**Backup Notification Script:**

```bash
#!/bin/bash
# backup-notify.sh

APPRISE_URL="discord://1234567890/abcdefghijklmnop"
BACKUP_DIR="/path/to/backup"

# Run backup
if rsync -av /data/ "$BACKUP_DIR/"; then
    apprise -t "✅ Backup Complete" \
            -b "Backup to $BACKUP_DIR succeeded at $(date)" \
            -n success \
            "$APPRISE_URL"
else
    apprise -t "❌ Backup Failed" \
            -b "Backup to $BACKUP_DIR failed at $(date)" \
            -n failure \
            "$APPRISE_URL"
fi
```

**System Monitoring Script:**

```bash
#!/bin/bash
# system-monitor.sh

# Notify when disk usage exceeds threshold
THRESHOLD=80
USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    apprise -t "⚠️ Disk Space Warning" \
            -b "Root partition is ${USAGE}% full" \
            -n warning \
            "ntfy://my-homelab-alerts"
fi
```

**Long-Running Process Notification:**

```bash
#!/bin/bash
# Run a long process and notify when done

echo "Starting long process..."

if ./long-running-script.sh; then
    apprise -t "Process Complete" -b "Script finished successfully" \
            "macosx://_/?sound=Glass"
else
    apprise -t "Process Failed" -b "Script exited with error" \
            "macosx://_/?sound=Basso"
fi
```

---

## Python API Usage

### Basic Python Usage

```python
#!/usr/bin/env python3
import apprise

# Create Apprise instance
apobj = apprise.Apprise()

# Add notification services
apobj.add('macosx://')
apobj.add('discord://1234567890/abcdefghijklmnop')
apobj.add('ntfy://my-topic')

# Send notification
apobj.notify(
    title='Hello from Python',
    body='This is a test notification!',
)
```

### With Notification Types

```python
#!/usr/bin/env python3
import apprise

apobj = apprise.Apprise()
apobj.add('discord://1234567890/abcdefghijklmnop')

# Different notification types
apobj.notify(
    title='Success!',
    body='Operation completed',
    notify_type=apprise.NotifyType.SUCCESS
)

apobj.notify(
    title='Warning',
    body='Disk space low',
    notify_type=apprise.NotifyType.WARNING
)

apobj.notify(
    title='Error',
    body='Connection failed',
    notify_type=apprise.NotifyType.FAILURE
)
```

### Using Configuration Files in Python

```python
#!/usr/bin/env python3
import apprise

# Create config object
config = apprise.AppriseConfig()

# Add configuration file
config.add('/path/to/apprise.yml')

# Create Apprise instance with config
apobj = apprise.Apprise()
apobj.add(config)

# Send to specific tags
apobj.notify(
    title='Tagged Notification',
    body='This only goes to services tagged "urgent"',
    tag='urgent'
)
```

### With Attachments

```python
#!/usr/bin/env python3
import apprise

apobj = apprise.Apprise()
apobj.add('discord://1234567890/abcdefghijklmnop')

# Send with attachment
apobj.notify(
    title='Report Ready',
    body='See attached file',
    attach='/path/to/report.pdf'
)
```

---

## Tips and Troubleshooting

### Debugging

Always use `-vv` for verbose output when troubleshooting:

```bash
apprise -vv -t "Test" -b "Debug mode" "ntfy://topic"
```

### Test Your Configuration

```bash
# List supported services
apprise --details

# Test a specific service
apprise -vv -t "Test" -b "Testing..." "SERVICE_URL"
```

### Environment Variables

You can set default URLs via environment variable:

```bash
export APPRISE_URLS="discord://id/token ntfy://topic"

# Now just run without URLs
apprise -t "Test" -b "Message"
```

### Common Issues

1. **macOS notifications not appearing:**
   - Ensure `terminal-notifier` is installed: `brew install terminal-notifier`
   - Check System Preferences → Notifications → terminal-notifier

2. **Discord webhook not working:**
   - Verify the webhook URL is correct
   - Check if the webhook is still active in Discord settings

3. **ntfy authentication failing:**
   - Use access tokens: `ntfy://:token@host/topic`
   - For HTTPS, use `ntfys://` prefix

4. **SSL certificate errors:**
   - Add `?verify=no` to skip verification (not recommended for production)

### Useful Aliases

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Quick desktop notification
alias notify='apprise -t "Task Complete" -b "Done!" "macosx://_/?sound=Glass"'

# Notify with custom message
notify-msg() {
    apprise -t "$1" -b "$2" "macosx://_/?sound=default"
}

# Send to all configured services
alias notify-all='apprise -c ~/.config/apprise/apprise.yml'
```

---

## Quick Reference Card

| Service | URL Format |
|---------|------------|
| macOS Desktop | `macosx://` |
| Discord | `discord://WebhookID/WebhookToken` |
| Pushover | `pover://UserKey@APIToken` |
| ntfy | `ntfy://topic` or `ntfy://host/topic` |
| Gotify | `gotify://host/token` |
| Slack | `slack://TokenA/TokenB/TokenC` |
| Telegram | `tgram://BotToken/ChatID` |
| Email | `mailto://user:pass@gmail.com` |

For the complete list of 100+ supported services, visit:
[https://github.com/caronc/apprise/wiki](https://github.com/caronc/apprise/wiki)

---

*Guide created for Apprise on macOS. For updates and more services, check the official documentation.*

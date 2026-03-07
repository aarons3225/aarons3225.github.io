---
title: How to Install and Configure a Storage Server
date: 2026-03-06T00:00:00-0700
categories: how-to
tags:
  - linux
  - fedora
  - storage
  - nas
---
Table of Contents
1. [Network Attached Storage](#network-attached-storage)
2. [Requirements](#requirements)
3. [Download the OS](#download-the-os)
4. [Install the OS](#install-the-os)
5. [Configure the System](#configure-the-system)
   1. [SSH Access](#ssh-access)
   2. [Configure DNF Package Manager (Optional)](#configure-dnf-package-manager-optional)
   3. [Install Essential Packages](#install-essential-packages)
   4. [Configure Firewall](#configure-firewall)
   5. [Enable Automatic Updates](#enable-automatic-updates)
   6. [Install ZFS](#install-zfs)
6. [Set Up the ZFS Pool](#set-up-the-zfs-pool)
7. [Configure Cockpit (Web UI)](#configure-cockpit-web-ui)
8. [Configure Samba Server](#configure-samba-server)
9. [Configure Samba Shares](#configure-samba-shares)
10. [Configure NFS Shares](#configure-nfs-shares)

# [Network Attached Storage](https://en.wikipedia.org/wiki/Network-attached_storage)

A NAS is basically just a file server attached via the network so devices like phones and laptops can connect to it wirelessly. Other devices attach to it via the network as well. It is not like attaching a USB drive or an external hard drive which would be more similar to a DAS ([Direct Attached Storage](https://en.wikipedia.org/wiki/Direct-attached_storage))

---
## Requirements

1. Computer that has
	1. One drive for OS
	2. SATA ports
	3. Drives for those SATA ports
2. Choose your OS
3. Choose your file system
> For this guide I chose Fedora 43 for the OS and ZFS for the file system.
{: .prompt-info }

---
## Download the OS

Go to [www.fedora.com/downloads](https://www.fedoraproject.org/server/download/) to download the latest version of Fedora. At the time of this guide, Fedora 43 is the latest and I will choose the one for Intel and AMD x86_64 systems, the DVD iso.

Next, depending on your current system, you will need to install the iso onto a usb flashdrive. If you are on Windows, you can use Rufus, or if you are on Mac you can use Balena Etcher. Links are here:
- Windows - [Rufus](https://rufus.ie/en/#download)
- Mac:
	- [Website](https://etcher.balena.io)
	- `brew install --cask balenaetcher`

Once you installed the iso onto the usb drive, plug it into your target computer/server and boot it up. Make sure to enter into the BIOS of your target computer so you can set the boot drive to the usb drive you just plugged in. 

---
## Install the OS

For Fedora, you will enter into the installation screen. Configure the disk you are going to install the OS to, and make sure you set a user with a password. 

You should be able to also set the hostname by going into the Network tab. You can also configure the network settings in this tab. 

| Option                   | Description                                                                  |
| ------------------------ | ---------------------------------------------------------------------------- |
| Keyboard                 | Allows you to set your keyboard preferences (defaults to english)            |
| Installation Source      | Allows you to choose which device you want to install from                   |
| Installation Destination | Allows you to select which drive(s) you want to install the OS on            |
| Language Support         | Allows you to select what languages you want installed                       |
| Software Selection       | Allows you to select how much software you want installed initially          |
| Network & Host Name      | Allows you to configure the network (set static IP) and the hostname         |
| Time & Date              | Allows you to set the time and date if it was not picked up by the installer |
| Root Account             | Allows you to set the root account up with a password                        |
| User Creation            | Allows you to set up a new user with sudo access initially                   |
Once Fedora is installed, it would be a good idea to update the system and reboot:
```sh
sudo dnf upgrade -y
# then
sudo systemctl reboot
```

---
## Configure the System

#### SSH Access

For best practice, setting up key-based authentication is better than using a password. Lets set this up.
###### Step 1. Generate the Key Pair On Your Main Computer

Open up a terminal and generate the SSH key pair:
```sh
ssh-keygen -t ed25519 -C "your-email@example.com"
```
You can accept the defaults by pressing enter, or you can choose to encrypt this file by entering in a password.

> The default on a Mac/Linux machine will place the files in the default location of ~/.ssh/id_ed25519
{: .prompt-info }

This will create two files:
- ~/.ssh/id_ed25519 - Your private key (Don't ever share this)
- ~/.ssh/id_ed25519.pub - Your public key (This is what we will put on the server)

###### Step 2. Copy Your Public Key

Display your public key:

```sh
cat ~/.ssh/id_ed25519.pub
```

Copy the entire output. Should look something like this:

```sh
ssh-ed25519 AAAAC32Nzs24880CSDF23AAAA... your-email@example.com
```

###### Step 3. Add the Key to Your Server

On your target machine (the storage server we are setting up), open a terminal. Create the directory and the authorized_keys file:

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
```

Copy your ssh key into the authorized_keys file, save then exit (Ctrl+X, then Y, then Enter). Now set the permissions:

```sh
chmod 600 ~/.ssh/authorized_keys
```

###### Step 4. Test the Key Authentication

Back on your main machine, ssh into the storage server:

```sh
ssh username@your-server-ip
```

> Optionally you can also start from the storage server terminal. Create keys there with the same command `ssh-keygen -t ed25519 -C "your-email@example.com"` then from your main machine do this command `ssh-copy-id username@your-server-ip`
{: .prompt-info }

> You should now be able to access your storage server via ssh without a password.
{: .prompt-tip }

###### Step 5. Disable Password Authentication

Now that we have successfully been able to ssh into the storage server with a key instead of the password, we can safely disable the password authentication in the ssh settings.

```sh
sudo nano /etc/ssh/sshd_config.d/50-disable-password.conf
```

Then add the following:

```sh
PasswordAuthentication no
```

Now, restart the service to enable the updated setting:

```sh
sudo systemctl restart sshd
```

###### Step 6. Verify Password Login is Disabled

From your main machine try to force a password authentication:

```sh
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no username@your-server-ip
```

You should see this:
```sh
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

#### Configure DNF Package Manager (Optional)

Fedora uses DNF5 for package management. Its configuration lives at `/etc/dnf/dnf.conf`. View the current settings:

```sh
cat /etc/dnf/dnf.conf
```

It is minimal by default, and you can see all available options by using `man`:

```sh
man dnf.conf
```

The most common tweak people add is to set the default install option to "Y" instead of "N":

```sh
sudo nano /etc/dnf/dnf.conf
```

Paste in:

```ini
[main]
defaultyes=True
max_parallel_downloads=10
fastestmirror=True
keepcache=True
```

- `defaultyes=True` - Already set by Fedora, makes "yes" the default for prompts
- `max_parallel_downloads=10` - Download multiple packages simultaneously (default is 3)
- `fastestmirror=True` - Automatically select the fastest mirror
- `keepcache=True` - Keep downloaded packages in cache (useful if you reinstall often, but uses disk space)

#### Install Essential Packages

```sh
sudo dnf install -y \
    curl \
    wget \
    git \
    htop \
    net-tools \
    unzip \
    util-linux-user \
    nano
```

#### Configure Firewall

Fedora uses firewalld instead of UFW. It's zone-based and integrates well with the rest of the system.

```sh
sudo firewall-cmd --state
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=cockpit
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

#### Enable Automatic Updates

```sh
sudo dnf install -y dnf-automatic
```

Edit the configuration:

```sh
sudo nano /etc/dnf/automatic.conf
```

Set these values:

```ini
[commands]
upgrade_type = security
apply_updates = yes
```

Enable and start the timer:

```sh
sudo systemctl enable --now dnf-automatic.timer
```

## Install ZFS

Add the ZFS repository (using Fedora 42 package for compatibility):

```sh
sudo dnf install -y https://zfsonlinux.org/fedora/zfs-release-2-5.fc42.noarch.rpm
```

Install kernel headers (must be installed before ZFS):

```sh
sudo dnf install -y kernel-devel-$(uname -r | awk -F'-' '{print $1}')
```

Install ZFS:

```sh
sudo dnf install -y zfs
```

Load the ZFS kernel module:

```sh
sudo modprobe zfs
```

Enable automatic module loading on boot:

```sh
echo zfs | sudo tee /etc/modules-load.d/zfs.conf
```

Verify ZFS is working:

```sh
zfs version
```

---
## Set Up the ZFS Pool

#### List Devices

To see the available disks use the command *`lsblk`*

Take note of what disks you have available. Example:
```sh
aaron@thor:~$ lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda            8:0    0 232.9G  0 disk
└─md0          9:0    0 232.8G  0 raid1
  ├─md0p1    259:0    0    50G  0 part  /
  └─md0p2    259:1    0 182.8G  0 part  /home
sdb            8:16   0 232.9G  0 disk
└─md0          9:0    0 232.8G  0 raid1
  ├─md0p1    259:0    0    50G  0 part  /
  └─md0p2    259:1    0 182.8G  0 part  /home
zram0        251:0    0   7.6G  0 disk  [SWAP]
```
In my test system, I have two drives already set up. They are listed as `sda` and `sdb`.

> For your setup, you may have the devices listed as sdc, sdd, sde, etc.
{: .prompt-info }

> For more reliable identification, use disk IDs: `ls -la /dev/disk/by-id/`
{: .prompt-info }

#### Wipe Devices

> Make sure to not format your OS drive!
{: .prompt-warning }

Next we will need to wipe these drives to prepare them for installing the file system.
```sh
sudo wipefs --all --force /dev/sda
sudo wipefs --all --force /dev/sdb
```

If the drives were part of a previous ZFS pool, you may also need to clear the ZFS labels:

```sh
sudo zpool labelclear -f /dev/sda
sudo zpool labelclear -f /dev/sdb
```

#### Create the Mirror Pool

```sh
sudo zpool create -m /data data mirror /dev/disk/by-id/... /dev/disk/by-id/...
```

This creates a pool named `data` mounted at `/data`. Replace the device paths with your actual drive paths — use `lsblk` to identify them and make sure you're not formatting your OS drive.

#### Create Datasets

> ZFS datasets are like folders with superpowers. Each can have its own compression, quota, and snapshot settings.
{: .prompt-info }

```sh
sudo zfs create data/media
sudo zfs create data/backups
sudo zfs create data/documents
sudo zfs set compression=lz4 data
```

Your datasets are now available at `/data/media`, `/data/backups`, etc.

#### Verify

```sh
zpool status
zfs list
```

> You should now see your healthy mirror pool and all datasets with compression enabled.
{: .prompt-tip }

#### Auto-Import on Boot

```sh
sudo systemctl enable zfs-import-cache.service
sudo systemctl enable zfs-import-scan.service
sudo systemctl enable zfs-mount.service
sudo systemctl enable zfs.target
```

If your pool doesn't mount automatically after a reboot, you can manually import and mount it:

```sh
sudo zpool import
sudo zpool import data
sudo zfs mount -a
```

#### Basic ZFS Maintenance

```sh
sudo zpool status
zfs list
sudo zfs snapshot data/media@before-upgrade
sudo zfs rollback data/media@before-upgrade
sudo zpool scrub data
```

#### Automate Monthly Scrubs

```sh
sudo nano /etc/systemd/system/zfs-scrub.service
```

```ini
[Unit]
Description=ZFS monthly scrub
After=zfs.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/zpool scrub data
```

```sh
sudo nano /etc/systemd/system/zfs-scrub.timer
```

```ini
[Unit]
Description=Run ZFS scrub monthly

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=timers.target
```

Enable the timer:

```sh
sudo systemctl enable --now zfs-scrub.timer
systemctl list-timers zfs-scrub.timer
```

> The `Persistent=true` option means if the system was off when the timer was supposed to fire, it will run the scrub on the next boot.
{: .prompt-info }

---
## Configure Cockpit (Web UI)

Cockpit is a web-based management interface for Fedora/RHEL systems. It gives you a browser dashboard for monitoring CPU, memory, storage, logs, and services — useful for managing your NAS without always dropping into a terminal.

#### Install Cockpit

Cockpit comes pre-installed on Fedora Server, but if it's missing:

```sh
sudo dnf install -y cockpit
sudo dnf install -y cockpit-storaged
```

#### Enable and Start Cockpit

```sh
sudo systemctl enable --now cockpit.socket
```

#### Firewall

You already added Cockpit to the firewall earlier in this guide. If you skipped that step, add it now:

```sh
sudo firewall-cmd --permanent --add-service=cockpit
sudo firewall-cmd --reload
```

#### Access Cockpit

Open a browser and navigate to:

```
https://your-server-ip:9090
```

> You'll get a self-signed certificate warning on first visit — this is expected. Accept the exception to proceed. You can replace it with a real cert later if desired.
{: .prompt-info }

Log in with your server's Linux username and password.

> You should now see the Cockpit dashboard showing system health, storage, logs, and running services.
{: .prompt-tip }

---
## Configure Samba Server

This section covers setting up Samba *on your NAS* so that other machines (Windows, Mac, Linux) can mount your ZFS datasets as network shares.

#### Install Samba

```sh
sudo dnf install -y samba samba-common samba-client
```

#### Configure Samba

Edit the main config file:

```sh
sudo nano /etc/samba/smb.conf
```

A basic config for sharing your ZFS datasets:

```ini
[global]
   workgroup = WORKGROUP
   server string = NAS Server
   security = user
   map to guest = bad user
   log file = /var/log/samba/%m.log
   max log size = 50

[media]
   path = /data/media
   valid users = aaron
   read only = no
   browsable = yes
   create mask = 0664
   directory mask = 0775

[backups]
   path = /data/backups
   valid users = aaron
   read only = no
   browsable = yes
   create mask = 0660
   directory mask = 0770
```

#### Create a Samba User

Samba maintains its own password database separate from Linux system passwords. Add your user:

```sh
sudo smbpasswd -a aaron
sudo smbpasswd -e aaron
```

#### SELinux — Label the Share Paths

Fedora's SELinux will block Samba from reading your ZFS mount unless you label it correctly:

```sh
sudo setsebool -P samba_export_all_rw on
sudo semanage fcontext -a -t samba_share_t "/data(/.*)?"
sudo restorecon -Rv /data
```

#### Enable and Start Samba

```sh
sudo systemctl enable --now smb nmb
```

#### Open the Firewall

```sh
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --reload
```

#### Verify

From another machine, test that your shares are visible:

```sh
smbclient -L //your-server-ip -U aaron
```

> You should see your shares (`media`, `backups`) listed. Other machines can now mount them using the steps in the Configure Samba Shares section below.
{: .prompt-tip }

---
## Configure Samba Shares

CIFS (Common Internet File System) is the protocol used to mount Windows/Samba shares on Linux. `cifs-utils` is the package that provides this support.

#### Install CIFS

```sh
sudo dnf install cifs-utils
```

#### Basic Mount

```sh
sudo mount -t cifs //SERVER_IP/share_name /mnt/mountpoint -o username=youruser
```

Example:

```sh
sudo mkdir -p /mnt/media
sudo mount -t cifs //192.168.1.10/media /mnt/media -o username=aaron
```

#### Common Mount Options

| Options        | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| username=      | Samba username                                               |
| password=      | Password (best practice to use credentials file instead)     |
| credentials=   | Path to a credentials file (more secure than password)       |
| uid=           | Local user that owns the mount files                         |
| gid=           | Local group that owns the mounted files                      |
| file_mode=0644 | Permissions for files                                        |
| dir_mode=0755  | Permissions for directories                                  |
| vers=3.0       | SMB Protocol version (2.1, 3.0, 3.1.1)                      |
| iocharset=utf8 | Character encoding                                           |
| nopperm        | Skip local permission checks (useful for mixed environments) |

#### Credentials File

Putting your password in `/etc/fstab` or on the command line is a bad idea. Use a credentials file instead:

```sh
sudo nano /etc/samba/credentials/myserver
```

```ini
username=youruser
password=yourpassword
domain=WORKGROUP
```

Set permissions:

```sh
sudo chmod 600 /etc/samba/credentials/myserver
sudo chown root:root /etc/samba/credentials/myserver
```

Mount using the credentials file:

```sh
sudo mount -t cifs //192.168.1.10/media /mnt/media -o credentials=/etc/samba/credentials/myserver
```

Persistent mount via `/etc/fstab`:

```
//192.168.1.10/media  /mnt/media  cifs  credentials=/etc/samba/credentials/myserver,uid=1000,gid=1000,file_mode=0644,dir_mode=0755,_netdev  0  0
```

> The `_netdev` option is important — it tells the system to wait for the network to be up before mounting. Without it, the mount can fail on boot.
{: .prompt-info }

Test your fstab entry without rebooting:

```sh
sudo mount -a
```

#### Fedora-Specific: SELinux Considerations

Fedora ships with **SELinux enforcing** by default. If you're writing to a CIFS mount and getting permission denied errors even though permissions look correct, SELinux may be blocking it.

```sh
sudo ausearch -m avc -ts recent
sudo setsebool -P use_samba_home_dirs on
```

#### Unmounting

```sh
sudo umount /mnt/media
sudo umount -l /mnt/media  # lazy unmount if target is busy
```

#### Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| `mount error(13): Permission denied` | Wrong credentials or guest access disabled | Double-check username/password, verify Samba user exists on server |
| `mount error(115): Operation now in progress` | Network timeout, server unreachable | Check server IP, firewall, Samba service running |
| `mount error(2): No such file or directory` | Share name wrong or doesn't exist | Run `smbclient -L //SERVER_IP -U username` to list available shares |
| Files show as root-owned | Missing `uid`/`gid` options | Add `uid=1000,gid=1000` to mount options |
| Works manually but fails on boot | Missing `_netdev` | Add `_netdev` to fstab options |

You can verify available shares on a server before mounting with:

```sh
smbclient -L //192.168.1.10 -U youruser
```

---
## Configure NFS Shares

#### Install NFS

```sh
sudo dnf install nfs-utils
```

#### Configure the Exports File (Server Side)

The `/etc/exports` file controls what directories your NAS shares out and who can access them.

```sh
sudo nano /etc/exports
```

Basic syntax:

```
/path/to/share    client_ip(options)
```

Example — sharing your ZFS datasets to a specific subnet:

```
/data/media       192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
/data/backups     192.168.1.0/24(rw,sync,no_subtree_check,root_squash)
/data/documents   192.168.1.50(ro,sync,no_subtree_check)
```

Common export options:

| Option             | Description                                                           |
| ------------------ | --------------------------------------------------------------------- |
| `rw`               | Allow read and write                                                  |
| `ro`               | Read only                                                             |
| `sync`             | Write to disk before replying (safer, slightly slower)                |
| `async`            | Reply before writing to disk (faster, slight data-loss risk on crash) |
| `no_subtree_check` | Disables subtree checking — recommended, improves reliability         |
| `root_squash`      | Maps remote root user to anonymous (safer for untrusted clients)      |
| `no_root_squash`   | Lets remote root act as local root (use only on trusted machines)     |
| `all_squash`       | Maps all users to anonymous (most restrictive)                        |
| `anonuid=`         | Sets the UID for anonymous/squashed users                             |
| `anongid=`         | Sets the GID for anonymous/squashed users                             |
| `fsid=0`           | Required for NFSv4 to designate the root export                       |

After editing `/etc/exports`, apply the changes without restarting NFS:

```sh
sudo exportfs -arv
sudo exportfs -v
```

#### Enable and Start NFS Server

```sh
sudo systemctl enable --now nfs-server
```

#### Open the Firewall (Server Side)

```sh
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload
```

> These firewall rules are for running Fedora as an **NFS server**. If you're only mounting shares from another server, you don't need these.
{: .prompt-info }

#### Basic Manual Mount

```sh
sudo mkdir -p /mnt/media
sudo mount -t nfs 192.168.1.10:/srv/media /mnt/media
```

#### Check What a Server is Exporting

```bash
showmount -e 192.168.1.10
```

#### Common Mount Options

| Option    | Description                                             |
| --------- | ------------------------------------------------------- |
| `vers=4.2`| NFS version (prefer 4.1 or 4.2 for modern servers)     |
| `rw`      | Mount read/write (default)                              |
| `ro`      | Mount read-only                                         |
| `hard`    | Retry indefinitely if server goes down (safer for data) |
| `soft`    | Give up after a timeout (faster failure, riskier)       |
| `noatime` | Don't update file access times — improves performance   |
| `_netdev` | Wait for network before mounting (required in fstab)    |

Persistent mount via `/etc/fstab`:

```
192.168.1.10:/srv/media  /mnt/media  nfs  vers=4.2,hard,noatime,_netdev  0  0
```

> Just like CIFS, `_netdev` is critical here — without it the system will try to mount before the network is up and hang or fail at boot.
{: .prompt-info }

Test it:

```sh
sudo mount -a
```

#### NFS Versions — Which to Use?

| Version  | Notes                                                       |
| -------- | ----------------------------------------------------------- |
| NFSv3    | Older, stateless, still widely supported. Use if server is old |
| NFSv4    | Default on modern systems, stateful, better performance     |
| NFSv4.1  | Adds parallel NFS (pNFS) and session improvements           |
| NFSv4.2  | Current best — adds server-side copy, sparse file support   |

#### Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| `mount.nfs: access denied` | Your IP isn't in the server's `/etc/exports` | Add your client IP to the export on the server |
| `mount.nfs: Connection timed out` | Firewall blocking, NFS service not running on server | Check `sudo systemctl status nfs-server` on the server side |
| Files show wrong ownership (nobody/nogroup) | NFSv4 ID mapping issue | Ensure `nfs-idmapd` is running: `sudo systemctl enable --now nfs-idmapd` |
| Mount hangs at boot | Missing `_netdev` in fstab | Add `_netdev` to mount options |

### CIFS vs NFS — Quick Comparison

|                  | CIFS                                       | NFS                              |
| ---------------- | ------------------------------------------ | -------------------------------- |
| **Best for**     | Mixed environments (Windows + Linux + Mac) | Linux-to-Linux                   |
| **Auth method**  | Username/password                          | IP-based (server `/etc/exports`) |
| **Performance**  | Slightly more overhead                     | Generally faster on LAN          |
| **macOS support**| Yes (Finder native)                        | Yes (but CIFS is easier on Mac)  |
| **Windows support** | Native                                  | Needs extra client software      |

---
## References

- Network Attached Storage - [Wikipedia](https://en.wikipedia.org/wiki/Network-attached_storage)
- Direct Attached Storage - [Wikipedia](https://en.wikipedia.org/wiki/Direct-attached_storage)
- You don't need TrueNAS or unRAID! How I setup a pure Linux NAS - TwoGuyzTech - [YouTube](https://www.youtube.com/watch?v=53KSHeiEyc0&list=LL&index=2&t=50s)
- The ULTIMATE Fedora Server Guide - Full Walkthrough (Podman, Cockpit, ZFS) - TechHut - [YouTube](https://www.youtube.com/watch?v=kOEcTGZWiUQ&list=LL&index=2)
- The ULTIMATE Fedora Server Guide - Full Walkthrough (Podman, Cockpit, ZFS) - TechHut - [Article](https://techhut.tv/fedora-server-guide-cockpit-zfs-podman#update-the-system)

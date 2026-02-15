---
title: Sources List Linux
date: 2024-04-21 00:00:00 -500
categories: homelab
tags:
  - homelab
  - linux
---
# About
The sources list is where you add repositories for things. Some popular ones are backports, plex, and other things. 

From Ubuntu Manpage[^1]:
>sources.list
>The source list [/etc/apt/sources.list](file:///etc/apt/sources.list) and the files contained in /etc/apt/sources.list.d/ etc/apt/sources.list.d/ are designed to support any number of active sources and a variety of source media. The files list one source per line (one-line style) or contain multiline stanzas defining one or more sources per stanza (deb822 style), with the most preferred source listed first (in case a single version is available from more than one source). The information available from the configured sources is acquired by **apt-get** **update** (or by an equivalent command from another APT front-end).
  
>sources.list.d 
The [/etc/apt/sources.list.d](file:///etc/apt/sources.list.d) directory provides a way to add sources.list entries in separate files. Two different file formats are allowed as described in the next two sections. Filenames need to have either the extension .list or .sources depending on the contained format. The filenames may only contain letters (a-z and A-Z), digits (0-9), underscore (_), hyphen (-) and period (.) characters. Otherwise APT will print a notice that it has ignored a file, unless that file matches a pattern in the Dir::Ignore-Files-Silently configuration list - in which case it will be silently ignored.

# How To
While in the Linux system, either via ssh or on an actual desktop setup:
```sh
cd /etc/apt/
ls
```

Look for the sources.list file. From there enter:
```sh
sudo nano sources.list
```

Make any modifications and then CTRL + X, Y, and then Enter to exit.

# Popular Repos
Some popular repos to add are as follows:
	Plex[^2]:
		add to sources.list.d
		deb https://downloads.plex.tv/repo/deb/ public main
	Backports[^3]:
		add to sources.list
		deb http://archive.ubuntu.com/ubuntu release-backports main restricted universe multiverse
		deb-src http://archive.ubuntu.com/ubuntu release-backports main restricted universe multiverse
		Replace the "release" with the system OS name, like mantic for Ubuntu 23.10

# Utilization
For an application like Cockpit[^4], it may be necessary to utilize backports repository.
From their website, use:
```sh
. /etc/os-release
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
```

# Citations
[^1]: Ubuntu Manpage: https://manpages.ubuntu.com/manpages/focal/man5/sources.list.5.html
[^2]: Plex Repo: https://support.plex.tv/articles/235974187-enable-repository-updating-for-supported-linux-server-distributions/
[^3]: Backports: https://askubuntu.com/questions/25717/how-do-i-enable-the-backports-repository
[^4]: Cockpit: https://cockpit-project.org/running.html#ubuntu
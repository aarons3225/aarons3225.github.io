---
layout: post
title: Intel Nuc11 Enthusiast Update
date: 2023-11-24 00:00:00 -0500
categories:
  - blog
tags:
  - homelab
  - hardware
  - server
  - ubuntu
---
Today, 11/24/23 I ended up installing Ubuntu Server 23.10 on my Nuc11. So far everything is running how I expected, much better. I have set up ssh which includes going into the /etc/ssh and copying the rsa file to get the key so my mac can access it. I also installed plex and set up the systemd service by creating a plexmediaserver.service file and modifying it so that I can enable the start up on boot. I also mounted my network folders and edited the /etc/fstab file so I can mount all the drives at once with sudo mount -a command. I used docker to install a couple of other services like tautulli (connects to plex and shows what is playing and how) and watchtower (a service that automatically updates docker services).


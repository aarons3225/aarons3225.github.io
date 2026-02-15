---
id: 202602150145
title: Homelab
date: 2026-02-15 01:45:00 -0700
categories: blog
tags:
  - linux
---
# My Linux Journey

## Introduction
I have been a Mac user since 2009. At the time I wasn't even aware that it was similar to linux. I mainly used a Windows computer since '95, and when I was in school, primarily Windows. I got a Mac when I went off to college. I primarily used it for browsing the web, writing homework documents, listening to music, etc. 

## Media (what got me started)
I started collecting my own media library since my first mp3 file. It became more complicated when I finally got into Macs. I tried to find a way to play my media library on my tv as I recognized back then that a hard drive was smaller than my entire DVD library. I tried a Western Digital TV box where you plug a usb drive into it, and it will play the media off the drive. The next step was wireless. 

This is where I discovered Plex. I didn't know what it was at first or how it worked. My technical understanding was not the best. For a while I didn't use it, and instead relied on the connection between Mac and Apple TV using the "My Computer" and sharing access. 

When I finally got into plex, it was an "Ah ha" moment. It's also where I discovered Mac's don't really have a good method to run as a server (they like to fall asleep) and same with Windows. Welcome Linux.

I ended up, after a ton of reading on NASes and other set ups, getting an Intel Nuc 11 Enthusiast. I installed Ubuntu 23.04. I got it all set up (with the help from YouTube tutorials). From there, things spiraled. I got a larger NAS, I got an MS-01 from Minisforum (installed Arch), and started playing with other things like Proxmox. 

## Home Lab

I got into other Operating Systems, trying them out. I tried Ubuntu, Fedora, Nix, Rocky, Debian, and Arch. There were some other flavors based on linux, like TrueNAS. 
My current setup:
> Media
	- Media Nas (HL15) - Rocky linux (came with HL15)
	- Media Server (Nuc) - Arch linux
> Lab
	- Lab (MS-01) - Arch linux (my experiment box but stable)
	- Lab (Zimaboard) - Fedora (experiment box for services I'm unsure about)
> Other storage
	- Document/backup Nas (Qnap) - Proxmox (Stores documents, photos, backups, etc)

Due to the devices running linux, I have had to become more familiar with the command line, both on my Mac and on those devices (via ssh). I have spent countless hours crawling google and reddit and substacks looking for help on issues.

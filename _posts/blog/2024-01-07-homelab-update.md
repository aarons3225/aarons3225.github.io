---
layout: post
title: Homelab Update
date: 2024-02-19 00:00:00 -0500
categories:
  - blog
tags:
  - homelab
  - server
  - ubuntu
  - zimaboard
---
So as of 01/07/24, I have unintalled the Dell R730. It was producing too much heat and causing the office to get too hot. I got an Intel Nuc11 Enthusiast which can be read about above. I pretty much only use it to run Plex and Tautulli. I mounted my drives in the Qnap which is running TrueNAS scale and point the directories to it.

I also got a Zimaboard. I also installed Ubuntu Server on it. I pretty much use it to run almost all of the rest of the services for my media and other things. I bought a domain name and am using Cloudflare Tunnels to connect my services including Plex to my domain name. I attempted to install Organizr bare metal, however, I could not get it to work. I got [Homepage](https://gethomepage.dev/latest/) to work for a short bit, but it stopped and required a terminal to be running. I opted to install [Organizr](https://docs.organizr.app) via docker. Basically Organizr is a home dashboard to manage services with predefined widgets to connect your services to.
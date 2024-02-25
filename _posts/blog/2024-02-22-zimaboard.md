---
layout: post
title: Zimaboard
date: 2024-02-22 02:00:00 -0500
categories:
  - blog
tags:
  - homelab
  - zimaboard
  - server
  - ubuntu
  - self-host
---
![Zimaboard](/assets/img/zimaboard/zimaboard.png)
I got a zimaboard recently. I have played around with it a bit. I was not the biggest fan of CasaOS. I can see the appeal. I just was not prepared to use it as a NAS with storage. I ended up installing Ubuntu Server 23.10 on it. 

I opted for this route to use docker and docker compose. I have a handful of services on it that I both use and am experimenting with. Lately I've been messing around with Traefik and trying to get it to work with more services than just a couple I finally got to run on it. It's also what I used to help me build this site, A huge shout out to TechnoTim. 

So far, I wish I had more of them. I would love to create a cluster for High Availability and migrate my existing containers to kubernetes. I highly recommend the zimaboard for any projects anyone might consider to want to do. 

I at the very least wish I could have a second one so as to play around with proxmox on the second. If it turns out I liked it, I could then recreate my containers on the second one, then install proxmox on the first, then split up the duties. 
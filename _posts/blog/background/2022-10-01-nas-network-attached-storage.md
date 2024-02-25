---
layout: post
title: NAS (Network Attached Storage)
date: 2022-10-01 00:00:00 -0500
categories:
  - blog
tags:
  - homelab
  - hardware
  - network
  - storage
  - NAS
---

# My first NAS…
I started to venture into the NAS world due to the ability to expand and grow outside of the realm of plugging in my hard drive and storing things on that due to slowly running out of room on my 8TB Seagate hard drive. I looked into a few brands including Terramaster, Buffalo, Synology, and Qnap. What sold me on the Qnap was the ability to transcode video for Plex.

# My TVS672XT:
![QNAP TVS672XT](/assets/img/qnap/qnap.jpeg)
I also bought a few 3.5 inch hard drives to begin filling it.

I then found I did not like the interface of the Qnap QUTS Hero OS. I have seen through my trips of the YouTube rabbit hole installing other OS’s, primarily TrueNAS. I ended up getting a couple more drives (some 3.5” and some NVME) and switched the OS.

I quickly realized I would have trouble with moving data on TrueNAS because it would not recognize my external drive (the 8TB). I figured out eventually that I could connect the 8TB to my computer, and use the copy from one folder to the other method, or use rsync. I finally got it to work with data on it.

I found the Plex application on both the QUTS Hero and the TrueNAS were not as robust as I’d hoped. So I started looking around to maybe figure out a solution. I figured splitting up the duties, as this was being used as an all in one solution, might do the trick as I read that NASes are not the best for all in one solutions and to just let a NAS be a NAS.

I ended up getting a Dell R730.


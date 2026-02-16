---
title: Swap.img and disk full fix
date: 2024-03-10 00:00:00 -500
categories:
  - how-to
  - homelab
tags:
  - homelab
  - linux
  - swapimage
  - diskfull
---
# Reason for post
Plex randomly stopped working. I wondered why? It took me a bit to figure out, but I checked my webmin dashboard and saw that my disk was full. Some playing around and I had high swap.img usage and the ubuntu-lvm volume created at startup was full. So here is my fix below. I view this as how to put that particular fire out, I have not figured out how to stop the fire from happening in the first place. 

# Swap Image
---
I have ran into an issue where the swapfile has become full. I have found a fix to it, but it is to resize it. Swap file basically uses ram so if you don't want to keep giving it more and more and more to the point where you need to upgrade the ram, then what I did was basically delete the swap file and make a new one. 

# How
Log in via ssh or open the terminal:
```sh
sudo swapoff -a
sudo rm swap.img
```

Next go to webmin dashboard, http://ipaddress:10000. Go to System/Disk and Network Filesystems. At the bottom is Virtual Memory. Click on it. 

![Webmin 1](/assets/img/webmin/Webmin1.webp)

It should take you to a Edit Mount page. On the mount now? click mount. on the right, make sure swap file is selected. Click save.

![Webmin 2](/assets/img/webmin/Webmin2.webp)

It should bring you to a page to select file size. Edit it, then click save.

You should be able to check the free space with the command:
```sh
free -m
```

# Disk full
---
Open the webmin dashboard, http://ipaddress:10000, then go to Hardware/Logical Volume Management.

![Webmin 3](/assets/img/webmin/Webmin3.webp)

Click on Logical Volumes

![Webmin 4](/assets/img/webmin/Webmin4.webp)

Click on the disk icon labeled ubuntu-lv with a size of disk below label.

![Webmin 5](/assets/img/webmin/Webmin5.webp)

For volume size, modify that to desired size, then click save.

# Citations
---
Webmin: 
1. main: [https://webmin.com](https://webmin.com)
2. downloads: [https://webmin.com/download/](https://webmin.com/download/)

Ploi.io:
1. [https://ploi.io/documentation/server/change-swap-size-in-ubuntu](https://ploi.io/documentation/server/change-swap-size-in-ubuntu)
---
layout: post
title: Introduction to Servarr
date: 2024-02-23 00:00:00 -0500
categories:
  - servarr
tags:
  - homelab
  - servarr
  - self-host
---
![Servarr Icon](https://avatars.githubusercontent.com/u/57051827?s=48&v=4)

# Intro
By no means am I going to reinvent the wheel. This is just a general overview of my current setup. 

I started growing my media library back in the day, and it became a hassle. Especially on a Mac. 

I recently found the arr suite and fell in love. It has everything to help manage your media library broken down by type.

# Servarr

The reason for the name servarr is due to the arr at the end of the services. Prowlarr, Radarr, Lidarr, Sonarr, Readarr, etc.

Prowlarr is an indexer. 
Radarr is for movies.
Sonarr is for tv shows.
Lidarr is for music.
Readarr is for books.

# Data Structure

Your data structure should look like this:
```
|--- /data
|      |---- 1 media
|      |        |_ movies
|      |            |_ Big Buck Bunny
|      |                |_ big.buck.bunny.mp4
|      |        |_ series
|      |            |_ Example 1
|      |                |_ Season 1
|      |                    |_ Example1.s01e01.pilot.mp4
|      |                |_ Season 2
|      |            |_  Example 2
|      |        |_ music
|      |        |_ books
|      |        |_ etc.
|      |---- 2 downloads
```

# Access

In order to allow the services access to your media files, for example to allow radarr to see what movies you currently have, they need the parent folder of movies. All subfolders and files will then be able to be read by the service. Similar thing with sonarr. Sonarr just needs access to series. If you gave Sonarr access to media, then it could see all of movies, series, music, books, etc. 

For more information visit https://wiki.servarr.com
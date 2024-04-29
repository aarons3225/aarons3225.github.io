---
title: Traefik + Authelia
date: 2024-03-05 08:00:00 -500
categories:
  - traefik
tags:
  - homelab
  - self-host
  - network
  - reverse-proxy
  - SSO
---
# A brief overview of Authelia
Authelia is an open-source [authentication](https://www.authelia.com/overview/authentication/introduction/) and [authorization](https://www.authelia.com/overview/authorization/access-control/) server and portal fulfilling the identity and access management (IAM) role of information security in providing [multi-factor authentication](https://www.authelia.com/overview/authentication/introduction/) and single sign-on (SSO) for your applications via a web portal. It acts as a companion for [common reverse proxies](https://www.authelia.com/overview/prologue/supported-proxies/).

# Requirements
- Domain Name (with access to add A records and C records)
- A Linux computer or mac (I used Ubuntu server 23.10 on a zimaboard)
- Docker with docker compose v2
- VS Code or other editor (optional, but helps a ton)
-  Watch Techno Tim's video ([link](https://www.youtube.com/watch?v=u6H-Qwf4nZA))

# Set up
Create the folder where you are going to install the docker compose file if it doesn't already exist, and where to store the app data. In this example for simplicity, It will be installed in /home/username/docker/authelia. From the home directory:

```sh
cd docker
sudo mkdir authelia
cd authelia
sudo mkdir config
cd config
sudo touch configuration.yml
sudo touch users_database.yml
cd ..
sudo touch compose.yml
```

Go to Techno Tim's GitHub Repo with this [link](https://github.com/techno-tim/launchpad/tree/master/docker/authelia). Open up your favorite text editor, I used VS Code. If you have a folder where you store backup configs or other files navigate there, if not just create a few files with the same names above (compose.yml, configuration.yml, users_database.yml). Copy those files in github to their respective files in your editor. Edit them to your liking/needs.

# To generate a hashed password
```sh
$ sudo docker run authelia/authelia:latest authelia hash-password 'yourpassword'
Password hash: $argon2id$v=19$m=65536$3oc26byQuSkQqksq$zM1QiTvVPrMfV6BVLs2t4gM+af5IN7euO0VB6+Q8ZFs
```
This password goes in your user_database.yml file.

When you edit the configuration.yml file, make sure you add each application into the section access_control:
```yml
access_control:
  default_policy: deny
  rules:
    # Rules applied to everyone
    - domain: portainer.odinactual.com
      policy: one_factor
```

# Traefik
Modify your traefik config.yml file. Add authelia to the middlewares sections:
```yml
http:
 #region routers 
  routers:
    portainer:
      entryPoints:
        - "https"
      rule: "Host(`portainer.yourdomain.com`)"
      middlewares:
        - authelia
        - default-headers
        - https-redirectscheme
      tls: {}
      service: portainer
#endregion
#region services
  services:
    portainer:
      loadBalancer:
        servers:
          - url: "https://192.168.0.11:9000"
        passHostHeader: true
#endregion
  middlewares:
    https-redirect:
      redirectScheme:
        scheme: https
    authelia:
      forwardAuth:
        address: "http://authelia:9091/api/verify?rd=https://auth.odinactual.com"
    default-headers:
      headers:
        frameDeny: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 15552000
        customFrameOptionsValue: SAMEORIGIN
        customRequestHeaders:
          X-Forwarded-Proto: https
```
Then add the traefik label to the application (traefik.http.routers.container_name-secure.middlewares=authelia@docker) like so:

```yml
version: '3'

services:
  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /home/aaron/docker/portainer/data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.entrypoints=http"
      - "traefik.http.routers.portainer.rule=Host(`portainer.odinactual.com`)"
      - "traefik.http.middlewares.portainer-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.portainer.middlewares=portainer-https-redirect"
      - "traefik.http.routers.portainer-secure.entrypoints=https"
      - "traefik.http.routers.portainer-secure.rule=Host(`portainer.odinactual.com`)"
      - "traefik.http.routers.portainer-secure.tls=true"
      - "traefik.http.routers.portainer-secure.service=portainer"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.portainer-secure.middlewares=authelia@docker"

networks:
  proxy:
    external: true
```

# Starting up
Start up authelia and restart Traefik and Portainer. Make sure you're in the authelia directory, if unsure, use the command "pwd".  To navigate to home directory, use command cd ~. From home directory:
```sh
cd docker
cd traefik
sudo docker compose up -d --force-recreate
cd ..
cd authelia
sudo docker compose up -d
cd ..
cd portainer
sudo docker compose up -d --force-recreate
```

Everything should be working!


Don't forget to support TechnoTim. He has an online store on the same site as his blog post. 

Citations
--- 

Authelia - https://www.authelia.com

---
Title: # 2 Factor Auth and Single Sign on with Authelia
Author: Timothy Stewart
URL: https://technotim.live/posts/authelia-traefik/
YouTube: https://www.youtube.com/watch?v=u6H-Qwf4nZA
Github:
	authelia: https://github.com/techno-tim/launchpad/tree/master/docker/authelia
	traefik updates: https://github.com/techno-tim/techno-tim.github.io/tree/master/reference_files/authelia-traefik/traefik
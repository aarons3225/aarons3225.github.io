---
title: LunaSea + Traefik + Authelia
date: 2024-03-06 08:00:00 -500
categories:
  - traefik
tags:
  - homelab
  - servarr
  - self-host
  - radarr
  - sonarr
  - lidarr
---
# About LunaSea
LunaSea is an awesome iOS app that allows you to connect to your Radarr, Sonarr, Lidarr, SABnzbd, and Tautulli applications that you can self host. It does so by acting as a remote. You can control your instances too. 

# Download
For the iOS app store link is [here](https://www.lunasea.app/appstore).

# The main issue
The main issue, and what brings me to write this is once I set up Authelia, I could no longer utilize LunaSea. Looking into it, I found that LunaSea does not, at least at the moment offer support for OAuth. So I had to do some playing around. I found a solution, albeit maybe not the best solution. It had to do with my configs. 

I had this set up:
```yml
access_control:
  default_policy: deny
  rules:
    # Rules applied to everyone
    - domain: radarr.odinactual.com
      policy: one_factor
```

# The fix
To fix it, I had to change a few things. Since LunaSea uses the api to make requests, I had to look for and mess with ways to bypass the authentication when using api. Here is my fix:
```yml
access_control:
  default_policy: one_factor
  rules:
    # Rules applied to everyone
    - domain: radarr.odinactual.com
      policy: bypass
	    resources:
	    - '^/api([/?].*)?$'
```

The reason I said this my not be the best solution, is I had to change the default_policy to one_factor from deny. I then had to change the policy for specific domain to bypass, add the resources and the regex for the api. I got it to work, so now if I visit it in a web browser, I can use Authelia to authenticate, but LunaSea can still bypass with api. 

Whoever happens to see this, I hope it helps. If anyone knows of a better way, please let me know. 

---
LunaSea:
	Main: https://www.lunasea.app
	Docs: https://docs.lunasea.app
Authelia:
	Main: https://www.authelia.com
	Docs: https://www.authelia.com/configuration/prologue/introduction/
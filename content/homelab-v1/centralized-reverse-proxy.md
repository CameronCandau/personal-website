---
title: "Centralized Reverse Proxy"
date: 2025-08-16
draft: false
series: ["Homelab v1"]
series_order: 6
---
I'll be reworking my proxy setup, as originally I installed one directly on the [Immich Installation](/homelab-v1/immich-installation/) server. Instead, we want one central reverse proxy which coordinates traffic between all of my application servers.

![](/images/homelab-v1/Pasted%20image%2020250809062314.png)


192.168.100.3

![](/images/homelab-v1/Pasted%20image%2020250809062635.png)

Follow docker instructions to get the latest version available for Ubuntu... the apt repos are a bit outdated for Immich's provided docker-compose configuration.
https://docs.docker.com/engine/install/ubuntu/

`for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done`

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

`sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`

Test installation
`sudo docker run hello-world`


https://youtu.be/Y7Z-RnM77tA?si=jt-6LJ8NDZaq6MxU

I'll make a new container on 192.168.100.10, immich, to be our reverse proxy with https://nginxproxymanager.com/guide/#quick-setup

![](/images/homelab-v1/Pasted%20image%2020250719091053.png)

![](/images/homelab-v1/Pasted%20image%2020250719091717.png)

- Create account on cloudflare, add domain, change nameservers to Cloudflare's if not already
- Get API token for editing DNS on your zone, save in password manager for future certs
- Paste into Nginx Proxy Manager config under SSL tab. 

![](/images/homelab-v1/Pasted%20image%2020250719092255.png)

![](/images/homelab-v1/Pasted%20image%2020250719092707.png)

Now we need to make a record to tell Cloudflare where to point when we visit immich.MYDOMAIN, which will be our Nginx server's internal IP.

![](/images/homelab-v1/Pasted%20image%2020250719093046.png)

This tells cloudflare to resolve any subdomain of my domain to this internal IP. On this internal IP, we'll reach Nginx Proxy Manager, which we've configured to proxy Immich for request to immich.MYDOMAIN


Now we have a valid SSL certificate and hostname!

![](/images/homelab-v1/Pasted%20image%2020250719093441.png)

If I try visiting immich.MYDOMAIN from outside my home network, like my phone which isn't on my home network, it will resolve but not be reachable.... UNTIL I enable my Tailscale VPN client.

![](/images/homelab-v1/2025-08-29_17-59.png)


Now I can download the Immich app from the app store and connect to my instance using this HTTPS URL!

Repeat for other services. So far, just [Jellyfin](/homelab-v1/jellyfin/) and this nginx proxy manager:


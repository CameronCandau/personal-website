---
title: 8 Months Later. The End* of Homelab v2
date: 2026-08-03
series:
  - Homelab v2
series_order: 3
showHero: true
heroStyle: background
---
\*It's not actually the end.

tldr: skip to [[#Summary]]

---
# Retrospective

A lot has changed since my initial posts for v2. Now my Proxmox looks like this:

![[Pasted image 20260803171835.png]]

![[Pasted image 20260803171948.png]]

As I adopted more IaC tooling, I used more AI. AI assistants like Claude Code and Codex have been immensely helpful for getting things up and running, but I also quickly felt that I lost touch with the lab, forgetting details or not learning certain technologies in the first place because they just worked after being set up. I didn't stick to writing manual documentation or blog posts. I wanted infrastructure and I got it, but I wish I learned more. I don't want to use AI to write anything (code, docs, or blog posts, etc) in the next generation.

I did my best to maintain good security and have attempted to audit the code, but for now I'm choosing to keep the source code private except upon request.

All that being said, I'm actually quite happy with the results. I have an IaC homelab which is more robust than I need. I haven't made any commits to my repository, or any major configuration changes in the past 2 months, which is good because I've been busy with other things and don't *always* want to be tinkering with my infrastructure.

I also got to become familiar with a wider variety of technologies overall, which was a lot of fun, and helped me get a sense for what I would keep the same (bold) or do differently (italics) in the next version. 

I've been learning more about Nix and NixOS. The biggest difference for v3 is that it will rely on these technologies extensively. And again, it will not be vibecoded.

Here's a summary of the live state

# Summary
## Infrastructure 
- Same [[content/blog/stable/Homelab/v1/hardware/index|hardware]] as v1
- **Proxmox** Hypervisor
- **OpenTofu** (Terraform) for managing VMs on Proxmox
- **Ansible** for configuring VMs
	- Separate playbooks for bootstrap vs installing/configuring applications
	- Looking forward to using less Ansible and more Nix
- **Backups**
	- **[Restic](https://restic.net/)** -> Backblaze B2 (S3-compatible bucket storage)
		- Ansible inventory defines VMs which should have `/data` backed up, and configures cron jobs and scripts for backing up that data using Restic every night
	- Local backups
		- I've kept a LUKS-encrypted SSD for offline backups. I used the same Ansible group with a separate playbook to copy data from the VMs directly using rsync. Mounting the SSD and starting backups was a manual process.

### Networking
- BIND9 DNS Server
	- Used for internal name resolution
	- Forwards external queries to [Mullvad DOT](https://mullvad.net/en/help/dns-over-https-and-dns-over-tls) for better privacy from ISP with built in content filtering (ad blocking)
	- *Use Terraform to manage zones rather than hardcoding and deploying with Ansible*
	- *Use a different resolver, maybe [numa](https://numa.rs/) or [Technitium](https://technitium.com/dns/)*
- **Traefik** Reverse Proxy for accessing applications via HTTPS
	- LetsEncrypt DNS-01 for automated TLS certificate renewal

## Containerization
- **Kubernetes** ([K3s](https://k3s.io/))
	- Runs Authentik, Miniflux, and Homepage
	- *Admittedly, this exists purely because I wanted to have K3s deployed. Obviously overkill, and didn't learn much because AI managed the configuration. Next time I'll do it myself, and then I'm sure I'll appreciate benefits K3s offers for IaC deployments, even though I likely still won't benefit from the elasticity and high availability that could be achieved.*
## Identity
- **[Zitadel](https://zitadel.com/)**
	- External Identity Provider
	- I set up Tailscale to use OIDC from my Zitadel tenant, so that I can grant access to friends/family by creating them an account and sending an invite without being bound to a single company as my Identity Provider (Tailscale only offers Google, Microsoft, Github, or Apple otherwise)
- **[Authentik](https://goauthentik.io/)** 
	- Internal Identity Provider
	- Federates trust from Zitadel -- users with access Zitadel can access internal services using their same Zitadel credentials
	- WebAuthn/FIDO-2 SSO authentication configured for internal services. Specifically, Immich, Nextcloud, and Kimai
	- Very good, big convenience especially if managing multiple identities across applications, or granting access to other users
	- *Will probably replace with self-hosted Zitadel for better IaC configuration*
	- ![[Pasted image 20260803174230.png]]
## Security
- [Wazuh](https://wazuh.com/)
	- It's deployed and has agents installed on the VMs, but I'm not doing much with it...
	
## User Applications
- [GitLab](https://about.gitlab.com/install/)
	- CI/CD with separate worker VM, for code linting and approval-gated Terraform applies
	- *Pretty heavy and overkill -- probably replace with [Forgejo](https://forgejo.org/)* 
- **[Homepage](https://github.com/gethomepage/homepage)** Service Dashboard
	- ![[Pasted image 20260803180754.png]]
- [Kimai](https://www.kimai.org/en/)
	- Self-hosted time tracker, similar to [Toggl](https://toggl.com/)
	- I really like taking ownership of my time by tracking it. Even moreso, I taking ownership by owning and backing up that data; Kimai has been great.
	- ![[Pasted image 20260803175630.png]]
- **[Miniflux](https://miniflux.app/)** RSS Reader
- **[Navidrome](https://www.navidrome.org/)**
	- Music player for music library (which is included in backups) 
- [Nextcloud](https://nextcloud.com/)
	- Personal cloud suite
	- I entirely replaced my previous Calendar and Contacts solutions with Nextcloud for a few months. No issues but eventually decided to return to the cloud so that if my server unexpectedly goes down, I can continue with my daily life...
	- Used with [Floccus](https://floccus.org/) to sync/backup my browser bookmarks
	- Awesome overall. Theme customization is very fun to have for something like this, especially if you share access with others.
	- *Since I only used it for file storage/backups in the end, going forward I'll probably opt for a more lightweight stack. Proabably SMB/SAMBA or WebDAV + Syncthing for files that need to be synced live between devices.*

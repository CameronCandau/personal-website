---
title: Returning to the Challenge Labs (GPO Abuse and Workflow Optimization)
date: 2026-07-26
series_order: 1
---
- Worked through Challenge Lab 0, Secura, again over the past few days.
- This is the easiest of the labs and wouldn't normally take so long to complete, but I've also been refining my environment and runbooks to address gaps in my workflow.
- Unfortunately I won't be posting writeups for the Challenge Labs, due to OffSec's copyright and academic integrity policies around PEN-200 content.

# GPO Abuse
The Secura lab has an opportunity to abuse GPO. I'm trying to avoid depending on Bloodhound as much, so I'm learning to be more hands-on with enumeration and researching exploitation methods.
- https://specterops.io/blog/2018/02/26/a-red-teamers-guide-to-gpos-and-ous/?gi=abdf7a3d827e#5620
- [BloodyAD](https://github.com/CravateRouge/bloodyAD)
	- Finding writable objects (the GPO)
- [SharpGPOAbuse](https://github.com/ReversecLabs/SharpGPOAbuse)
	- For abusing from Windows
	- The devs don't release binaries, but [SharpCollection](https://github.com/Flangvik/SharpCollection)  has it! (Only recommended for lab environments, of course)
- [pyGPOAbuse](https://github.com/Hackndo/pyGPOAbuse)
	- For abusing from Linux
	- Today I learned that pipx can install Python modules by repo URL, they don't necessarily need to be in PyPI. You can literally just do:
	- `pipx install git+https://github.com/Hackndo/pyGPOAbuse` 
	- `pipx install ssh+https://github.com/Hackndo/pyGPOAbuse`
		- Could be particularly convenient for private repos. [Inspiration](https://documentation.breadnet.co.uk/kb/pipx/pipx-install-from-private-git-repo/)
# Workflow/Productivity
- I've been using these all for at least a few weeks now, but [zoxide](https://github.com/ajeetdsouza/zoxide), [tmux](https://github.com/tmux/tmux), and [direnv](https://github.com/direnv/direnv) have reduced a lot of friction and fatigue when switching between targets in AD labs
- [Pentest-Reference](https://github.com/CameronCandau/Pentest-Reference)
	- Removed a lot of slop that I never used and could easily look up online
	- Now copying content to a page on website at https://cameroncandau.com/pentest/
	- Established personal conventions for HTTP server and reverse shell ports, to be consistent going forward
	- Documented primary and fallback methods for downloading and uploading files
		- Previously I either had many methods documented, or would just randomly pick a different one from memory each time. Just another way to reduce decision fatigue
- Added upload functionality to [Payload-Server](https://github.com/CameronCandau/Payload-Server/commit/2d64626d485c04146ef360a927f17028e8e3b25d), for quickly transferring files back from a target to my host
- Uploaded most of the artifacts I'll need to my ORAS backend to use with [Artifact-Locker](https://github.com/CameronCandau/Artifact-Locker)
	- Having all my scripts and binaries in one place that I can immediately pull down from a fresh Kali VM is awesome. With Payload-Server, it really reduces friction for payload transfers and ensures I'm not scrambling to remember paths or find GitHub repos during the lab.
- Overall, I'm finally feeling pretty satisfied with my tooling, runbooks, and note templates. I'll have to detail some more of these projects in future posts.
- Ending ChatGPT Codex subscription today
	- Feeling a bit uneasy because I think it's really helped me to implement a lot of workflow tooling and optimization, but I also think I consult it more than I should.
	- Trying to ween myself off and focus on my manual work and building foundations, rather than just building more optimizations (maybe I'll expand in a future post).

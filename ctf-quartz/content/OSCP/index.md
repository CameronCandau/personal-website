---
title: OSCP
tags:
  - pentesting
---

# Timeline

- 2025-08-06: Bought exam + lab access
- 2025-08-29: Completed at least 30 boxes from the TJnull/Lain lists
- 2025-08-30: Started PWK course and lab access
- 2025-10-17 to 2025-11-11: Completed PWK Challenge Labs
- Additional Proving Grounds boxes
  - [[DVR4]]
  - [[Image]]
  - [[Lavita]]
  - [[Shenzi]]
  - [[PC]]
  - [[Fired]]
  - [[Press]]
  - [[Scrutiny]]
  - [[RubyDome]]
  - [[Zipper]]
  - [[Flu]]
  - [[Ochima]]
  - [[PyLoader]]
  - [[Plum]]
  - [[SPX]]
  - [[Vault]]
  - [[Nagoya]]
- 2025-11-29: Failed first OSCP attempt
- 2025-11-29 to 2026-04-22: Homelab detour, new job, moving, general life delays
- 2026-04-22: Moved old writeups to Archive and created [[OffSec Proving Grounds Tracking for OSCP]] to redo labs with new notes / methodology
- 2026-06-14: Migrate dotfiles and Kali VM bootstrap from Ansible to Nix: https://github.com/CameronCandau/kali-bootstrap
- 2026-06-22:
  - More life delays without much lab progress
  - Consolidating this content from separate site on https://veilcat.dev to main site on https://cameroncandau.com/ctf

# Summary of Preparation

HTB Academy CBBH 100% -> CPTS 50% -> Proving Grounds Machines -> PEN-200

I completed the CBBH learning path and about half of CPTS on HackTheBox Academy, as I heard these courses cover OSCP's material, and in some cases go into more depth. I didn't take either of the exams, since they aren't widely recognized yet and OSCP has always been my goal. Especially considering their student discount, **HTB Academy has been an effective and affordable way to get started**.

I'm currently working through OffSec's [Proving Grounds Practice](https://www.offsec.com/labs/individual/) Labs, following [TJnull](https://docs.google.com/spreadsheets/u/1/d/1dwSMIAPIam0PuRBkCiDI88pU3yzrqqHkDtBngUHNCw8/htmlview) and [Lain](https://docs.google.com/spreadsheets/d/18weuz_Eeynr6sXFQ87Cd5F0slOj9Z6rt/edit?usp=sharing&ouid=114195388015267391379&rtpof=true&sd=true)'s lists, which I've seen commonly recommended as a starting point.

OffSec's [YouTube playlist](https://youtube.com/playlist?list=PLJrSyRNlZ2EeqkJa12Tu-Ezun9kXvHufN&si=IHKK3LUcgVSUNAyK) with walkthroughs has been great for reinforcing methodology before going into the PWK course material and labs. [S1REN](https://sirensecurity.io/blog/)'s community-led walkthroughs in this playlist and her website are especially valuable.

The "Linux" and "Windows" folders under this page contain my completed Proving Grounds writeups. You'll notice how my methodology and notetaking style has evolved between writeups.

I've watched many YouTube videos from others in the community to learn about experiences in passing/failing.

Finally, the PEN-200 course itself, from OffSec.
OffSec offers a bundle for standalone exam attempts instead of buying PEN-200. Even though it's possible to learn everything required without going through the course, going through the labs in each lesson is a great way to solidify understanding. Further, the challenge labs give additional insight into the exam's format and relative difficulty.

## Notetaking

My methodology and notes template: [OSCP-Methodology](https://github.com/CameronCandau/OSCP-Methodology)

## Workflow Optimization

I vibecoded [OpIndex](https://github.com/CameronCandau/OpIndex) to parse my methodology to have all commands available to fuzzy find, then copy/paste. This was a huge improvement and allowed me to stay in flow state much better. I needed to minimize cognitive overhead from context switching (switching between exploitation to notes, to search for a command, then move my mouse to copy it, then switch back to the other window, paste, and finally modify before pressing enter). We are keyboard-first in this household.

_I'm really excited about this project because it's totally independent of the subject, as it just parses markdown files. It makes it so easy to turn regular notes into an efficient searchable cheat sheet. It really is a general purpose productivity tool, but feels so well suited for IT and security due to the huge number of tools we interact with on a regular basis. I'm excited to improve the tool in the future and publish more cheatsheets for the things I learn.

I also made a few scripts to bootstrap extremely common actions, like starting to enumerate a new target: [OSCP-Automation](https://github.com/CameronCandau/OSCP-Automation).

# References

Really helpful references and cheatsheets:

- hexdump's Youtube videos and cheatsheet: https://github.com/LeonardoE95/OSCP/blob/main/cheatsheet.org#windows-1
- https://www.emmanuelsolis.com/oscp.html
- https://book.hacktricks.wiki/en/index.html
- [Red Team Manual: Services Cheat Sheet](https://docs.google.com/document/d/17W30A0wpB7lVTDb7SCjWs0lb9bMAjVR4B7Dp_c2rU2g/edit?tab=t.0#heading=h.aoia5laf4167)
- [Windows Commands Cheat Sheet](https://docs.google.com/document/d/1CGgADAOZQuMXAyzXVeXRNhQ_PPBYliMXCy-4RNE0UMw/edit?tab=t.0)
- [Linux Commands Cheat Sheet](https://docs.google.com/document/d/1vJxoHrjW607NJDLC1Zln1llrEIqrS6Ea3j9ihJTdblg/edit?tab=t.0#heading=h.daugsj3oqt1)
- [OSCP Secret Sauce - eins.li](https://eins.li/posts/oscp-secret-sauce/) - _UDP scanning, NetExec usage, pspy monitoring_
- [Netexec](https://pentesting.site/cheat-sheets/netexec/)
- [GTFOBins](https://gtfobins.github.io/)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)

---
title: "Git: Finding When a String Changed"
date: 2026-07-27
draft: true
summary: ""
description: ""
tags: []
showHero: false
---
While working on [a nixpkgs PR](https://github.com/NixOS/nixpkgs/pull/530138), I encountered a situation where an environment variable was removed from the upstream program I was trying to package. I wanted to find out exactly when this string was modified in the Git diff history, as there had been many commits since the last time I looked at the repo.

![[content/blog/nightly/Git, finding when a string changed/satty-20260727-233358.png]]

`git log -S"PROTON_DRIVE_UNSAFE_SECRETS"`

...to be continued
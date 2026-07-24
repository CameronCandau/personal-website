---
title: Buffing .bash_history
date: 2026-07-23
---
I found some new Bash config options for making `history` and Ctrl+R more ergonomic and useful.

([Dotfiles commit](https://github.com/CameronCandau/dotfiles/commit/537e8e280a9f8d38420d5ef345eec04fcc082d8b))

I think these options make more sense for working on systems and pentesting as they allow me to see the original order and timing of when I ran commands. If I vaguely remember running a specific tool in the past but didn't make a note, it's already self-documented.

These are all defined in bash(1) (`man bash`).

```bash
# Append to $HISTFILE, don't overwrite
shopt -s histappend

# Increase max length of session history
HISTSIZE=100000
# Increase max length of history file
HISTFILESIZE=200000

# Don't ignore/delete duplicates, just ignore commands starting with space
export HISTCONTROL=ignorespace
# Log when commands were run
HISTTIMEFORMAT='%F %T  '

# Save commands with multiple lines as one history entry
shopt -s cmdhist
shopt -s lithist

# At every prompt, append current session's history to $HISTFILE. Allows all new shells to open with an updated copy of history from all other shells.
PROMPT_COMMAND='history -a'

# Search history by the current line prefix with up/down arrows.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
```

fzf is also a big quality of life improvement to bash's Ctrl+R for me. With Nix Home Manager, this was a simple addition:

```
programs.fzf = {
	enable = true;
	enableBashIntegration = true;
};
```

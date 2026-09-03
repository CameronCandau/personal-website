Summary from existing writeups:
- :80 http directory brute force -> discover /bugtracker -> MantisBT 2.0
- CVE-2017-12419 -> LFI -> read config with hardcoded mysql credentials
- connect to mysql, dump hash of administrator user, crack/crackstation to recover plaintext password
- authenticate to MantisBT as administrator 
- authenticated RCE -> code execution as www-data
- pspy -> mysqldump with password `BugTracker007` password in the clear
- `su mantis` with `BugTracker007`
- `sudo -l` -> root 

Summary from existing writeups:
- wpscan / wp-config.php -> https://www.exploit-db.com/exploits/44340
- LFI redis config, find hardcoded password
- redis-rce.py / redis-rogue-server to get code execution from redis access https://github.com/n0b0dyCN/redis-rogue-server.git
- `ps -aux` shows that apache is running as user alice
- find that /run/redis is writable (`find / -type d -maxdepth 5 -writable 2>/dev/null`)
- write PHP reverse shell, then use the earlier wordpress LFI to run it, gaining code execution as alice
- `/etc/crontab` contains job to run a backup script, which uses tar unsafely with \* wildcard -> abuse wildcard to run arbitrary commands as root when the cron job runs https://medium.com/@cybenfolland/linux-privilege-escalation-wildcards-with-tar-f79ab9e407fa?source=post_page-----88a3e0e21f62---------------------------------------

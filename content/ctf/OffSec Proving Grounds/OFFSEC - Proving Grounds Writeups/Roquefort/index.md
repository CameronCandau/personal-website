Summary from existing writeups:
- gitea on :3000
- create account
- authenticated rce https://github.com/p0dalirius/CVE-2020-14144-GiTea-git-hooks-rce
- write permissions on /usr/local/bin
- find cron job: `*/5 *   * * *   root    cd / && run-parts --report /etc/cron.hourly` which includes 
- write payload to /usr/local/bin/run-parts -> code execution as root
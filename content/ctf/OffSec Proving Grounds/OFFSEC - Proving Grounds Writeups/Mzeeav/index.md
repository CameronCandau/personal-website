Summary from existing writeups:
- :80 HTTP MZEE-AV 2022
- directory brute force -> /backups -> .zip of app source code
- source code reveals that file upload functionality checks for specific magic byte
- upload PHP payload containing required magic byte -> code execution as www-data
- `ls /opt` -> discover `/opt/fileS` which is a copy of `files`, owned by root with SUID bit set -> gtfobins -> root

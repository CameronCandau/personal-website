---
title: "Jellyfin"
date: 2025-08-16
draft: false
series: ["Homelab v1"]
series_order: 5
---

New Ubuntu VM:
- 40GB Storage
- 2 CPU cores 
- 4096 MB RAM
- 150GB attached LVM disk

Networking during installation:
IP: 192.168.100.11
Subnet mask: 192.168.100.0/24
Gateway: 192.168.100.1

Attach storage, as we did in [Immich Installation](/homelab-v1/immich-installation/).

![](/images/homelab-v1/Pasted%20image%2020250808202053.png)

(Reboot)

`lsblk`

```
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   40G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   38G  0 part 
  └─ubuntu--vg-ubuntu--lv 252:0    0   19G  0 lvm  /
sdb                         8:16   0  150G  0 disk 
sr0                        11:0    1    3G  0 rom 
```

`sudo fdisk /dev/sdb`

```
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-314572799, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-314572799, default 314572799): 

Created a new partition 1 of type 'Linux' and of size 150 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

`lsblk`

```
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   40G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   38G  0 part 
  └─ubuntu--vg-ubuntu--lv 252:0    0   19G  0 lvm  /
sdb                         8:16   0  150G  0 disk 
└─sdb1                      8:17   0  150G  0 part 
sr0                        11:0    1    3G  0 rom 
```

`sudo mkdir -p /mnt/jellyfin-data && sudo mount /dev/sdb1 /mnt/jellyfin-data/`

`df -h /mnt/media/`

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb1       147G   28K  140G   1% /mnt/media
```

`sudo bklid /dev/sdb1`

```
/dev/sdb1: UUID="0c9db7f3-d899-423d-ac0d-4314019a1b29" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="ae2cf8da-01"
```

Append into /etc/fstab:
`UUID=0c9db7f3-d899-423d-ac0d-4314019a1b29 /mnt/media ext4 defaults 0 2`

Unmount/remount
```
sudo umount /mnt/media
sudo systemctl daemon-reload
sudo mount -a
```

`lsblk`

```
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   40G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   38G  0 part 
  └─ubuntu--vg-ubuntu--lv 252:0    0   19G  0 lvm  /
sdb                         8:16   0  150G  0 disk 
└─sdb1                      8:17   0  150G  0 part /mnt/jellyfin-data
sr0                        11:0    1    3G  0 rom
```


# Jellyfin Installation

From Jellyfin's installation page for Debian:
https://jellyfin.org/downloads/server

`curl -s https://repo.jellyfin.org/install-debuntu.sh | sudo bash`

After waiting for installation to finish!...

![](/images/homelab-v1/Pasted%20image%2020250808203156.png)

Continue with login, set admin credentials, etc

Create media library for Music, keep all default settings except for changing language and region. Add folder /mnt/media/audio (not shown in screenshot).

![](/images/homelab-v1/Pasted%20image%2020250808203532.png)

## Troubleshooting Notes
Trouble when copying data to the mounted drive via SCP:

`scp -i <ssh_key_path> -r /media/localuser/full_backup/audio/ user@192.168.100.11:/mnt/media`

```
Enter passphrase for key '<ssh_key_path>':
scp: stat remote: No such file or directory
scp: failed to upload directory /media/exis/full_backup/audio to /mnt/media
```

Current owner is probably root, not user, which is why there are permission issues copying as user:
Check this:
```
ls -ld /mnt/media
mount | grep media
```

Change owner to fix:
```
sudo chown user:user /mnt/media
sudo chmod 755 /mnt/media
```


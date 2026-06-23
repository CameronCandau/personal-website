**Secure Shell Protocol**

# Environment Variables / Setup

```
export IP=192.168.159.24
export PORT=22
```

# Phase 1: Service Enumeration

## Nmap SSH Scripts
```
nmap --script=ssh2-enum-algos,ssh-hostkey,ssh-auth-methods -p$PORT $IP
```

```
PORT   STATE SERVICE
22/tcp open  ssh
| ssh-hostkey:
|   256 b9:bc:8f:01:3f:85:5d:f9:5c:d9:fb:b6:15:a0:1e:74 (ECDSA)
|_  256 53:d9:7f:3d:22:8a:fd:57:98:fe:6b:1a:4c:ac:79:67 (ED25519)
| ssh-auth-methods:
|   Supported authentication methods:
|     publickey
|_    password
| ssh2-enum-algos:
|   kex_algorithms: (10)
|       curve25519-sha256
|       curve25519-sha256@libssh.org
|       ecdh-sha2-nistp256
|       ecdh-sha2-nistp384
|       ecdh-sha2-nistp521
|       sntrup761x25519-sha512@openssh.com
|       diffie-hellman-group-exchange-sha256
|       diffie-hellman-group16-sha512
|       diffie-hellman-group18-sha512
|       diffie-hellman-group14-sha256
|   server_host_key_algorithms: (4)
|       rsa-sha2-512
|       rsa-sha2-256
|       ecdsa-sha2-nistp256
|       ssh-ed25519
|   encryption_algorithms: (6)
|       chacha20-poly1305@openssh.com
|       aes128-ctr
|       aes192-ctr
|       aes256-ctr
|       aes128-gcm@openssh.com
|       aes256-gcm@openssh.com
|   mac_algorithms: (10)
|       umac-64-etm@openssh.com
|       umac-128-etm@openssh.com
|       hmac-sha2-256-etm@openssh.com
|       hmac-sha2-512-etm@openssh.com
|       hmac-sha1-etm@openssh.com
|       umac-64@openssh.com
|       umac-128@openssh.com
|       hmac-sha2-256
|       hmac-sha2-512
|       hmac-sha1
|   compression_algorithms: (2)
|       none
|_      zlib@openssh.com
```

## SSH Version and Banner Grabbing
```
ssh -V
telnet $IP $PORT
nc -nv $IP $PORT
```

```
OpenSSH_10.0p2 Debian-7, OpenSSL 3.5.1 1 Jul 2025
Trying 192.168.159.24...
Connected to 192.168.159.24.
Escape character is '^]'.
SSH-2.0-OpenSSH_8.9p1 Ubuntu-3

Invalid SSH identification string.
Connection closed by foreign host.
(UNKNOWN) [192.168.159.24] 22 (ssh) open
SSH-2.0-OpenSSH_8.9p1 Ubuntu-3

Invalid SSH identification string.
```

# Phase 2: Authentication Testing

## Username Enumeration
Some SSH implementations leak valid usernames:

```
# Test common usernames
for user in root admin administrator user test guest; do
    echo "Testing: $user"
    ssh -o PreferredAuthentications=none -o PubkeyAuthentication=no $user@$IP 2>&1 | grep -E "(Permission denied|Authentication failed)"
done
```

(None allowed)

# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Levram/Service Enumeration/8000 HTTP]]

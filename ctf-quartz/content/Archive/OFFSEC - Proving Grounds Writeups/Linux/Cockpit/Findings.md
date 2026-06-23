# Vulnerabilities
The user and password form fields on :80/login.php are vulnerable to error-based SQL injection. They allow the attacker to leak information about the database, manipulate SQL queries, and view the results, as MySQL's raw error messages are reflected to the page.

The application should implement input sanitation or make use of prepared statements to mitigate the potential for SQL injection attacks. Additionally, it is best practice to always use custom exception handling and messages, rather than allowing internally generated error messages to be seen by the end user.

User credentials are stored insecurely, being only encoded in Base64, rather than hashed with a cryptographically secure hashing algorithm like PBKDF2 or Argon2. This allows an attacker to directly use those credentials.

Finally, James' sudo permissions allow for local privilege escalation to root. 

# Credentials

```
james canttouchhhthiss@455152 (used to sign in on :9090)
cameron	thisscanttbetouchedd@455152 
```


# Flags
(Use https://github.com/vivami/SauronEye)
```
/home/james/local.txt: ce95521e489e92e56982d7563e984e34
/root/flag2.txt: RWFzdGVyRWdn (not accepted or needed)
/root/proof.txt: 6ee324035379d99e62a4306fbe85892f
```

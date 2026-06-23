---
draft: "true"
---


```
curl -i 'http://34.86.186.68:8080/proxy'

HTTP/1.1 500 Internal Server Error
X-Powered-By: Express
Content-Security-Policy: default-src 'none'
X-Content-Type-Options: nosniff
Content-Type: text/html; charset=utf-8
Content-Length: 1182
Date: Sat, 14 Jun 2025 15:59:10 GMT
Connection: keep-alive
Keep-Alive: timeout=5

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>TypeError: Cannot read properties of undefined (reading &#39;startsWith&#39;)<br> &nbsp; &nbsp;at /home/david_morgan2/jj-graphql/app.js:43:35<br> &nbsp; &nbsp;at Layer.handleRequest (/home/david_morgan2/jj-graphql/node_modules/router/lib/layer.js:152:17)<br> &nbsp; &nbsp;at next (/home/david_morgan2/jj-graphql/node_modules/router/lib/route.js:157:13)<br> &nbsp; &nbsp;at Route.dispatch (/home/david_morgan2/jj-graphql/node_modules/router/lib/route.js:117:3)<br> &nbsp; &nbsp;at handle (/home/david_morgan2/jj-graphql/node_modules/router/index.js:435:11)<br> &nbsp; &nbsp;at Layer.handleRequest (/home/david_morgan2/jj-graphql/node_modules/router/lib/layer.js:152:17)<br> &nbsp; &nbsp;at /home/david_morgan2/jj-graphql/node_modules/router/index.js:295:15<br> &nbsp; &nbsp;at processParams (/home/david_morgan2/jj-graphql/node_modules/router/index.js:582:12)<br> &nbsp; &nbsp;at next (/home/david_morgan2/jj-graphql/node_modules/router/index.js:291:5)<br> &nbsp; &nbsp;at Function.handle (/home/david_morgan2/jj-graphql/node_modules/router/index.js:186:3)</pre>
</body>
</html>

┌──(kali㉿kali)-[~]
└─$ curl -i 'http://34.86.186.68:8080/proxy?url='

HTTP/1.1 400 Bad Request
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 11
ETag: W/"b-vtIvYJSrZ5HNvImfy92Jx/HTqsk"
Date: Sat, 14 Jun 2025 15:59:24 GMT
Connection: keep-alive
Keep-Alive: timeout=5

Invalid URL
```


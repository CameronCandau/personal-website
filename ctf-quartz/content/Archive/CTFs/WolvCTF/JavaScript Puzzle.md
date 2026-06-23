![[Pasted image 20250321230209.png]]

After extracting the provided gzip archive, we find the source code and docker files to run the application.
![[Pasted image 20250321221800.png]]

app.js:
```JavaScript
const express = require('express')

const app = express()
const port = 8000

app.get('/', (req, res) => {
    try {
        const username = req.query.username || 'Guest'
        const output = 'Hello ' + username
        res.send(output)
    }
    catch (error) {
        res.sendFile(__dirname + '/flag.txt')
    }
})

app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`)
})
```

The simple application either reflects the username query parameter, or welcomes us as guest if no username is provided.
![[Pasted image 20250321223021.png]]
![[Pasted image 20250321222855.png]]

Right away we see that this provides an opportunity for reflected XSS, and we're able to confirm with a PoC payload, `<script> alert(window.location)</script>`
![[Pasted image 20250321223238.png]]

However this doesn't do anything for us, as we need to cause an error on the server, and XSS will only affect the client.

After much tinkering and research, I came to the following payloads.
![[Pasted image 20250321224423.png]]

![[Pasted image 20250321224652.png]]

This works because we're essentially re-declaring toString as a variable, shadowing the toString() function which is called when trying to convert the username from an object to a string.

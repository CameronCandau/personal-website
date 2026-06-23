**HyperText Transport Protocol**

# Manual Enumeration

![[Pasted image 20250822175714.png]]

This seems to be an instance of FuguHub Website Builder.

The 'About' page shows this is version 8.4.

![[Pasted image 20250822180622.png]]

At `/Config-Wizard/wizard/SetAdmin.lsp` ('CMS Admin' button in top right), it seems we're able to initialize the admin account.

![[Pasted image 20250822175846.png]]


I'll use admin:password and submit the form.

![[Pasted image 20250822180025.png]]

Now we can log in with these credentials to reach the admin page (it redirects us to port 9999 for HTTPS sign in).

![[Pasted image 20250822181631.png]]

On exploitdb I discovered an exploit for [CVE-2023-24078](https://nvd.nist.gov/vuln/detail/CVE-2023-24078), which allows RCE in FuguHub. It was tested with version 8.1, but I'm not seeing confirmation of when it was patched, so it is worth a try.

https://www.exploit-db.com/exploits/51550

On GitHub there is a simple PDF writeup of the manual process for exploitation.
https://github.com/ojan2021/Fuguhub-8.1-RCE/blob/main/Fuguhub-8-1-RCE-Report.pdf

However, I'm going to use the script from exploitdb.

# Exploit Troubleshooting

![[Pasted image 20250822181249.png]]

Looking at the script source, these print statements indicate that it finishes the checkAccount() function, but fails during login(). I noticed that in login(), it tries to use port 443 for HTTPS; we need to change this, as this instance is *not* operating on default ports, and we saw earlier that HTTPS is running on port 9999.

![[Pasted image 20250822182311.png]]

Getting closer... now we're reaching the end of login() where exploit() is called and exits.

```
def exploit(r,s):
    #Find the file server, default is fs
    r = s.get(f"https://{url}:9999/fs/cmsdocs/")
...
```

The script assumes /fs/cmsdocs, but browsing manually, I see that the file server is actually just at /fs/, so I'll remove /cmsdocs/ from the rest of this function.

Still, I was getting errors within the exploit function, and because the main function was still wrapped within the generic exit message, I wasn't able to debug... so I deleted it, since I actually want to see the errors.

```
if __name__=='__main__':
    try:
        main()
    except:
        print(f"\n{Fore.YELLOW}[*]{Fore.WHITE} Good bye!\n\n**All Hail w4rf4ther!")
```

->

```
if __name__=='__main__':
	main()
```

Now, I could finally see that the remaining errors were resultant of the site's invalid SSL certificate.

![[Pasted image 20250822185432.png]]

I modified the script again to add `,verify=False` to each request. 

![[Pasted image 20250822185037.png]]

This time, it ran successfully and I caught the reverse shell.

With this, we've already gained access as root:

![[Pasted image 20250822185649.png]]


# Directory Enumeration (Not used)
(Autorecon feroxbuster)

```
401      GET        1l        2w       21c http://192.168.174.25:8082/private/any/number/of/directories/
401      GET        1l        2w       21c http://192.168.174.25:8082/rtl/protected/admin
200      GET      326l      587w     5738c http://192.168.174.25:8082/theme/bd.css
401      GET        1l        2w       21c http://192.168.174.25:8082/private/manage/
401      GET        1l        2w       21c http://192.168.174.25:8082/private/any/number/of/directories/pagename.html
401      GET        1l        2w       21c http://192.168.174.25:8082/private/any/
401      GET        1l        2w       21c http://192.168.174.25:8082/rtl/protected/
200      GET       29l       45w      737c http://192.168.174.25:8082/zzCMS.js
401      GET        1l        2w       21c http://192.168.174.25:8082/private/any/number/
200      GET       50l       99w     1145c http://192.168.174.25:8082/theme/bd.js
200      GET       11l       21w      415c http://192.168.174.25:8082/metaweblog/rsd.lsp
401      GET        1l        2w       21c http://192.168.174.25:8082/private/
401      GET        1l        2w       21c http://192.168.174.25:8082/private/manage/manual.html
401      GET        1l        2w       21c http://192.168.174.25:8082/rtl/protected/wfslinks.lsp
200      GET      148l      350w     4315c http://192.168.174.25:8082/Config-Wizard/wizard/SetAdmin.lsp
200      GET       52l      239w    21628c http://192.168.174.25:8082/rtl/images/logo.png
200      GET        2l        3w      488c http://192.168.174.25:8082/images/file.gif
200      GET        1l      124w     9775c http://192.168.174.25:8082/album/lightbox.js
200      GET       70l      576w     6761c http://192.168.174.25:8082/photos.html
401      GET        1l        2w       21c http://192.168.174.25:8082/private/any/number/of/
200      GET       69l      173w     2231c http://192.168.174.25:8082/rtl/about.lsp
401      GET        1l        2w       21c http://192.168.174.25:8082/rtl/protected/admin/help
405      GET        1l        7w      110c http://192.168.174.25:8082/metaweblog/
200      GET       67l      449w     4973c http://192.168.174.25:8082/Contact-Us.html
200      GET      248l     1297w   118957c http://192.168.174.25:8082/rtl/favicon.ico
200      GET      156l     2404w   146849c http://192.168.174.25:8082/rtl/jquery.js
200      GET      147l      606w     6924c http://192.168.174.25:8082/
200      GET       55l      809w     7605c http://192.168.174.25:8082/blog/
200      GET        1l       23w     1125c http://192.168.174.25:8082/favicon.ico
401      GET        1l        2w       21c http://192.168.174.25:8082/fs/
200      GET       21l       82w     7415c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img2.jpg
401      GET        1l        2w       21c http://192.168.174.25:8082/private/manage/PageManager.lsp
200      GET       18l       76w     6613c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img7.jpg
200      GET       21l       88w     7147c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img4.jpg
200      GET       22l       73w     6732c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img1.jpg
200      GET       22l       81w     6807c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img9.jpg
200      GET       23l       50w     3408c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img8.jpg
200      GET       17l       64w     5173c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img10.jpg
200      GET        0l        0w    58006c http://192.168.174.25:8082/introduction-to-photo-albums/img3.jpg
200      GET       23l       84w     7584c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img5.jpg
401      GET        1l        2w       21c http://192.168.174.25:8082/private/manage/photo/managealbums.lsp
200      GET       17l       74w     7196c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img6.jpg
200      GET      252l     1307w   133306c http://192.168.174.25:8082/introduction-to-photo-albums/img4.jpg
200      GET       23l       66w     4715c http://192.168.174.25:8082/introduction-to-photo-albums/thumb_img3.jpg
200      GET        0l        0w    38941c http://192.168.174.25:8082/introduction-to-photo-albums/img8.jpg
200      GET      236l      998w    99924c http://192.168.174.25:8082/introduction-to-photo-albums/img10.jpg
200      GET        0l        0w    51361c http://192.168.174.25:8082/introduction-to-photo-albums/img1.jpg
200      GET      225l     1381w   156996c http://192.168.174.25:8082/introduction-to-photo-albums/img6.jpg
200      GET        0l        0w    40345c http://192.168.174.25:8082/introduction-to-photo-albums/img2.jpg
200      GET        0l        0w    43611c http://192.168.174.25:8082/introduction-to-photo-albums/img7.jpg
200      GET        0l        0w    84689c http://192.168.174.25:8082/introduction-to-photo-albums/img9.jpg
200      GET        0l        0w    83618c http://192.168.174.25:8082/introduction-to-photo-albums/img5.jpg
200      GET        1l        3w       42c http://192.168.174.25:8082/red.txt
200      GET        3l        9w       95c http://192.168.174.25:8082/flower.txt
200      GET        1l        7w       76c http://192.168.174.25:8082/passion.txt
```

---
tags:
  - Forensics
  - exiftool
---
# Hidden in Plain Sight - Forensics Writeup


![[Pasted image 20250614090942.png]]

The challenge provided selfie.png. There were no visible clues in the image itself but the hint suggested checking metadata, so I used exiftool.


Sure enough, the flag was embedded directly in the Comment field of the image metadata. We can also grep for it since we know the flag starts with C1:

``` bash
exiftool selfie.png | grep C1
```

``` Plaintext
Comment                         : C1{smile_youre_flagged}
```

``` bash
exiftool selfie.png
```

```
ExifTool Version Number         : 13.25
File Name                       : selfie.png
Directory                       : .
File Size                       : 2.9 MB
File Modification Date/Time     : 2025:06:14 09:10:02-07:00
File Access Date/Time           : 2025:06:14 09:10:21-07:00
File Inode Change Date/Time     : 2025:06:14 09:10:20-07:00
File Permissions                : -rw-rw-r--
File Type                       : PNG
File Type Extension             : png
MIME Type                       : image/png
Image Width                     : 1024
Image Height                    : 1536
Bit Depth                       : 8
Color Type                      : RGB
Compression                     : Deflate/Inflate
Filter                          : Adaptive
Interlace                       : Noninterlaced
JUMD Type                       : (c2pa)-0011-0010-800000aa00389b71
JUMD Label                      : c2pa
Actions Action                  : c2pa.created, c2pa.converted
Actions Software Agent Name     : GPT-4o, OpenAI API
Actions Digital Source Type     : http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia
Exclusions Start                : 33
Exclusions Length               : 14149
Name                            : jumbf manifest
Alg                             : sha256
Hash                            : (Binary data 32 bytes, use -b option to extract)
Pad                             : (Binary data 8 bytes, use -b option to extract)
Instance ID                     : xmp:iid:4ab9f752-5816-4a57-bd02-22f6dde290f3
Claim Generator Info Name       : ChatGPT
Claim Generator Info Org Cai C2 Pa Rs: 0.51.1
Signature                       : self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746/c2pa.signature
Created Assertions Url          : self#jumbf=c2pa.assertions/c2pa.actions.v2, self#jumbf=c2pa.assertions/c2pa.hash.data
Created Assertions Hash         : (Binary data 32 bytes, use -b option to extract), (Binary data 32 bytes, use -b option to extract)
Title                           : image.png
Item 0                          : (Binary data 1985 bytes, use -b option to extract)
Item 1 Pad                      : (Binary data 10932 bytes, use -b option to extract)
Item 2                          : null
Item 3                          : (Binary data 64 bytes, use -b option to extract)
C2PA Thumbnail Ingredient Jpeg Type: image/jpeg
C2PA Thumbnail Ingredient Jpeg Data: (Binary data 32785 bytes, use -b option to extract)
Relationship                    : componentOf
Format                          : png
Validation Results Active Manifest Success Code: claimSignature.insideValidity, claimSignature.validated, assertion.hashedURI.match, assertion.hashedURI.match, assertion.dataHash.match
Validation Results Active Manifest Success Url: self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746/c2pa.signature, self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746/c2pa.signature, self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746/c2pa.assertions/c2pa.actions.v2, self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746/c2pa.assertions/c2pa.hash.data, self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746/c2pa.assertions/c2pa.hash.data
Validation Results Active Manifest Success Explanation: claim signature valid, claim signature valid, hashed uri matched: self#jumbf=c2pa.assertions/c2pa.actions.v2, hashed uri matched: self#jumbf=c2pa.assertions/c2pa.hash.data, data hash valid
Active Manifest Url             : self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746
Active Manifest Alg             : sha256
Active Manifest Hash            : (Binary data 32 bytes, use -b option to extract)
Claim Signature Url             : self#jumbf=/c2pa/urn:c2pa:a85273ea-e1fd-4098-b3a8-4439a2f3d746/c2pa.signature
Claim Signature Alg             : sha256
Claim Signature Hash            : (Binary data 32 bytes, use -b option to extract)
Thumbnail URL                   : self#jumbf=c2pa.assertions/c2pa.thumbnail.ingredient.jpeg
Thumbnail Hash                  : (Binary data 32 bytes, use -b option to extract)
Comment                         : C1{smile_youre_flagged}
Image Size                      : 1024x1536
Megapixels                      : 1.6

```

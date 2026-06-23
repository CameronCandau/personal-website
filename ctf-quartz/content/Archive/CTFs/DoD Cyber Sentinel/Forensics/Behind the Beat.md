---
tags:
  - Forensics
  - exiftool
---
![[Pasted image 20250614090835.png]]

As with [[Hidden in Plain Sight]], I found the flag within the provided file's metadata, under the "Encoded By" field:

`exiftool message.mp3`

```
ExifTool Version Number         : 13.25
File Name                       : message.mp3
Directory                       : .
File Size                       : 241 kB
File Modification Date/Time     : 2025:06:14 09:06:48-07:00
File Access Date/Time           : 2025:06:14 09:07:14-07:00
File Inode Change Date/Time     : 2025:06:14 09:07:13-07:00
File Permissions                : -rw-rw-r--
File Type                       : MP3
File Type Extension             : mp3
MIME Type                       : audio/mpeg
MPEG Audio Version              : 1
Audio Layer                     : 3
Audio Bitrate                   : 64 kbps
Sample Rate                     : 44100
Channel Mode                    : Single Channel
MS Stereo                       : Off
Intensity Stereo                : Off
Copyright Flag                  : False
Original Media                  : False
Emphasis                        : None
ID3 Size                        : 79
Encoded By                      : C1{metadata_tells_more}
Encoder Settings                : Lavf61.7.100
Duration                        : 0:00:30 (approx)
```

`C1{metadata_tells_more}`
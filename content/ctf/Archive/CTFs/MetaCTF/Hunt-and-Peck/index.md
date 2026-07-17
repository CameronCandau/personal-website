---
draft: "true"
---


![[Pasted image 20250626140351.png]]

- Open in Wireshark
- Nothing to get from File >Export Objects
- Filter using `usb.device_class == 0x03`
- Filter using `usb.transfer_type == 0x01 && usb.src == "2.9.1"` for things that were typed and sent from the input device
- 
- HID = Human Interface Device
	- part of the USB specification for computer peripherals: it specifies a device class for human interface devices such as keyboards, mice, touchscreen, game controllers and alphanumeric display devices. The USB HID class is defined in a number of documents provided by the USB Implementers Forum's Device Working Group.  https://en.wikipedia.org/wiki/USB_human_interface_device_class
- We see HID data in the packets
	- ![[Pasted image 20250626141743.png]]
- https://abawazeeer.medium.com/kaizen-ctf-2018-reverse-engineer-usb-keystrok-from-pcap-file-2412351679f4
- Other people have Leftover Capture Data instead of "HID Data", like ChatGPT was saying
- `tshark -r usb.pcapng -Y '((usb.transfer_type == 0x01) && (usb.src == "2.9.1"))' -T fields -e usbhid.data`

```
Decoded Output:

aaaaaaaaabbbbbbabaaaaaaaaaaabbaabababababcabcbbaccbacbbaaabaaaaaabaaaabaabbababababababbbacbabaaabaaaaaaaaabaaabaabababacbababbaaaabaaaaabaaaaab
```

> i used https://github.com/Nissen96/USB-HID-decoders/tree/main then watched the animation carefully


> https://github.com/WangYihang/USB-Mouse-Pcap-Visualizer?tab=readme-ov-file


https://metactf.com/blog/flash-ctf-huntandpeck/
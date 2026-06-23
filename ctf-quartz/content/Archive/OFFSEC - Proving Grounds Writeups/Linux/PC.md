---
date: 2025-11-25
---
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [ ] 8000
- [ ] 22

# Service Enumeration
## 8000
![[Pasted image 20251115114243.png]]

This is an interesting start...

HTTP headers reveal that this is ttyd. Specifically ttyd version 1.7.3-a2312cb, at /snap/bin/ttyd.
https://github.com/tsl0922/ttyd

`curl http://192.168.222.210:8000/token`

```
{"token": ""}
```

# Privilege Escalation

Linux pc 5.4.0-156-generic # 173-Ubuntu SMP Tue Jul 11 07:25:22 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

`sudo -l` requires password

`ss -antup` shows 127.0.0.1:65432 is listening, and /opt/rpc.py seems likely to be the source code, as it also runs on this port.

```
from typing import AsyncGenerator
from typing_extensions import TypedDict

import uvicorn
from rpcpy import RPC

app = RPC(mode="ASGI")


@app.register
async def none() -> None:
    return


@app.register
async def sayhi(name: str) -> str:
    return f"hi {name}"


@app.register
async def yield_data(max_num: int) -> AsyncGenerator[int, None]:
    for i in range(max_num):
        yield i


D = TypedDict("D", {"key": str, "other-key": str})


@app.register
async def query_dict(value: str) -> D:
    return {"key": value, "other-key": value}


if __name__ == "__main__":
    uvicorn.run(app, interface="asgi3", port=65432)
```

`ps aux | grep rpc` shows that the process is running as root.
![[Pasted image 20251115133823.png]]

Through a combination of searching for things related to rpcpy and this port number, I eventually found CVE-2022-35411 which allows for unauthenticated RCE 
https://nvd.nist.gov/vuln/detail/CVE-2022-35411

https://github.com/ehtec/rpcpy-exploit

For ease of use, I used ligolo-ng to forward 127.0.0.1 on the target to 240.0.0.1 on my workstation, but I also could have simply transferred the exploit to the target to run it.

I was able to quickly modify this script to connect to my listener to establish a reverse shell as root.
![[Pasted image 20251115134103.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/root/proof.txt
399985ee523749fe27b71d1537adebbd

![[Pasted image 20251115134123.png]]


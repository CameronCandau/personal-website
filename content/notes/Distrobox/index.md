## Create an Ubuntu 24.04 distrobox
```bash
distrobox create --name ubuntu24 --image docker.io/library/ubuntu:24.04
```

## List existing distroboxes
```bash
distrobox list
```

## Enter a distrobox shell
```bash
distrobox enter <box-name>
```

## Enter a distrobox with container-manager root privileges
```bash
distrobox enter --root <box-name>
```

## Run a one-off command inside a distrobox
```bash
distrobox enter <box-name> -- <command> <arg1> <arg2>
```

## Run a command as root inside the distrobox container
```bash
# Useful when package installs or root access are awkward through distrobox enter.
podman exec -u 0 <box-name> <command> <arg1> <arg2>
```

## Install packages inside a distrobox
```bash
podman exec -u 0 <box-name> apt-get update
podman exec -u 0 <box-name> apt-get install -y <package1> <package2>
```

## Create a distrobox with an extra host directory mounted
```bash
distrobox create --name <box-name> --image <image> \
  --volume /absolute/host/path:/absolute/container/path
```

## Create a distrobox with direct access to a host device
```bash
distrobox create --name <box-name> --image <image> \
  --additional-flags "--device /dev/<device>"
```

## Check whether desktop audio sockets are visible inside a distrobox
```bash
podman exec <box-name> sh -lc 'echo PULSE_SERVER=$PULSE_SERVER; ls /run/user/1000/pulse/native 2>/dev/null || true; ls /run/user/1000/pipewire-0 2>/dev/null || true; ls -ld /dev/snd 2>/dev/null || true'
```

## Export a desktop app from a distrobox to the host
```bash
distrobox enter <box-name> -- distrobox-export --app <desktop-id>
```

## Export a command from a distrobox to the host
```bash
distrobox enter <box-name> -- distrobox-export --bin /usr/bin/<command>
```

## Launch a host file from inside a distrobox without inheriting GTK3 module overrides
```bash
env -u GTK3_MODULES distrobox enter <box-name> -- /absolute/path/to/program
```

## Notes2Hosts (OpIndex)
Run after creating md files for each machine to print commands to paste into VM for updating hosts.txt for NetExec and /etc/hosts.
```
printf 'sudo tee -a /etc/hosts <<EOF\n'
find . -maxdepth 1 -type f -printf '%f\n' |
awk '$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {
    host=$2
    sub(/\.md$/, "", host)
    print $1 "\t" host
}'
printf 'EOF\n'
printf '\ncat > hosts.txt <<EOF\n'
find . -maxdepth 1 -type f -printf '%f\n' |
awk '$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {print $1}'
printf 'EOF\n'
```
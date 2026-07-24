# Bicep Deployments

## Create deployment using template and parameter files

```
az deployment sub create --location wus --template-file foo.bicep --parameters bar.json
```

# Azure Key Vault

## Show Key Vault

```bash
az keyvault show --name 'vault-name'
```

## List Secret Names

```bash
az keyvault secret list \
  --vault-name 'vault-name' \
  --query '[].name' \
  -o tsv
```

## Show Secret Value

```bash
az keyvault secret show \
  --vault-name "vault-name" \
  --name "secret-name" \
  --query "value" \
  -o tsv
# Optional: remove --query to return the full JSON result instead of one field
```

## Search Secret Names in One Key Vault

```bash
set -euo pipefail

secret_name_list=$(
  az keyvault secret list --vault-name 'vault-name' --query '[].name' -o tsv
)

printf '%s\n' "$secret_name_list" | grep -E -- '(token|url)' || true
```

## Search Secret Values in One Key Vault

```bash
set -euo pipefail

vault_name='vault-name'

secret_name_list=$(
  az keyvault secret list --vault-name "$vault_name" --query '[].name' -o tsv
)

mapfile -t secret_names <<< "$secret_name_list"

for secret_name in "${secret_names[@]}"; do
  if ! secret_value=$(
    az keyvault secret show \
      --vault-name "$vault_name" \
      --name "$secret_name" \
      --query value \
      -o tsv
  ); then
    printf 'WARN   unable to read %s/%s\n' "$vault_name" "$secret_name" >&2
    continue
  fi

  if printf '%s\n' "$secret_value" | grep -qiE -- '\.com$'; then
    preview=$(printf '%s' "$secret_value" | tr '\n' ' ' | cut -c1-80)
    printf 'MATCH  %s/%s\n' "$vault_name" "$secret_name"
    printf '       %s...\n' "$preview"
  fi
done
```

## Search Secret Names Across Key Vaults

```bash
set -euo pipefail

vault_list=$(
  az keyvault list --query '[].name' -o tsv
)

vault_list=$(
  printf '%s\n' "$vault_list" | grep -E -- '^kv-app' || true
)
# Optional: remove the grep filter above to search all available vaults

mapfile -t vaults <<< "$vault_list"

for vault in "${vaults[@]}"; do
  printf '=== %s ===\n' "$vault"

  if ! secret_name_list=$(
    az keyvault secret list --vault-name "$vault" --query '[].name' -o tsv
  ); then
    printf 'WARN   unable to list secrets for %s\n' "$vault" >&2
    continue
  fi

  printf '%s\n' "$secret_name_list" | grep -E -- '(token|url)' || true
done
```

## Search Secret Values Across Key Vaults

```bash
set -euo pipefail

vault_list=$(
  az keyvault list --query '[].name' -o tsv
)

vault_list=$(
  printf '%s\n' "$vault_list" | grep -E -- '^kv-app' || true
)
# Optional: remove the grep filter above to search all available vaults

mapfile -t vaults <<< "$vault_list"

for vault in "${vaults[@]}"; do
  printf '=== %s ===\n' "$vault"

  if ! secret_name_list=$(
    az keyvault secret list --vault-name "$vault" --query "[].name" -o tsv
  ); then
    printf 'WARN   unable to list secrets for %s\n' "$vault" >&2
    continue
  fi

  mapfile -t secret_names <<< "$secret_name_list"

  for secret_name in "${secret_names[@]}"; do
    if ! secret_value=$(
      az keyvault secret show \
        --vault-name "$vault" \
        --name "$secret_name" \
        --query value \
        -o tsv
    ); then
      printf 'WARN   unable to read %s/%s\n' "$vault" "$secret_name" >&2
      continue
    fi

    if printf '%s\n' "$secret_value" | grep -qiE -- '\.com$'; then
      preview=$(printf '%s' "$secret_value" | tr '\n' ' ' | cut -c1-80)
      printf 'MATCH  %s/%s\n' "$vault" "$secret_name"
      printf '       %s...\n' "$preview"
    fi
  done
done
```

# DNS

Source: https://learn.microsoft.com/en-us/azure/dns/dns-operations-recordsets-cli#create-a-txt-record

## Create a CNAME record

```
az network dns record-set cname set-record --resource-group myresourcegroup --zone-name contoso.com --record-set-name test-cname --cname www.contoso.com
```

## Create a TXT record

```
az network dns record-set txt add-record --resource-group myresourcegroup --zone-name contoso.com --record-set-name test-txt --value "This is a TXT record"
```


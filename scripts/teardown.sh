#!/usr/bin/env bash
set -uo pipefail
RG=${1:-rg-lab}
LOC=${2:-canadacentral}
LOG=~/teardown-$(date +%Y%m%d-%H%M%S).log

echo "== Inventory: $RG =="
az resource list -g "$RG" --query "[].{name:name, type:type}" -o table | tee "$LOG"

echo "== Node resource groups (AKS-managed) =="
az group list --query "[?starts_with(name,'MC_')].name" -o tsv | tee -a "$LOG"

echo "== Deleting $RG =="
time az group delete --name "$RG" --yes

echo "== Purging soft-deleted key vaults =="
az keyvault list-deleted --query "[?starts_with(name,'kv-lab')].name" -o tsv \
  | xargs -r -I {} az keyvault purge --name {} --location "$LOC"

echo "== Remaining =="
az group list -o table
az keyvault list-deleted -o table
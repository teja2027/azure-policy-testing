#!/bin/bash

VAULT_NAME=$1
VAULT_SECRETNAME_ARM_CLIENT_ID=$2
VAULT_SECRETNAME_ARM_CLIENT_SECRET=$3

if [[ ! -x $(which az) ]]
then
    echo "$0 ERROR: Unable to execute Azure CLI. Is it in your PATH?" >&2
    exit 1
fi

if [[ ! -x $(which jq) ]]
then
    echo "$0 ERROR: Unable to execute jq. Is it in your PATH?" >&2
    exit 1
fi

if ! az account show > /dev/null 2>&1
then
    echo "$0 ERROR: You are not logged in to the Azure CLI." >&2
    exit 1
fi

ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
ARM_CLIENT_ID=$(az keyvault secret show --name $VAULT_SECRETNAME_ARM_CLIENT_ID --vault-name $VAULT_NAME --query value -o tsv)
ARM_CLIENT_SECRET=$(az keyvault secret show --name $VAULT_SECRETNAME_ARM_CLIENT_SECRET --vault-name $VAULT_NAME --query value -o tsv)

jq -n \
--arg ARM_CLIENT_ID "$ARM_CLIENT_ID" \
--arg ARM_CLIENT_SECRET "$ARM_CLIENT_SECRET" \
--arg ARM_TENANT_ID "$ARM_TENANT_ID" \
'{"ARM_TENANT_ID":$ARM_TENANT_ID, "ARM_CLIENT_ID":$ARM_CLIENT_ID, "ARM_CLIENT_SECRET":$ARM_CLIENT_SECRET}'

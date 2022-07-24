#!/bin/bash

cwd=$(pwd)
cd ${HOME}/.local/consul

[ -d ${cwd}/namespaces/vault/secrets ] || mkdir -p ${cwd}/namespaces/vault/secrets

kubectl create secret generic choclab-consul-cert \
  --namespace vault \
  --from-file="ca.crt"=consul-agent-ca.pem \
  --from-file="tls.crt"=choclab-server-consul-0.pem \
  --from-file="tls.key"=choclab-server-consul-0-key.pem \
  --dry-run=client \
  -o yaml > ${cwd}/namespaces/vault/secrets/choclab-consul-cert.yaml

cd ${HOME}/.local/vault
kubectl create secret generic vault-consul-acl-token \
    --namespace vault \
    --from-file=token=vault-consul-token \
    --dry-run=client \
    -o yaml > ${cwd}/namespaces/vault/secrets/vault-consul-acl-token.yaml

kubectl create secret generic vault-bitwarden \
    --namespace vault \
    --from-file=token="bwv.token" \
    --from-literal=address="https://192.168.1.2:6277" \
    --from-literal=path="choclab/nebula/vault" \
    --dry-run=client \
    -o yaml > ${cwd}/namespaces/vault/secrets/vault-bitwarden.yaml

cd ${cwd}
sops --encrypt --in-place namespaces/vault/secrets/choclab-consul-cert.yaml
sops --encrypt --in-place namespaces/vault/secrets/vault-consul-acl-token.yaml
sops --encrypt --in-place namespaces/vault/secrets/vault-bitwarden.yaml

./scripts/letsencrypt.bash vault choclab-vault-cert vault.choclab.net

kubectl create cm vault-unseal \
  --namespace vault \
  --from-file="vault-unseal.sh"=scripts/unseal.bash \
  --dry-run=client \
  -o yaml > namespaces/vault/vault-unseal.yaml
git add .
git commit -am'Updated - Vault certificates, secrets and configmaps'

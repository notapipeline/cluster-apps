#!/bin/bash

cwd=$(pwd)
[ -d  ${HOME}/.local/consul ] || mkdir ${HOME}/.local/consul
cd ${HOME}/.local/consul
[ -f consul-agent-ca.pem ] || consul tls ca create
[ -f consul-gossip.key ] || consul keygen > consul-gossip.key

# TODO tls expiry rm cert

[ -f choclab-server-consul-0.pem ] || consul tls cert create -server -days=730 -domain=consul -ca=consul-agent-ca.pem \
    -key=consul-agent-ca-key.pem -dc=choclab \
    -additional-dnsname="consul-consul-server" \
    -additional-dnsname="*.consul-consul-server" \
    -additional-dnsname="*.consul-consul-server.vault" \
    -additional-dnsname="consul-consul-server.vault" \
    -additional-dnsname="*.consul-consul-server.vault.svc" \
    -additional-dnsname="consul-consul-server.vault.svc" \
    -additional-dnsname="*.server.choclab.choclab.net" \
    -additional-dnsname="server.choclab.choclab.net" \
    -additional-dnsname="*.consul.choclab.net" \
    -additional-dnsname="consul.choclab.net" \
    -additional-dnsname="localhost" \
    -additional-dnsname="127.0.0.1"

[ -d ${cwd}/namespaces/consul/secrets ] || mkdir -p ${cwd}/namespaces/consul/secrets

kubectl create secret generic consul \
  --namespace consul \
  --from-file=cacrt=consul-agent-ca.pem \
  --from-file=cakey=consul-agent-ca-key.pem \
  --from-file=gossip=consul-gossip.key \
  --dry-run=client \
  -o yaml > ${cwd}/namespaces/consul/secrets/consul.yaml

kubectl create secret generic choclab-consul-cert \
  --namespace consul \
  --from-file="tls.crt"=choclab-server-consul-0.pem \
  --from-file="tls.key"=choclab-server-consul-0-key.pem \
  --dry-run=client \
  -o yaml > ${cwd}/namespaces/consul/secrets/choclab-consul-cert.yaml

cd ${cwd}
sops --encrypt --in-place namespaces/consul/secrets/consul.yaml
sops --encrypt --in-place namespaces/consul/secrets/choclab-consul-cert.yaml

git add .
git commit -am'Updated - Consul certificates and secrets'

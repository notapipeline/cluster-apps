#!/bin/bash
namespace=$1
secret=$2
fqdn=$3
cwd=$(pwd)
if [ ! -d build/${namespace} ]; then
    mkdir -p build/${namespace}
fi
sudo bash -c "cp /etc/letsencrypt/live/${fqdn}/fullchain.pem ${cwd}/build/${namespace}/tls.crt"
sudo bash -c "cp /etc/letsencrypt/live/${fqdn}/privkey.pem ${cwd}/build/${namespace}/tls.key"
sudo chown -R $(id -un):$(id -gn) ${cwd}/build/${namespace}

[ -d namespaces/${namespace}/secrets ] || mkdir  namespaces/${namespace}/secrets
kubectl create secret generic ${secret} \
  --namespace ${namespace} \
  --from-file="tls.crt"=./build/${namespace}/tls.crt \
  --from-file="tls.key"=./build/${namespace}/tls.key \
  --dry-run=client \
  -o yaml > namespaces/${namespace}/secrets/${secret}.yaml

sops --encrypt --in-place namespaces/${namespace}/secrets/${secret}.yaml
rm ${cwd}/build/${namespace}/tls.crt ${cwd}/build/${namespace}/tls.key

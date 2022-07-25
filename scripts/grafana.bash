#!/bin/bash

kubectl create secret generic grafana-db \
    --namespace frontend \
    --from-literal=GF_DATABASE_USER=$(bwv 'choclab/nebula/db/grafana-db' | jq -r '.[0].username') \
    --from-literal=GF_DATABASE_PASSWORD=$(bwv 'choclab/nebula/db/grafana-db' | jq -r '.[0].password') \
    --dry-run=client \
    -o yaml > namespaces/frontend/secrets/grafana-db.yaml
sops --encrypt --in-place namespaces/frontend/secrets/grafana-db.yaml

kubectl create secret generic grafana-admin \
    --namespace frontend \
    --from-literal=username=$(bwv 'choclab/nebula/grafana' | jq -r '.[0].username') \
    --from-literal=password=$(bwv 'choclab/nebula/grafana' | jq -r '.[0].password') \
    --dry-run=client \
    -o yaml > namespaces/frontend/secrets/grafana-admin.yaml
sops --encrypt --in-place namespaces/frontend/secrets/grafana-admin.yaml

git add .
git commit -am'Updated - grafana credentials'

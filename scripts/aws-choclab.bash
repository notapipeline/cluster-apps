AWS_PROFILE=default

cat <<EOT > creds.conf
[default]
aws_access_key_id = $(aws configure get aws_access_key_id --profile $AWS_PROFILE)
aws_secret_access_key = $(aws configure get aws_secret_access_key --profile $AWS_PROFILE)
EOT

kubectl create secret generic choclab-aws-credentials \
    --namespace crossplane-system \
    --dry-run=client \
    --from-file=eu-central-1=./creds.conf -o yaml > namespaces/crossplane-system/secrets/choclab-aws-credentials.yaml
rm creds.conf
sops --encrypt --in-place namespaces/crossplane-system/secrets/choclab-aws-credentials.yaml

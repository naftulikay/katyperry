# Spinnaker

Enter the Vagrant box and setup your `GOOGLE_APPLICATION_CREDENTIALS` environment variable to use your credentials
for Terraform, and choose a GCP project to use with the `GOOGLE_PROJECT` environment variable:

```shell
$ export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/legacy_credentials/me@naftuli.wtf/adc.json"
$ export GOOGLE_PROJECT="naftuli-test"
```

Next, spin up the Terraform to create a network and deploy GKE:

```shell
$ cd terraform/gke
$ terraform init
$ terraform apply
```

Hop back to the root directory, which is `/vagrant` if you're in the VM.

After this completes, the GKE cluster should be ready, so let's fetch the `kubectl` credentials:

```shell
$ gcloud container clusters get-credentials --region=us-west1 gke-test-1
```

Next, deploy Helm and Tiller into the cluster:


```shell
#!/bin/bash

kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount kube-system:tiller
helm init --service-account tiller
```

We must either:

List the public repos in `values.yaml`, as in the existing example

**or**

List credentials for (in our case) GCR:

1. Run this script (from [spinnaker docs](https://www.spinnaker.io/setup/install/providers/docker-registry/#add-the-account)):

```shell
#!/bin/bash

ADDRESS=gcr.io
SERVICE_ACCOUNT_NAME=spinnaker-gcr-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/browser

gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/storage.admin

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL
```

2. Paste the json in `$SERVICE_ACCOUNT_DEST` into `helm/values.yaml`
3. The rest of the values are already set.

Next, we'll deploy Spinnaker:

```shell
#!/bin/bash

cd helm/charts/stable/spinnaker
helm install --name genghis -f demos/spinnaker/values.yaml stable/spinnaker
```

Apply a necessary RBAC:

```shell
#!/bin/bash

kubectl apply -f demos/spinnaker/rbac.yaml
```

Port forwarding must be setup to access Spinnaker:

```shell
#!/bin/bash

export DECK_POD=$(kubectl get pods --namespace default -l "component=deck,app=genghis-spinnaker" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace default $DECK_POD 9000
```

Now, `127.0.0.1:9000` within the VM is securely forwarded into the cluster to Spinnaker. The easiest way to access this
from your desktop is to shell into the Vagrant machine with an SSH port forward:

```
$ vagrant ssh -- -L 9000:localhost:9000
```

Open up your browser to http://localhost:9000 to be greeted by the Spinnaker UI.

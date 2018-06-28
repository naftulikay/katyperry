# Spinnaker

Enter the Vagrant box and setup your `GOOGLE_APPLICATION_CREDENTIALS` environment variable to use your credentials
for Terraform:

```shell
$ export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/legacy_credentials/me@naftuli.wtf/adc.json"
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
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin \
    --serviceaccount kube-system:tiller
$ helm init --service-account tiller
```

Next, we'll deploy Spinnaker:

```shell
$ cd helm/charts/stable/spinnaker
$ helm install --name genghis stable/spinnaker
```

After this is created, port forwarding must be setup to access Spinnaker:


```shell
$ kubectl get pods --namespace default -l "component=deck,app=genghis-spinnaker" \
    -o jsonpath="{.items[0].metadata.name}" && echo
genghis-spinnaker-deck-DEADBEEFED-CAFE5
$ kubectl port-forward --namespace default genghis-spinnaker-deck-DEADBEEFED-CAFE5 9000
```

Now, `127.0.0.1:9000` within the VM is securely forwarded into the cluster to Spinnaker. The easiest way to access this
from your desktop is to shell into the Vagrant machine with an SSH port forward:

```
$ vagrant ssh -- -L 9000:localhost:9000
```

Open up your browser to http://localhost:9000 to be greeted by the Spinnaker UI.

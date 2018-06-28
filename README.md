# katyperry

A Vagrant-based Kubernetes development and management environment.

## Setup

### GKE

Fetch credentials for `kubectl`:

```shell
$ gcloud container clusters get-credentials --region=us-west1 cluster-1
```

Now the cluster and its resources should be visible:

```shell
$ kubectl get nodes
NAME                                       STATUS                     ROLES     AGE       VERSION
gke-cluster-1-default-pool-3fb5fe40-59v3   Ready                      <none>    3h        v1.8.10-gke.0
gke-cluster-1-default-pool-52536a45-4tcr   Ready                      <none>    3h        v1.8.10-gke.0
gke-cluster-1-default-pool-52536a45-gpp1   Ready                      <none>    3h        v1.8.10-gke.0
```

Next, Helm and Tiller can be initialized:

```shell
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin \
    --serviceaccount kube-system:tiller
$ helm init --service-account tiller
```

From here, the sky's the limit and the course uncharted.

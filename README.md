# Infrastructure Engineer Challenge

For the instructions of this task see [instructions.md](instructions.md).

## Project structure
This simple project contains an automated scripts to create:
- Kind cluster
- Local registry
- Deploy a demo full-stack app to the cluster
- Integrate observability stack for monitoring and logging of the cluster/workload
```
.
├── clusters/
│   └── dev/
│       ├── .env
│       └── shared-k8s-services/
│           ├── loki
│           ├── prometheus-stack
│           ├── promtail
│           └── namespaces.yaml
├── scripts/
│   ├── bootstrap-kind-cluster.sh
│   ├── bootstrap-local-registry.sh
│   ├── build-publish-images.sh
│   ├── cluster-dependencies.sh
│   ├── configs.sh
│   ├── deploy-observability-stack.sh
│   ├── deploy-workloads.sh
│   └── functions.sh
├── src/
│   ├── backend/
│   │   ├── kubernetes-manifests/
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── ...
│   └── frontend/
│       ├── kubernetes-manifests/
│       ├── requirements.txt
│       ├── Dockerfile
│       └── ...
├── tests/
│   └── test-local-registry.sh
├── .gitignore
├── instructions.md
└── README.md
```

### `scripts/` This is all the automation scripts in this project in their running order:
- `scripts/configs.sh` contains all the configurable global values of all scripts
- `scripts/functions.sh` contains all the shared functions among all scripts
- `scripts/bootstrap-local-registry.sh`
- `scripts/bootstrap-kind-cluster.sh`
- `scripts/cluster-dependencies.sh`
- `scripts/deploy-observability-stack.sh`
- `scripts/build-publish-images.sh`
- `scripts/deploy-workloads.sh`

### `src` this contains the source code of the workloads
- `src/backend/` the source code of the backend workload with its Dockerfile and the needed manifests for rolling it out.
- `src/frontend/` the source code of the frontend workload with its Dockerfile and the needed manifests for rolling it out.

### `clusters` this is used to separate the configuration of the helm charts and the k8s services based on enveronmant.
- `dev` contains all special values of the shared services that's running in the dev cluster. Or any cluster-wide manifest. E.g the manifest and helm chart's values of the observability service can be found in here.

# Before you start
TODO: add more details
- You need the following tools to be installed on your local machine(MacOs/Linux)
```
KinD
Docker
kubectl
helm
trivy
kustomize
```

# How to run

```
chmod +x start-local.sh
./start-local.sh
```

- Get Grafana 'admin' user password by running (see the Tech-debt):
```
kubectl --namespace monitoring get secrets kps-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
```

- Add Loki as a datasource to Grafana (see the Tech-debt)
```
# Connections > add new connection > search for "Loki" > add this as Connection::URL
# http://<loki-service-name>.<loki-namespace>.svc.cluster.local:<service-port>

http://loki-gateway.logging.svc.cluster.local
```

- To access the deployed app:
```
# port-forward
kubectl port-forward service/python-guestbook-frontend 8080:80

# curl/or via browser
curl "http://localhost:8080"
```

# Tests
- to check your local registry
```
chmod +x tests/test-local-registry.sh
./tests/test-local-registry.sh <REG_PORT>
```

TODOs:
- !!IMPORTANT!! [Tech-debt] Trivy reports for the workloads images shows tons of High/Critical vulnerabilities:
```
backend-app:v0.0.1 (debian 12.7)
Total: 832 (HIGH: 791, CRITICAL: 41)
----
frontend-app:v0.0.1 (debian 12.7)
Total: 832 (HIGH: 791, CRITICAL: 41)
```
- [Tech-debt] the sizes of the docker images is so high (> 1G each)
- [Tech-debt] harden docker images
- [Tech-debt] customzie Grafana's admin creds secret
- [Tech-debt] automate Grafana's data sources

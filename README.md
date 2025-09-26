# Infrastructure Engineer Challenge

For the instructions of this task see [instructions.md](instructions.md).

# Before you start
TODO: add more details
- You need the following tools to be installed on your local machine(MacOs/Linux)
```
KinD
Docker
kubectl
helm
trivy
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
- [Tech-debt] customzie Grafana's admin creds secret
- [Tech-debt] automate Grafana's data sources

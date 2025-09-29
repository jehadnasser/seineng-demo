# Infrastructure Engineer Challenge

For the instructions of this task see [instructions.md](instructions.md).

This simple project contains an automated scripts to create:
- Kind cluster
- Local registry
- Deploy a demo full-stack app to the cluster
- Integrate observability stack for monitoring and logging of the cluster/workload
- Expose all intresting services and echo its URLs.

## Project's structure
    ```
    .
    ├── clusters/
    │   └── dev/
    │       └── ...
    ├── scripts/
    │   └── ...
    ├── ...
    ```

- `clusters` this is used to separate the configuration of the applications (workloads) and the shared k8s services based on enveronmant.

- `scripts/` This dir contains the automation scripts of this project.

## Before you start
### 1. Prepare your local machine
- You need the following tools to be installed on your local machine (MacOs/Linux):
    - KinD from [here](https://kind.sigs.k8s.io/)
    - Docker from [here](https://www.docker.com/)
    - kubectl from [here](https://kubernetes.io/docs/reference/kubectl/kubectl/)
    - helm from [here](https://helm.sh/)
    - trivy from [here](https://aquasecurity.github.io/trivy/)
    - kustomize from [here](https://kustomize.io/)

- for MacOS:
    ```sh
    brew install kind docker kubectl helm trivy kustomize
    ```

- for Linux (Debian/Ubuntu):
    ```sh
    # Install curl for other tool installations
    sudo apt-get update
    sudo apt-get install -y curl

    # Install Docker
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Install KinD
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

    # Install Trivy
    sudo apt-get install -y wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y trivy

    # Install Kustomize
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
    ```


### 2. Prepare PagerDuty integration
- Sign up for PagerDuty [here](https://www.pagerduty.com/sign-up/)
- Create a New Service in PagerDuty UI
    - Navigate to Services -> Service Directory
    - Click the `+ New Service` button.
    - Give your service a descriptive name, assign an Escalation policy to the service. You can use the default or create a new one to define who gets notified and in what order. Click Next.
    - In the `Integrations` section, choose `Events API V2` as the integration method.
    - Once created, get the `Integration Key` from the section: Service Directory > Your-Service-Name integrations. This key will be used later as the `routing_key` in the alertmanager's receivers configs.
- Decrypt `clusters/<ENV>/.env`, you can find ansible-vault's password in the Environment secrets of this repository under the name `ANSIBLE_VAULT_PASS`:
    ```sh
    ansible-vault decrypt clusters/dev/.env --output=- > clusters/<ENV>/secret.env
    ```
- Add the `Integration Key` to the file `clusters/<ENV>/secret.env`:
    ```sh
    PAGERDUTY_ROUTING_KEY=<YOUR-INTEGRATION-KEY>
    # ...
    ```
- Consume this inside the alertmanager configs in the prometheus-stack chart's values in `clusters/<ENV>/shared-k8s-services/observability/monitoring/prometheus-stack/values.yaml`
    ```sh
    alertmanager:
    enabled: true
    config:
        receivers:
        - name: '<receiver-name>'
        pagerduty_configs:
        - routing_key: ${PAGERDUTY_ROUTING_KEY}
    # ...
    ```
- PagerDuty is ready and the integration will happen during the installation of the prometheus-stack chart as part of the automation script next.

## How to run
- In the root's directory, execute the following:
    ```sh
    chmod +x start-local.sh
    ./start-local.sh
    ```
    This script will deploy a kind cluster and a local registry, then it will deploy monitoring/logging stack(Prometheus/Grafana/Loki/Promtail/Alertmanager), then it will build the docker images of the workloads(backend/frontend), then it will rollout the deployments of the workloads, then lastly it will expose the services of Grafana/Alertmanager/Frontend and print out URL of each with the forwarded port.

- Get Grafana `admin` user password by running (I kept the default one, see the Tech-debts bellow):
    ```sh
    kubectl --namespace monitoring get secrets kps-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
    ```

## Tests
- to check your local registry
    ```sh
    chmod +x tests/test-local-registry.sh
    ./tests/test-local-registry.sh <REG_PORT>
    ```

## Tech debts
- !!IMPORTANT!! [Tech-debt] Trivy reports for the workloads images shows tons of High/Critical vulnerabilities:
    ```
    backend-app:v0.0.1 (debian 12.7)
    Total: 832 (HIGH: 791, CRITICAL: 41)
    ----
    frontend-app:v0.0.1 (debian 12.7)
    Total: 832 (HIGH: 791, CRITICAL: 41)
    ```
- [Tech-debt] The sizes of the docker images is so high (> 1G each)
- [Tech-debt] Harden docker images
- [Tech-debt] Customzie Grafana's admin creds secret


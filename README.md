# SRE_Project

Hands-on SRE lab: Kubernetes on **Docker Desktop** via Terraform.

## Layout

- `k8s/project/` — Terraform (`kubernetes` provider) deploying nginx into namespace `sre-apps`.

## Quick start

```bash
cd k8s/project
terraform init
terraform apply
kubectl get pods -n sre-apps
kubectl port-forward svc/nginx-sre-svc 8080:80 -n sre-apps
```

Requires a working `docker-desktop` kube context in `~/.kube/config`.

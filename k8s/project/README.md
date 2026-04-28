# Kubernetes Deployment using Terraform (Docker Desktop)

terraform init
terraform apply

kubectl get pods -n sre-apps
kubectl port-forward svc/nginx-sre-svc 8080:80 -n sre-apps

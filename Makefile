CLUSTER_NAME="multi-service-platform"
ARGO_NAMESPACE=argocd

.PHONY: help up clean status password

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

CLUSTER_NAME="multi-service-platform"

cluster:
	@echo "Set up Docker Desktop..."
	kubectl config use-context docker-desktop
	@echo "Creating namespaces..."
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
	@echo "Installing ArgoCD Server-Side..."
	kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Argo Workflow Installing..."
	kubectl apply -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.0/install.yaml
	@echo "Installing Nginx Ingress (Docker Desktop version)..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
	@echo "Bootstrapping root application..."
	kubectl apply -f bootstrap/root-app.yaml

argo-password:
	@echo Username: admin
	@powershell -Command "$$p = kubectl -n $(ARGO_NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath='{.data.password}'; $$decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($$p)); Write-Host \"Password: $$decoded\""

grafana-password:
	@echo Username: admin
	@powershell -Command "$$p = kubectl get secret -n monitoring -l 'app.kubernetes.io/name=grafana' -o jsonpath='{.items[0].data.admin-password}'; $$decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($$p)); Write-Host \"Password: $$decoded\""

grafana-restart:
	@echo Restarting grafana
	kubectl rollout restart deployment monitoring-grafana -n monitoring

localstack-api:
	@kubectl create namespace localstack --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create secret generic localstack-secrets \
		-n localstack \
		--from-literal=auth-token='$(TOKEN)' \
		--dry-run=client -o yaml | kubectl apply -f -

localstack-bucket-password:
	@echo Creating S3 credentials
	kubectl create secret generic my-s3-credentials --from-literal=accessKey=test --from-literal=secretKey=test -n argo

terraform-bucket:
	@echo Creating Bucket 
	cd terraform && terraform init && terraform apply -auto-approve	

vault-password:
	kubectl exec -it vault-0 -n vault -- vault operator init

velero-auth:
	@echo Creating Velero authentication 
	kubectl create secret generic velero-repo-credentials -n velero --from-literal=repository=$auth

velero-password:
	@echo Username/Password: admin/admin

download-report:
	@echo Downloading reports to D:/report
	aws --endpoint-url=http://localstack.local s3 cp s3://postgres-pdf D:/ --recursive

clean:
	@echo "🗑️ Cleaning up resources..."
	-kubectl delete namespace argocd argo
	@echo "🌐 Removing Ingress Controller..."
	-kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
	@echo "✨ Clean up complete!"
	
status:
	kubectl get pods -A

ingress:
	@echo Ingress apply
	kubectl apply -f infrastructure/argocd/argocd-ingress.yaml

# #!/bin/bash

# echo "Setting up port forwarding for all services..."

# # Kill any existing port forwards
# pkill -f "kubectl.*port-forward" || true

# # Start port forwarding in background
# echo "Starting Grafana on port 3000..."
# kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring > /dev/null 2>&1 &

# echo "Starting Prometheus on port 9090..."
# kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring > /dev/null 2>&1 &

# echo "Starting Loki on port 3100..."
# kubectl port-forward svc/loki 3100:3100 -n monitoring > /dev/null 2>&1 &

# echo "Starting cAdvisor on port 8080..."
# kubectl port-forward svc/cadvisor 8080:8080 -n monitoring > /dev/null 2>&1 &

# echo "Starting Elasticsearch on port 9200..."
# kubectl port-forward svc/elasticsearch-master 9200:9200 -n logging > /dev/null 2>&1 &

# echo "Port forwarding setup complete!"
# echo ""
# echo "Access your services at:"
# echo "- Grafana: http://localhost:3000 (admin/admin123)"
# echo "- Prometheus: http://localhost:9090"  
# echo "- Loki: http://localhost:3100"
# echo "- cAdvisor: http://localhost:8080"
# echo "- Elasticsearch: http://localhost:9200"
# echo ""
# echo "To stop port forwarding: pkill -f 'kubectl.*port-forward'"

# # start-ingress.sh
# #!/bin/bash

# echo "Starting ingress port forwarding for custom domains..."
# echo "This will forward localhost:8080 to your ingress controller"
# echo "Access your applications at: http://png.pickme:8080"
# echo ""
# echo "Press Ctrl+C to stop the port forwarding"
# echo ""

# kubectl port-forward svc/my-release-nginx-ingress-controller 8080:80 --context kind-lumpalumpa

# # 1.sh
# #!/bin/bash
# set -e

# echo "🚀 Starting simple Kind cluster setup..."

# if ! docker info > /dev/null 2>&1; then
#     echo "❌ Docker is not running. Please start Docker first."
#     exit 1
# fi

# echo "🧹 Cleaning up..."
# kind delete cluster --name trainee-inw 2>/dev/null || true
# sudo sed -i '' '/nginx.png.scbtechx/d' /etc/hosts 2>/dev/null || true

# echo "📝 Creating Kind config..."
# cat > kind-config.yaml << 'EOF'
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# nodes:
# - role: control-plane
#   kubeadmConfigPatches:
#   - |
#     kind: InitConfiguration
#     nodeRegistration:
#       kubeletExtraArgs:
#         node-labels: "ingress-ready=true"
#   extraPortMappings:
#   - containerPort: 80
#     hostPort: 80
#   - containerPort: 443
#     hostPort: 443
# EOF

# echo "🏗️  Creating cluster..."
# kind create cluster --name trainee-inw --config kind-config.yaml

# echo "📦 Pre-pulling and loading images..."
# docker pull nginx:latest
# kind load docker-image nginx:latest --name trainee-inw

# echo "🔧 Installing ingress-nginx via Helm..."
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update

# helm install nginx-ingress ingress-nginx/ingress-nginx \
#   --create-namespace \
#   --namespace ingress-nginx \
#   --set controller.service.type=NodePort \
#   --set controller.hostPort.enabled=true \
#   --set controller.admissionWebhooks.enabled=false \
#   --set controller.image.pullPolicy=IfNotPresent

# kubectl wait --namespace ingress-nginx \
#   --for=condition=ready pod \
#   --selector=app.kubernetes.io/name=ingress-nginx \
#   --timeout=300s

# echo "🚀 Deploying nginx app..."
# cat << 'EOF' | kubectl apply -f -
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: nginx-app
# spec:
#   replicas: 1
#   selector:
#     matchLabels:
#       app: nginx-app
#   template:
#     metadata:
#       labels:
#         app: nginx-app
#     spec:
#       containers:
#       - name: nginx
#         image: nginx:1.25-alpine
#         ports:
#         - containerPort: 80
# ---
# apiVersion: v1
# kind: Service
# metadata:
#   name: nginx-app-service
# spec:
#   selector:
#     app: nginx-app
#   ports:
#   - port: 80
#     targetPort: 80
#   type: ClusterIP
# ---
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: nginx-ingress
#   annotations:
#     nginx.ingress.kubernetes.io/rewrite-target: /
# spec:
#   ingressClassName: nginx
#   rules:
#   - host: nginx.png.scbtechx
#     http:
#       paths:
#       - path: /
#         pathType: Prefix
#         backend:
#           service:
#             name: nginx-app-service
#             port:
#               number: 80
# EOF

# kubectl wait --for=condition=ready pod -l app=nginx-app --timeout=120s

# echo "🔗 Adding hostname..."
# echo "127.0.0.1 nginx.png.scbtechx" | sudo tee -a /etc/hosts

# echo "🧪 Testing..."
# sleep 10
# curl -s http://nginx.png.scbtechx/ | grep -q "Welcome to nginx" && \
#   echo "✅ Success! Visit http://nginx.png.scbtechx/" || \
#   echo "⚠️  Setup complete but test failed"

# kubectl get ingress


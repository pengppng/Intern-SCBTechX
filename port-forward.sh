#!/bin/bash

echo "Setting up port forwarding for all services..."

# Kill any existing port forwards
pkill -f "kubectl.*port-forward" || true

# Start port forwarding in background
echo "Starting Grafana on port 3000..."
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring > /dev/null 2>&1 &

echo "Starting Prometheus on port 9090..."
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring > /dev/null 2>&1 &

echo "Starting Loki on port 3100..."
kubectl port-forward svc/loki 3100:3100 -n monitoring > /dev/null 2>&1 &

echo "Starting cAdvisor on port 8080..."
kubectl port-forward svc/cadvisor 8080:8080 -n monitoring > /dev/null 2>&1 &

echo "Starting Elasticsearch on port 9200..."
kubectl port-forward svc/elasticsearch-master 9200:9200 -n logging > /dev/null 2>&1 &

echo "Port forwarding setup complete!"
echo ""
echo "Access your services at:"
echo "- Grafana: http://localhost:3000 (admin/admin123)"
echo "- Prometheus: http://localhost:9090"  
echo "- Loki: http://localhost:3100"
echo "- cAdvisor: http://localhost:8080"
echo "- Elasticsearch: http://localhost:9200"
echo ""
echo "To stop port forwarding: pkill -f 'kubectl.*port-forward'"

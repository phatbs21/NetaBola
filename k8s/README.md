# Kubernetes Deployment

## Prerequisites
- kubectl configured
- Access to Kubernetes cluster
- Docker images built and pushed to registry

## Deploy
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/redis-statefulset.yaml
kubectl apply -f k8s/rabbitmq-statefulset.yaml
kubectl apply -f k8s/auth-service-deployment.yaml
kubectl apply -f k8s/auth-service-service.yaml
kubectl apply -f k8s/gateway-deployment.yaml
kubectl apply -f k8s/gateway-service.yaml
```

## Services
- api-gateway: LoadBalancer (port 80)
- auth-service: ClusterIP (port 8081)
- redis: StatefulSet (port 6379)
- rabbitmq: StatefulSet (port 5672)

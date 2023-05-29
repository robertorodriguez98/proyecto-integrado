# Proyecto Integrado - Despliegue de EKS usando Crossplane

## Instalaciones

### Crear cluster de k8s

```bash
kind create cluster
```

### ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Contraseña inicial

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d;echo
```

Port-forward

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80 --address=0.0.0.0
```

### Crossplane

```bash
helm repo add \
crossplane-stable https://charts.crossplane.io/stable
helm repo update
```

```bash
helm install crossplane \
crossplane-stable/crossplane \
--namespace crossplane-system \
--create-namespace
```

## Configuraciones

### Proveedores de Crossplane

#### AWS

```bash
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-aws:v0.39.0
EOF
```

Secret

```bash
kubectl create secret \
generic aws-creds \
-n crossplane-system \
--from-file=creds=./aws-credentials.txt
```

Providerconfig

```bash
cat <<EOF | kubectl apply -f -
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: creds
EOF
```

#### Kubernetes

```bash
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: crossplane-provider-kubernetes
spec:
  package: crossplane/provider-kubernetes:main
EOF
```

### Recursos gestionados

```bash
kubectl apply -f eks.yaml && kubectl apply -f definition.yaml
```

### Ngrok

```bash
ngrok http https://localhost:8080
```

### Webhook

(se añade la url de ngrok al repositorio)

## Demos

### Demo 1

Añadir 1 nodo al clúster usando Crossplane, demostración de que añadiéndolo por medio de la consola de EKS no funciona.

### Demo 2

Ejecutamos el script 

```bash
./configurar-k8s.sh
```

y desplegamos la aplicación 

```bash
kubectl apply -f despliegue-remoto.yaml
```

Para obtener la dirección de la aplicación desplegada:

```bash
k describe object loadbalancer-aplicacion-remoto | egrep "Hostname"
```
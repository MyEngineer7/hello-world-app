# Hello World Web Application

A containerized Hello World web application deployed to Kubernetes with Helm. 

## Documentation

1. Prerequisites
2. Step-by-step instructions for:
   - Building the container
   - Running locally with Docker
   - Deploying with Helm
3. Includes maintenance instructions

## Prerequisites

The following tools are required to build, run, and deploy this application:

### Docker
- **Windows/Mac**: Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Linux**:
  ```bash
  # Update package index
  sudo apt-get update
  
  # Install dependencies
  sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
  
  # Add Docker's official GPG key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  
  # Add Docker repository
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  
  # Install Docker
  sudo apt-get update
  sudo apt-get install docker-ce
  
  # Add your user to the docker group to run without sudo
  sudo usermod -aG docker $USER
  ```

### Docker Compose
- **Windows/Mac**: Included with Docker Desktop
- **Linux**:
  ```bash
  # Download Docker Compose
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  
  # Apply executable permissions
  sudo chmod +x /usr/local/bin/docker-compose
  ```

### kubectl
- **Windows**:
  ```bash
  # Using Chocolatey
  choco install kubernetes-cli
  ```
- **Mac**:
  ```bash
  # Using Homebrew
  brew install kubectl
  ```
- **Linux**:
  ```bash
  # Download kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  
  # Install kubectl
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  ```

### Helm 3.x
- **Windows**:
  ```bash
  # Using Chocolatey
  choco install kubernetes-helm
  ```
- **Mac**:
  ```bash
  # Using Homebrew
  brew install helm
  ```
- **Linux**:
  ```bash
  # Download and install Helm
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  ```

### Kubernetes Cluster

#### Minikube (Local Development)
- **All Platforms**:
  ```bash
  # Install Minikube
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 
  sudo install minikube-linux-amd64 /usr/local/bin/minikube

  curl.exe -Lo minikube.exe https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe
  
  # Start Minikube
  minikube start
 
Verify your installation by checking the version of each tool:
```bash
docker --version
docker-compose --version
kubectl version --client
helm version
```

## Building the Container

1. Build the Docker image:
   ```
   docker build -t hello-world-app:latest .
   ```

2. Verify the image was created:

   On Linux:
   ```
   docker images | grep hello-world-app
   ```
    On Windows PowerShell:
   ```
   docker images | where { $_ -like "*hello-world-app*" }
   ```

## Running Locally with Docker

### Option 1: Using Docker Run

1. Run the container:
   ```
   docker run -p 8000:8000 hello-world-app:latest
   ```

2. Access the application:
   - Open a web browser and navigate to http://localhost:8000
   - Or use curl: `curl http://localhost:8000`

3. Check the health endpoint:
   ```
   curl http://localhost:8000/health
   ```

### Option 2: Using Docker Compose (Recommended)

1. Start the application with enhanced security features:
   ```
   docker-compose up
   ```

2. Access the application:
   ```
   curl http://localhost:8000
   ```

3. Check the health endpoint:
   ```
   curl http://localhost:8000/health
   ```

4. Stop the application:
   ```
   docker-compose down
   ```

### Security Benefits of Docker Compose

Using Docker Compose provides additional security features in docker-compose.yml file:

- **Read-only filesystem**: Prevents runtime modifications to the container
- **Dropped capabilities**: Limits the Linux capabilities to minimum required
- **Resource limits**: Prevents resource exhaustion attacks
- **Temporary filesystems**: Provides controlled writable areas that reset on restart

## Deploying with Helm

### Preparing for Deployment

1. If using a remote cluster, tag and push the image to a registry:
   ```
   docker tag hello-world-app:latest <registry>/<username>/hello-world-app:latest
   docker push <registry>/<username>/hello-world-app:latest
   ```
   
   Then update the image reference in `hello-world-chart/values.yaml`.

2. If using Minikube, load the image into Minikube:
   ```
   minikube image load hello-world-app:latest
   ```

### Deployment Options

#### Development Deployment (Default)

```
helm install hello-world ./hello-world-chart
```

This uses the default values from `values.yaml` which are configured for a development environment.

#### Production Deployment

```
helm install hello-world ./hello-world-chart --values ./hello-world-chart/values-production.yaml
```

This applies production-specific settings including:
- 3 replicas instead of 2
- Horizontal Pod Autoscaler enabled
- Increased resource allocations
- More robust health checks
- Production-specific logging settings

### Verifying the Deployment

```
# Check the deployment
kubectl get deployments

# Check the pods
kubectl get pods

# Check the service
kubectl get services

# Check the HPA (if using production values)
kubectl get hpa
```

### Accessing the Application

- For cloud providers with LoadBalancer support:
  ```
  kubectl get service hello-world-app
  ```
  Access using the EXTERNAL-IP address provided
  
- For Minikube:
  ```
  minikube service hello-world-app
  ```

### Upgrading the Deployment

To update an existing deployment:

```
helm upgrade hello-world ./hello-world-chart
```

To switch from development to production:

```
helm upgrade hello-world ./hello-world-chart --values ./hello-world-chart/values-production.yaml
```

### Uninstalling the Deployment

```
helm uninstall hello-world
```

## Maintenance

### Updating the Application

1. Modify the application code
2. Rebuild the Docker image with a new tag
3. Update the image in the Helm values
4. Upgrade the Helm release

### Scaling

With Helm and Kubernetes:

```
# Manual scaling
kubectl scale deployment hello-world-app --replicas=4

# Or update the replicaCount in values.yaml and run:
helm upgrade hello-world ./hello-world-chart
```

In production, the Horizontal Pod Autoscaler will automatically scale based on CPU usage.

### Monitoring

Monitor the application health and logs:

```
kubectl logs -f deployment/hello-world-app
kubectl describe pods -l app=hello-world-app
```

## Environment Variables

The application uses environment variables for configuration:

- `ENVIRONMENT`: Set to "development" by default, "production" in production
- `LOG_LEVEL`: Controls logging verbosity (debug in development, info in production)
- `LOG_FORMAT`: Sets logging format (text in development, json in production)

These can be modified in the respective values files.








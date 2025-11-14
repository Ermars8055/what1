# 🧪 DevOps Lab Exam Preparation Guide

**Quick Reference – Minimal Code Version**

---

## ⚙️ Experiment 1 – Git Essentials

### Core Commands

```bash
git init
git add .
git commit -m "message"
git remote add origin <repo-url>
git remote -v
git push -u origin main
git pull origin main
```

### Branch & Pull Request

```bash
git checkout -b feature-branch
git add .
git commit -m "Added new feature"
git push origin feature-branch
```

On GitHub: Compare & Pull Request → Create PR → Merge

### Change Repository Visibility

GitHub → Settings → Danger Zone → Change visibility → Make private/public

---

## 🐳 Experiment 2 – Docker Containers and Images

### Check Docker

```bash
docker --version
docker run hello-world
```

### Project Setup

```bash
mkdir docker-demo && cd docker-demo
```

**index.html**
```html
<h1>Hello Docker</h1>
```

**Dockerfile**
```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/
EXPOSE 80
```

### Build & Run

```bash
docker build -t myweb:v1 .
docker run -d -p 8080:80 myweb:v1
# Access: http://localhost:8080
```

---

## 🧩 Experiment 3 – Flask App with Docker Hub

**Project Structure**
```
what1/
├── app.py
├── requirements.txt
├── Dockerfile
└── templates/
    └── index.html
```

**app.py**
```python
from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
```

**templates/index.html**
```html
<!DOCTYPE html>
<html>
  <head><title>Flask App</title></head>
  <body><h1>Hello from Flask + Docker!</h1></body>
</html>
```

**requirements.txt**
```
flask
```

**Dockerfile**
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5001
CMD ["python", "app.py"]
```

### Build & Run Commands

```bash
# Build the Docker image
docker build -t ashwinjoeoffl/flask-app:latest .

# Run the container
docker run -p 5001:5001 ashwinjoeoffl/flask-app:latest

# Access the app
# http://127.0.0.1:5001
```

### Important: Template Directory Structure

⚠️ **Common Issue**: Flask's `render_template()` looks for templates in a `templates/` subdirectory by default.

**Error Example:**
```
jinja2.exceptions.TemplateNotFound: index.html
```

**Solution**: Always create a `templates/` directory and place your HTML files there.

### Debug Steps if Template Not Found

1. **Verify project structure**:
   ```bash
   ls -la
   # Should show: app.py, requirements.txt, Dockerfile, templates/
   
   ls -la templates/
   # Should show: index.html
   ```

2. **Check Dockerfile copies all files**:
   ```dockerfile
   COPY . .  # This copies the entire project including templates/
   ```

3. **Rebuild the image** if structure changed:
   ```bash
   docker build -t ashwinjoeoffl/flask-app:latest .
   ```

4. **Run with verbose output** to see Flask's file lookup:
   ```bash
   docker run -p 5001:5001 ashwinjoeoffl/flask-app:latest
   # Look for errors like "TemplateNotFound" in the output
   ```

### Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag the image (if not already done)
docker tag ashwinjoeoffl/flask-app:latest ashwinjoeoffl/flask-app:latest

# Push to Docker Hub
docker push ashwinjoeoffl/flask-app:latest
```

---

## 🚀 Experiment 4 – CI Pipeline using GitHub Actions

### Workflow File: `.github/workflows/ci-dockerhub.yml`

```yaml
name: ci-dockerhub
on:
  push:
    branches: [ "main" ]
jobs:
  build-test-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install deps
        run: pip install -r requirements.txt
      - name: Run tests
        run: PYTHONPATH=. pytest -q
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Build and push image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/python-ci-lab:latest
```

### Secrets

Settings → Secrets → Actions → New secret

Add:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

---

## 🔧 Experiment 4 – Jenkins Static Site Deployment (Windows & Linux)

### Setup (Windows & Mac/Linux)

```bash
mkdir jenkins-static-site   
cd jenkins-static-site 
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - ./jenkins-config:/usr/share/jenkins/ref
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  jenkins_home:
    driver: local
```

### Commands (Windows PowerShell / Mac/Linux Terminal)

```bash
# Start Jenkins
docker compose up -d

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins at: http://localhost:8080
```

### If Error Occurs

```bash
# Stop and remove containers
docker compose down

# Start again
docker compose up -d
```

### Example Pipeline for Static Site

```groovy
pipeline {
  agent any
  stages {
    stage('Generate site') {
      steps {
        script {
          sh 'mkdir -p site'
          writeFile file: 'site/index.html', text: '<html><body><h1>Hello from Jenkins!</h1></body></html>'
        }
      }
    }
    stage('Publish site') {
      steps {
        publishHTML([
          reportDir: 'site',
          reportFiles: 'index.html',
          reportName: 'Static Site'
        ])
      }
    }
  }
}
```

---

## 🧪 Experiment 5 – Python CI/CD with Docker & GitHub Actions

### Project Structure

```
python-ci-docker-lab/
├── __init__.py
├── app.py
├── requirements.txt
├── Dockerfile
├── .gitignore
├── tests/
│   └── test_app.py
└── .github/
    └── workflows/
        └── ci-dockerhub.yml
```

### Step 1: Setup Project (Windows & Mac/Linux)

```bash
mkdir python-ci-docker-lab
cd python-ci-docker-lab
```

### Step 2: Create Python Files

**app.py**
```python
def add(a, b):
    return a + b

if __name__ == "__main__":
    print("Hello from Python CI Lab!")
    print("2 + 3 =", add(2, 3))
```

**tests/test_app.py**
```python
import sys
import os
# Add the project root to Python's module path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app import add

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
```

**requirements.txt**
```
pytest==8.3.2
```

**Dockerfile**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

**.gitignore**
```
__pycache__/
.venv/
.pytest_cache/
.DS_Store
*.pyc
```

**__init__.py** (empty file)
```
```

### Step 3: Create GitHub Actions Workflow

**`.github/workflows/ci-dockerhub.yml`**
```yaml
name: ci-dockerhub

on:
  push:
    branches: [ "main" ]
    tags: [ "*" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build-test-push:
    runs-on: ubuntu-latest
    steps:
      # Step 1: Checkout code
      - name: Checkout
        uses: actions/checkout@v4
      
      # Step 2: Set up Python 3.11
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      # Step 3: Install dependencies
      - name: Install deps
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      
      # Step 4: Run tests
      - name: Run tests
        run: pytest -q
      
      # Step 5: Set Docker image metadata
      - name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: your_dockerhub_username/python-ci-lab
          tags: |
            type=raw,value=latest,enable={{is_default_branch}}
            type=sha,prefix=sha-,format=short
            type=ref,event=tag
      
      # Step 6: Set up QEMU (for multi-arch builds)
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
      
      # Step 7: Set up Docker Buildx
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      # Step 8: Login to Docker Hub
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      # Step 9: Build and push the Docker image
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          platforms: linux/amd64
```

### Step 4: Test Locally (Optional)

```bash
# Test Python app
python app.py

# Run pytest
python -m pytest -q

# Build Docker image
docker build -t yourname/python-ci-lab:local .

# Run container
docker run --rm yourname/python-ci-lab:local
```

### Step 5: Initialize Git & Push

```bash
git init
git add .
git commit -m "init lab"
git branch -M main
git remote add origin https://github.com/<your-username>/python-ci-docker-lab.git
git push -u origin main

# If needed, retrigger CI/CD:
git commit --allow-empty -m "retrigger: fix Docker Hub login"
git push
```

### Step 6: Configure GitHub Secrets

1. Go to your repository on GitHub
2. Settings → Secrets and variables → Actions → New repository secret
3. Add two secrets:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username
   - `DOCKERHUB_TOKEN`: Your Docker Hub personal access token

### What This Workflow Does

✅ Test Python code using pytest  
✅ Build Docker image  
✅ Push image to Docker Hub automatically on every push to main branch  
✅ Tag images with latest and commit SHA  
✅ Support multi-platform builds (linux/amd64)

---

## ☸️ Experiment 6 – Kubernetes Management with CLI (Windows, Mac & Linux)

### Prerequisites

#### A. Install Docker
**Windows:**
1. Download and install Docker Desktop from [Docker's website](https://www.docker.com/products/docker-desktop)
2. Enable WSL2 backend during installation
3. Start Docker Desktop and ensure it is running

**Verify Docker installation:**
```bash
docker --version
```

#### B. Install kubectl (Kubernetes CLI)

**Windows (using Chocolatey):**
```powershell
choco install kubernetes-cli
```

**Mac (using Homebrew):**
```bash
brew install kubectl
```

**Verify installation:**
```bash
kubectl version --client
```

#### C. Install and Start Minikube

**Windows (using Chocolatey):**
```powershell
choco install minikube
minikube start --driver=docker
```

**Mac/Linux:**
```bash
brew install minikube
minikube start --driver=docker
```

**Verify the cluster is running:**
```bash
minikube status
kubectl get nodes
```

✅ If `kubectl get nodes` returns a node in **Ready** state — you are ready to go!

---

### 🧩 Step 1: Create a Simple Pod

Create a file: **nginx-pod.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

**Commands:**
```bash
# Apply the manifest
kubectl apply -f nginx-pod.yaml

# Check pod status
kubectl get pods
# Expected: nginx-pod 1/1 Running

# Describe the pod (detailed info)
kubectl describe pod nginx-pod

# Forward the port locally to access in browser
kubectl port-forward pod/nginx-pod 8080:80

# Then open http://localhost:8080 in your browser

# When done, delete the pod
kubectl delete pod nginx-pod
```

---

### 🧩 Step 2: Deployment and Scaling

**Create a deployment:**
```bash
kubectl create deployment my-nginx --image=nginx
```

**Check deployments and pods:**
```bash
kubectl get deployments
kubectl get pods -l app=my-nginx
```

**Scale to 3 replicas:**
```bash
kubectl scale deployment my-nginx --replicas=3
kubectl get pods
```

**Update the image (rolling update):**
```bash
kubectl set image deployment/my-nginx nginx=nginx:1.25
kubectl rollout status deployment/my-nginx
```

**If something goes wrong, rollback:**
```bash
kubectl rollout undo deployment/my-nginx
```

---

### 🧩 Step 3: Expose Deployment as a Service

**Expose the deployment using a NodePort service:**
```bash
kubectl expose deployment my-nginx --type=NodePort --port=80
kubectl get svc
```

**Get the URL of your app using Minikube:**
```bash
minikube service my-nginx --url
```

Open the displayed URL in your browser.

**Remove the service:**
```bash
kubectl delete svc my-nginx
```

---

### 🧹 Step 4: Cleanup

**After the lab, clean up all resources:**
```bash
kubectl delete deployment my-nginx
kubectl delete svc my-nginx
kubectl delete all --all -n default
```

**Stop or delete the cluster:**
```bash
minikube stop
minikube delete
```

---

### 🧾 Summary

In this lab, you learned how to:
1. ✅ Install Docker, kubectl, and Minikube (Windows, Mac, Linux)
2. ✅ Create and manage Pods
3. ✅ Deploy and scale applications
4. ✅ Expose Deployments as services
5. ✅ Clean up resources safely

---

## 🐍 Experiment 7 – Python App Deployment in Kubernetes

### Prerequisites
- Complete Experiment 5 (Python CI/Docker) first
- Push your Docker image to Docker Hub
- Ensure Minikube is running (from Experiment 6)

### Create Deployment Files

**python-deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: python-web
  template:
    metadata:
      labels:
        app: python-web
    spec:
      containers:
        - name: python-web
          image: your_dockerhub_username/python-ci-lab:latest
          ports:
            - containerPort: 5000
```

**python-service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: python-web-service
spec:
  type: NodePort
  selector:
    app: python-web
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
```

### Commands (Windows & Mac/Linux)

```bash
# Ensure Minikube is running
minikube start --driver=docker

# Apply the deployment
kubectl apply -f python-deployment.yaml

# Apply the service
kubectl apply -f python-service.yaml

# Check deployment status
kubectl get deployments
kubectl get pods

# Get the service URL
minikube service python-web-service --url

# View logs
kubectl logs -f deployment/python-web-deployment

# Cleanup when done
kubectl delete deployment python-web-deployment
kubectl delete svc python-web-service
```

---

## 🧠 Experiment 8 – Ansible + Kubernetes (Linux/Mac/WSL2 on Windows)

### Install Ansible

**Mac (using Homebrew):**
```bash
brew install ansible
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y ansible
```

**Windows (using WSL2):**
```bash
wsl --install -d Ubuntu
# Inside WSL2:
sudo apt update
sudo apt install -y ansible
```

### Install Kubernetes Collection

```bash
ansible-galaxy collection install community.kubernetes
```

### Test Kubernetes Connection

**test-k8s.yaml**
```yaml
---
- name: Test Kubernetes Connection
  hosts: localhost
  connection: local
  tasks:
    - name: List all pods
      community.kubernetes.k8s_info:
        kind: Pod
      register: pod_list
    - debug:
        msg: "{{ pod_list.resources | map(attribute='metadata.name') | list }}"
```

**Run the playbook:**
```bash
ansible-playbook test-k8s.yaml
```

---

## 🧨 Experiment 9 – Deploy Flask App via Ansible (Linux/Mac/WSL2)

### Prerequisites
- Ansible installed (from Experiment 8)
- Python 3 and pip installed
- Flask app ready (from Experiment 5)

### Inventory File

**inventory.ini**
```ini
[local]
localhost ansible_connection=local
```

### Playbook

**playbook.yml**
```yaml
---
- hosts: local
  become: true
  vars:
    app_root: "/opt/ansible_flask_app"
    venv_path: "{{ app_root }}/venv"
  tasks:
    - name: Create app directory
      file:
        path: "{{ app_root }}"
        state: directory
        mode: '0755'
    
    - name: Copy app source
      copy:
        src: "src_app/"
        dest: "{{ app_root }}/"
    
    - name: Create virtual environment
      command: "python3 -m venv {{ venv_path }}"
    
    - name: Install dependencies
      command: "{{ venv_path }}/bin/pip install -r {{ app_root }}/requirements.txt"
    
    - name: Create systemd service file
      template:
        src: "ansible-flask.service.j2"
        dest: "/etc/systemd/system/ansible-flask.service"
    
    - name: Start and enable service
      systemd:
        name: ansible-flask.service
        state: started
        enabled: true
```

### Systemd Service Template

**ansible-flask.service.j2**
```ini
[Unit]
Description=Ansible Flask Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory={{ app_root }}
ExecStart={{ venv_path }}/bin/python app.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Run the Playbook

```bash
# Test connectivity first
ansible all -i inventory.ini -m ping

# Run the playbook (will prompt for sudo password)
ansible-playbook -i inventory.ini playbook.yml -K

# Check service status
sudo systemctl status ansible-flask.service

# View logs
sudo journalctl -u ansible-flask.service -f

# Access the app
curl http://127.0.0.1:5000
```

---

## 🧱 Experiment 10 – Ansible for Docker & Kubernetes (Windows, Mac & Linux)

### Prerequisites
- Ansible installed
- Docker running
- Minikube running (for K8s exercises)

### Collections Installation

**requirements.yml**
```yaml
collections:
  - community.docker
  - kubernetes.core
```

**Install collections:**
```bash
ansible-galaxy install -r requirements.yml
```

### Inventory File

**inventory.ini**
```ini
[local]
127.0.0.1 ansible_connection=local
```

### Docker Management Playbook

**docker.yml**
```yaml
---
- hosts: local
  become: true
  tasks:
    - name: Install Docker (Ubuntu/Debian)
      block:
        - name: Update apt cache
          apt:
            update_cache: yes
        - name: Install Docker
          apt:
            name: docker.io
            state: present
      when: ansible_os_family == "Debian"
    
    - name: Start Docker service
      systemd:
        name: docker
        state: started
        enabled: true
    
    - name: Run NGINX container
      community.docker.docker_container:
        name: web
        image: nginx:alpine
        state: started
        ports:
          - "8080:80"
        restart_policy: always
```

### Kubernetes Management Playbook

**k8s.yml**
```yaml
---
- hosts: local
  connection: local
  tasks:
    - name: Ensure Minikube cluster exists
      shell: minikube status | grep -q "Running" || minikube start --driver=docker
    
    - name: Create NGINX deployment
      kubernetes.core.k8s:
        name: nginx-deployment
        api_version: apps/v1
        kind: Deployment
        namespace: default
        state: present
        definition:
          metadata:
            name: nginx-deployment
          spec:
            replicas: 2
            selector:
              matchLabels:
                app: nginx
            template:
              metadata:
                labels:
                  app: nginx
              spec:
                containers:
                  - name: nginx
                    image: nginx:latest
                    ports:
                      - containerPort: 80
    
    - name: Expose NGINX via service
      kubernetes.core.k8s:
        name: nginx-service
        api_version: v1
        kind: Service
        namespace: default
        state: present
        definition:
          metadata:
            name: nginx-service
          spec:
            type: NodePort
            selector:
              app: nginx
            ports:
              - protocol: TCP
                port: 80
                targetPort: 80
    
    - name: Get service URL
      shell: minikube service nginx-service --url
      register: service_url
    
    - name: Display service URL
      debug:
        msg: "NGINX is available at: {{ service_url.stdout }}"
```

### Run the Playbooks

**Test connectivity:**
```bash
ansible all -i inventory.ini -m ping
```

**Run Docker management:**
```bash
ansible-playbook -i inventory.ini docker.yml -K
```

**Run Kubernetes management:**
```bash
ansible-playbook -i inventory.ini k8s.yml
```

**Verify deployments:**
```bash
# Docker containers
docker ps

# Kubernetes pods
kubectl get pods
kubectl get svc
```

**Cleanup:**
```bash
# Delete Docker container
docker stop web && docker rm web

# Delete Kubernetes resources
kubectl delete deployment nginx-deployment
kubectl delete svc nginx-service
```

---

## 🧭 Quick Reference Summary

| Tool | Key Commands |
|------|--------------|
| Git | init → add → commit → push → branch |
| Docker | build → run → push → pull |
| Kubernetes | apply → get pods → expose → minikube service |
| Ansible | ansible-playbook -i inventory file.yml |
| Jenkins | pipeline → stages → steps → publishHTML |
| CI/CD | .github/workflows with build → test → push |

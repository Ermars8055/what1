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

## 🔧 Experiment 5 – Jenkins Deployment via Docker

**docker-compose.yml**
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
volumes:
  jenkins_home:
```

### Commands

```bash
docker compose up -d
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
# Access: http://localhost:8080
```

### Example Pipeline

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

## ☸️ Experiment 6 – Kubernetes with Minikube

```bash
minikube start --driver=docker
kubectl get nodes
```

**nginx-pod.yaml**
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

### Commands

```bash
kubectl apply -f nginx-pod.yaml
kubectl get pods
kubectl port-forward pod/nginx-pod 8080:80
```

---

## 🐍 Experiment 7 – Python App Deployment in Kubernetes

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
          image: username/flaskimage:1.0
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

### Commands

```bash
minikube start --driver=docker
kubectl apply -f python-deployment.yaml
kubectl apply -f python-service.yaml
minikube service python-web-service --url
```

---

## 🧠 Experiment 8 – Ansible + Kubernetes

### Install

```bash
sudo apt update
sudo apt install -y ansible
ansible-galaxy collection install community.kubernetes
```

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

---

## 🧨 Experiment 9 – Deploy Flask App via Ansible

**inventory.ini**
```ini
[local]
localhost ansible_connection=local
```

**playbook.yml (simplified)**
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
    - name: Copy app source
      copy:
        src: "src_app/"
        dest: "{{ app_root }}/"
    - name: Create venv and install deps
      command: "{{ venv_path }}/bin/pip install -r {{ app_root }}/requirements.txt"
    - name: Start service
      systemd:
        name: ansible-flask.service
        state: started
        enabled: true
```

### Run

```bash
ansible-playbook playbook.yml -K
sudo systemctl status ansible-flask.service
curl http://127.0.0.1:8000
```

---

## 🧱 Experiment 10 – Ansible for Docker & Kubernetes

**inventory.ini**
```ini
[local]
127.0.0.1 ansible_connection=local
```

**requirements.yml**
```yaml
collections:
  - community.docker
  - kubernetes.core
```

**docker.yml**
```yaml
---
- hosts: local
  become: true
  tasks:
    - name: Run NGINX container
      community.docker.docker_container:
        name: web
        image: nginx:alpine
        published_ports:
          - "8080:80"
```

**k8s.yml**
```yaml
---
- hosts: local
  become: true
  tasks:
    - name: Create Kind cluster
      shell: kind get clusters | grep -q '^simple$' || kind create cluster --name simple
    - name: Apply NGINX deployment
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', 'k8s-nginx.yaml') | from_yaml_all | list }}"
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

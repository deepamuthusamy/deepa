# Blue-Green CI/CD Pipeline for JSP Web Application on AWS

## 📌 Project Overview

This project sets up a **CI/CD pipeline** using AWS native services (CodePipeline, CodeBuild, CodeDeploy) to deploy a **Maven-based JSP web application** hosted on **Apache Tomcat on EC2**, using **Blue-Green deployment** strategy with **Auto Scaling** and a **Classic Load Balancer (CLB)**.

---

## ⚙️ CI/CD Architecture and Flow

```
GitHub (Source Code)
      |
      v
AWS CodePipeline
 ├── Source Stage (GitHub)
 ├── Build Stage (CodeBuild: mvn clean package)
 └── Deploy Stage (CodeDeploy: Blue-Green to EC2 ASGs behind CLB)
```

### Flow Description:

1. **Source Stage**:  
   Triggers on every new commit to the GitHub repository. It fetches the latest source code.

2. **Build Stage (CodeBuild)**:  
   - Runs `mvn clean package` using `buildspec.yml`
   - Packages `hello-jsp.war`
   - Prepares `appspec.yml` and deployment scripts (`start_server.sh`)

3. **Deploy Stage (CodeDeploy)**:  
   - Blue-Green deployment strategy
   - Deploys the new WAR to the **Green Auto Scaling Group**
   - Tests application via **CLB test listener**
   - On success, shifts traffic from **Blue** to **Green**
   - Blue becomes idle (ready for next deployment cycle)

---

## ☁️ AWS Resources Used

| Resource           | Purpose                                                |
|--------------------|--------------------------------------------------------|
| **EC2**            | Hosts Apache Tomcat with JSP app                       |
| **Launch Template**| Installs Java, Tomcat, and CodeDeploy agent via UserData |
| **Auto Scaling Groups** | Blue and Green environments for deployment        |
| **Classic Load Balancer** | Distributes HTTP traffic and allows CLB shifting |
| **CodePipeline**   | Orchestrates the CI/CD flow                            |
| **CodeBuild**      | Compiles JSP Maven app and generates artifacts         |
| **CodeDeploy**     | Handles Blue-Green deployment via Deployment Group     |
| **IAM Roles**      | Grants permissions to each service                     |
| **S3 (optional)**  | Stores build artifacts (managed by CodePipeline)       |
| **CloudWatch Logs**| Logs from CodeBuild and CodeDeploy                     |

---

## 🔁 Blue/Green Deployment Mechanics

| Phase              | Blue ASG                | Green ASG               |
|--------------------|-------------------------|--------------------------|
| **Initial State**  | Receives production traffic | Idle (not in use)      |
| **Deploy New Build** | Unchanged              | New WAR deployed        |
| **Testing**        | Still Live              | Tested via CLB hook     |
| **Switch Traffic** | Idle (standby)          | Live (receives traffic) |

- Deployment type: `Blue/Green`
- Load Balancer listener updates are **automatic**
- Ensures **zero downtime** deployments
- Easy rollback by reverting to Blue

---

## 📁 Repository Structure

```
.
├── src/
│   └── main/webapp/index.jsp
├── pom.xml
├── buildspec.yml
├── appspec.yml
└── scripts/
    └── start_server.sh
```

---

## ⚠️ Known Issues / Manual Steps

| Issue / Step | Details |
|--------------|---------|
| **Port 80 binding** | Tomcat runs on port 80, so EC2 security group must allow inbound HTTP (port 80) |
| **Startup Timing** | Tomcat startup script may take time, CodeDeploy may need `wait` logic |
| **CLB Target Health** | Ensure health check URL `/` is working or adjust to custom path if needed |
| **Manual cleanup** | After several deployments, clean up old ASGs and instances to stay in free tier |
| **Blue-Green rotation** | Automatically handled by CodeDeploy, but verify manually via CLB DNS if needed |
| **GitHub Connection** | CodePipeline GitHub (V2) integration may need re-auth after 60 days (OAuth token) |
| **Tomcat permissions** | User `ec2-user` needs permission to run `/opt/tomcat/bin/startup.sh` (already handled in UserData) |

---

## ✅ How to Test

1. Push a commit to GitHub (modify `index.jsp`)
2. Watch CodePipeline run all stages
3. Check CodeDeploy switching traffic to new version
4. Open CLB DNS name in browser — app should reflect changes


---

## 👥 Author

Kishore SR

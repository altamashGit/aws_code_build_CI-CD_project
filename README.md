# 🚀 AWS CodeBuild CI/CD Pipeline with ECS & Fargate

This project demonstrates a robust, automated **CI/CD pipeline** that streamlines the deployment of containerized applications to AWS. By leveraging **GitHub Actions**, **Amazon ECR**, and **AWS CodeBuild**, we ensure that every code push is built, scanned, and deployed to a serverless **ECS Fargate** environment.

---

## 🛠 Tech Stack
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

| Component | Service Used |
| :--- | :--- |
| **Source Control** | GitHub |
| **Artifact Registry** | Amazon ECR (Elastic Container Registry) |
| **Build Tool** | AWS CodeBuild |
| **Orchestration** | Amazon ECS (Elastic Container Service) |
| **Compute** | AWS Fargate (Serverless) |

---
## Architecture Diagram

<img width="1741" height="794" alt="Screenshot 2026-05-05 014020" src="https://github.com/user-attachments/assets/6ec5f655-2583-429a-8f57-3624e6258eae" />

---
## 🏗 Workflow Architecture

The automation follows these six critical steps:

1.  **Code Push**: Developer pushes code to the `main` branch on GitHub.
2.  **ECR Setup**: Create an **Elastic Container Registry** repository and copy the **URI**.
3.  **Task Definition**: Define the blueprint for the application (pasting the ECR URI into the container definitions).
4.  **ECS Service**: Create a service to maintain the desired count of running tasks.
5.  **Fargate Launch**: Deploy the containers using the **Fargate** launch type (No EC2 instances to manage!).
6.  **CodeBuild Automation**: Configure **AWS CodeBuild** with ECR credentials to automate the `docker build`, `tag`, and `push` phases.

---
## 🧠 Architectural Deep-Dive: The "How" & "Why"

This project automates the manual infrastructure patterns established in my [Reference Repository](https://github.com/altamashGit/ECR-ECS-Project--aws-ecs-fargate-project-). Below is the technical breakdown of the core components:

### 📦 1. Amazon ECR (Registry)
* **How:** Acts as a private version-controlled storage for Docker images.
* **Why:** Unlike public registries, [Amazon ECR](https://github.com/altamashGit/ECR-ECS-Project--aws-ecs-fargate-project-#-what-is-amazon-ecr) provides high-availability and security within the AWS network, ensuring ECS can pull images faster and more securely using internal AWS backbone traffic.

### 🔐 2. IAM Roles (Security Bridge)
* **How:** We use an **ECS Task Execution Role** with the `AmazonECSTaskExecutionRolePolicy`.
* **Why:** In AWS, services do not talk to each other by default. As explained in the [IAM Setup Guide](https://github.com/altamashGit/ECR-ECS-Project--aws-ecs-fargate-project-#-why-iam-role-is-required), this role is the "Security Bridge" that gives the ECS agent permission to pull images from ECR and send logs to CloudWatch without hardcoding credentials.

### 🚢 3. Amazon ECS & Fargate (Orchestration)
* **How:** * **Task Definition:** The blueprint (CPU, Memory, Image URI).
    * **Service:** The manager that maintains our "Desired Count" of containers.
* **Why:** By using [AWS Fargate](https://github.com/altamashGit/ECR-ECS-Project--aws-ecs-fargate-project-#-what-is-aws-fargate), we achieve a **Serverless** architecture. This removes the "Undifferentiated Heavy Lifting" of managing EC2 instances, patching OS, or scaling servers manually.

---

### 🚀 Evolution: Manual to Automated
| Feature | Manual Method ([View Reference](https://github.com/altamashGit/ECR-ECS-Project--aws-ecs-fargate-project-)) | Automated CI/CD (This Project) |
| :--- | :--- | :--- |
| **Image Build** | Manual `docker build` on EC2 | **AWS CodeBuild** (Serverless Build) |
| **Authentication** | Manual `aws ecr login` | Automated via **IAM Build Roles** |
| **Deployment** | Manual Task Update | **GitHub Actions** auto-triggers deployment |
---
## 🚀 Getting Started

### Prerequisites
* An active **AWS Account**.
* **AWS CLI** configured locally.
* A `Dockerfile` present in the root directory.

### Quick Deployment Steps
> [!IMPORTANT]
> Ensure your IAM roles for CodeBuild have the `AmazonEC2ContainerRegistryPowerUser` policy attached.

1. **Clone the Repo**
   ```bash
   git clone [https://github.com/altamashGit/aws_code_build_CI-CD_project.git](https://github.com/altamashGit/aws_code_build_CI-CD_project.git)
   cd aws_code_build_CI-CD_project

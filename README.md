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

<img width="1699" height="773" alt="Screenshot 2026-05-08 191617" src="https://github.com/user-attachments/assets/69280371-5329-4b9b-81fb-41abeb137a57" />


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

---
## 🏗️ Advanced Infrastructure & Networking

This project extends beyond simple builds into a production-grade networking stack involving Load Balancers, SSL/TLS certificates, and DNS mapping.

### 1. 🔐 IAM Security Roles
To allow these services to communicate, the following roles are configured:
* **CodeBuild Service Role**: Permissions for `ecr:PutImage` and `ecr:GetAuthorizationToken`.

```bash
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"ecr:GetAuthorizationToken",
				"ecr:BatchCheckLayerAvailability",
				"ecr:GetDownloadUrlForLayer",
				"ecr:GetRepositoryPolicy",
				"ecr:DescribeRepositories",
				"ecr:ListImages",
				"ecr:DescribeImages",
				"ecr:BatchGetImage",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload",
				"ecr:PutImage"
			],
			"Resource": "arn:aws:ecr:us-east-1:335357805095:repository/awebsite-ws_code_build"
		},
		{
			"Effect": "Allow",
			"Action": "ecr:GetAuthorizationToken",
			"Resource": "*"
		}
	]
}
```
  
* **ECS Task Execution Role**: Attached with `AmazonECSTaskExecutionRolePolicy` to pull images from ECR.
* **ALB Service Linked Role**: Automatically created to allow the Load Balancer to manage network interfaces.

---

---

## 🏗️ CI/CD Pipeline Configuration

This project uses a fully automated pipeline to build, push, and deploy the application.


<img width="1611" height="980" alt="git push buildspec" src="https://github.com/user-attachments/assets/6f398afe-59f9-49a7-a0f7-661e16801554" />


### 1. 🔨 AWS CodeBuild (Continuous Integration)
The `buildspec.yaml` handles the Docker lifecycle:
* **Pre-Build**: Log in to Amazon ECR.
* **Build**: Build the Docker image and tag it as `latest`.
* **Post-Build**: Push the image to the ECR repository and create an `imagedefinitions.json` artifact for deployment.

### buildspec.yaml
```bash
version: 0.2

  phases:
    pre_build:
      commands:
       - echo logging to AMAZON ECR `date`
       - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
    build:
      commands:
        - echo docker build images `date`
        - docker build -t $IMAGE_REPO_NAME:$IMAGE_ID .
        - echo "Tagging ECR images"
        - docker tag $IMAGE_REPO_NAME:$IMAGE_ID $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_ID
    post_build:
     commands:
      - echo docker image push to ECR `date`
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_ID
```

### Code Build Env Variable

<img width="1838" height="520" alt="code build env variable" src="https://github.com/user-attachments/assets/4939622e-f286-485e-8a6e-be983f9f87ca" />

### Code Build

<img width="1634" height="505" alt="code-pipeline" src="https://github.com/user-attachments/assets/62e854a9-4e44-4951-a20a-8fadc5690752" />

---

### 2. 🚀 AWS CodeDeploy (Continuous Delivery)
CodeDeploy manages the update of the ECS Service:
* **Deployment Type**: Blue/Green (or Rolling Update).
* **AppSpec**: Defines how the ECS task should be updated and which container port to use.
* **Traffic Shifting**: Controlled via the Application Load Balancer to ensure zero downtime.

### Code Pipeline Git intergration Setup

<img width="1744" height="850" alt="codepipeline-git-webhook setup" src="https://github.com/user-attachments/assets/ab9ed7e7-3e6e-4938-9c91-704c56adc08a" />

### Code Pipeline

<img width="1758" height="789" alt="s3-build-artifact" src="https://github.com/user-attachments/assets/44b09ba4-3e8c-48dd-abc9-619580476c00" />


---

## 🌐 Networking & DNS Access

### Accessing without a Domain Name
Initially, you can access the app via the **ALB DNS Name**:
1. Go to **EC2 Dashboard** -> **Load Balancers**.
2. Copy the **DNS name** (e.g., `my-alb-12345.us-east-1.elb.amazonaws.com`).
3. Access: `http://<ALB-DNS-NAME>`


<img width="1505" height="807" alt="Screenshot 2026-05-08 202410" src="https://github.com/user-attachments/assets/c48db3d3-b3b3-4649-84cb-093494946361" />


---

## 🔒 Secure HTTPS & Domain Mapping

To move from HTTP to a secure **HTTPS** connection with a custom domain:

### Step 1: SSL Certificate (ACM)
Request a certificate in **AWS Certificate Manager** for your domain (e.g., `space.alatamsh.cloud`).   
<img width="1770" alt="certificate-manager" src="https://github.com/user-attachments/assets/b7b722a3-0a89-4098-9248-406652013074" />

### Step 2: Route 53 Mapping
Create an **A Record** (Alias) pointing your domain to the ALB DNS name.   
<img width="1311" alt="domain-mapping" src="https://github.com/user-attachments/assets/5a7980ec-dd6a-4b53-a3a4-87bf5cf1ee16" />

### Step 3: HTTPS Listener & Redirection
1. **HTTPS (443)**: Add a listener using the ACM certificate.
2. **HTTP (80)**: Configure a redirect rule to forward all traffic to Port 443.
3. 
<img width="1594" alt="listener-rules" src="https://github.com/user-attachments/assets/5fe6dbd6-2f6f-4153-b660-ee57ab2f2524" />

---
### Build Artiface on S3

<img width="1758" height="789" alt="s3-build-artifact" src="https://github.com/user-attachments/assets/e9ff1f08-18be-44e6-ad61-0ec44c08af3b" />

### CloudWatch logs

<img width="1917" height="878" alt="logs cloud watch" src="https://github.com/user-attachments/assets/1fb8063b-5d5b-4868-8a85-d162c0f8a078" />


---

## 📸 Final Deployment Status

### ECS Service Health
The Fargate tasks are running across multiple AZs, managed by the ECS Service.   
<img width="1760" alt="ecs-service-status" src="https://github.com/user-attachments/assets/0cbef0bb-9d0d-4d8f-8d10-77a90be6193e" />

### Verified Secure Connection

The application is now live and secure with a valid SSL certificate.  
<img width="1906" height="881" alt="secure browser" src="https://github.com/user-attachments/assets/b0579f5c-5b90-4e7f-beec-4a2a277ddcc8" />

---

## 🏁 Conclusion & Future Enhancements

This project successfully demonstrates a production-ready **CI/CD pipeline** on AWS. By integrating **CodeBuild** and **CodeDeploy** with **ECS Fargate**, the application benefits from automated scaling, high availability, and secure delivery via SSL/TLS.

### Key Achievements:
* **Zero Downtime**: Rolling updates managed by CodeDeploy.
* **Security First**: Forced HTTPS redirection and IAM least-privilege roles.
* **Scalability**: Serverless execution using AWS Fargate.

---

## 🧹 Cleanup (Cost Optimization)

To avoid unexpected AWS charges, ensure you delete or disable the following resources if this project is a demo:

### 🚀 Compute & Networking
* **ECS Service & Tasks**: 
* **Application Load Balancer (ALB)**: Delete the Load Balancer and associated **Target Groups**.
* **Route 53 & AWS ACM**: Delete the **Alias Record** (A Record) pointing to the ALB.

### 🔨 CI/CD Pipeline
* **AWS CodePipeline**: Delete the pipeline to stop automatic execution and polling.
* **AWS CodeBuild**: Remove the build project to prevent unauthorized builds.
* **S3 Bucket**: Empty and delete the bucket used for **CodePipeline Artifacts** (e.g., `codepipeline-us-east-1-xxxx`).

### 📦 Storage & Security
* **Amazon ECR**: Delete the repository or remove all stored Docker images to stop storage costs.
* **ACM Certificate**: (Optional) Delete the SSL certificate if it is no longer required for other projects.
* **CloudWatch Logs**: Delete the log groups created by ECS and CodeBuild to clean up storage.

---

## 👤 Author

**Altamash Alam**
* **LinkedIn**: [Altamash Alam](https://www.linkedin.com/in/altamash-alam-129969289/)
* **GitHub**: [@altamashGit](https://github.com/altamashGit)

---

*If you found this project helpful, give it a ⭐!*

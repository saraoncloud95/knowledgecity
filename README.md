# 🌍 KnowledgeCity Multi-Region AWS Architecture

<img width="7180" height="4420" alt="Blank diagram (2)" src="https://github.com/user-attachments/assets/6478927d-0795-434e-a1f9-9d5055be1702" />

> A highly available, secure, and scalable AWS architecture designed for a global educational platform, addressing multi-region deployment, high availability, video processing, and data sovereignty for both US and Middle East (ME-South) regions.

---

## 📘 Project Overview

This architecture is designed as part of the **Senior DevOps Engineer Test Task** for **KnowledgeCity**. It represents a real-world, production-grade, multi-region cloud infrastructure optimized for performance, scalability, security, and cost-efficiency.

---

## 🧩 Core Architecture Components

### 🌐 Front-End Delivery
- **Single Page Application (SPA)** hosted on Amazon EKS
- Delivered globally via **Amazon CloudFront**
- Geo-routed using **Amazon Route 53** for latency-based routing and health checks

### 🐘 Backend Services
- **Monolithic PHP application** running in containers on Amazon EKS
- **Analytics Microservice** using **ClickHouse** for real-time interaction tracking
- **Video Conversion Microservice** deployed on EKS for transcoding uploaded videos

---

## 🌍 Multi-Region Deployment

- **Primary Region**: `us-east-1` (for U.S. users and content)
- **Secondary Region**: `me-south-1` (for Saudi Arabia and Middle East users)
- Each region includes:
  - 3 **Public Subnets** with IGWs, ALBs, and NAT Gateways
  - 3 **Private Subnets** hosting EKS Pods
  - 3 **DB Subnets** with RDS and ClickHouse
- **Cross-Region Replication** for S3 and RDS to ensure compliance and redundancy

---

## 🔒 Security Architecture

- **AWS WAF**: Protects web apps against OWASP threats
- **AWS Shield**: DDoS mitigation
- **Amazon GuardDuty**: Continuous threat detection
- **AWS KMS**: Encryption key management
- **IAM**: Role-based access control
- **Private Subnets**: All compute, databases, and services isolated from the public internet

---

## 📈 Observability & Monitoring

- **Amazon CloudWatch**: Logs, metrics, and alarms
- **Prometheus & Grafana**: Application-level metrics and dashboards
- **Amazon SNS**: Notification system for alerts and monitoring
- **(Optional)** Integration with **OpenTelemetry**, **CloudTrail**, or **ELK/EFK**

---

## 🎥 Media Storage & Delivery

- Users upload raw videos to **Amazon S3**
- **Video Processing Microservice** (in EKS) converts them into optimized formats
- Final assets delivered via **CloudFront**, with **S3 Lifecycle Policies** for tiered storage

---

## ⚙️ Scalability & Cost Optimization

- **EKS Cluster Autoscaler** with Spot and On-Demand Instances
- **S3 Cross-Region Replication** + lifecycle management
- **CDN caching** for global asset delivery
- Infrastructure is modular and **ready for Terraform/IaC integration**

---

## ✅ SLA, Compliance & Data Residency

- 99.99% availability with **multi-AZ redundancy**
- Saudi user data stored in **me-south-1**, U.S. data in **us-east-1**
- Easily adaptable to GDPR, HIPAA, or future regulatory changes

---

## 📌 Technologies Used

| Category          | Services/Tools                        |
|-------------------|---------------------------------------|
| Compute           | Amazon EKS (Kubernetes)               |
| Storage           | Amazon S3, Lifecycle Policies         |
| Database          | Amazon RDS (MySQL), ClickHouse        |
| Networking        | VPC, NAT, IGW, ALB                    |
| Security          | WAF, Shield, GuardDuty, KMS, IAM      |
| Monitoring        | CloudWatch, Prometheus, Grafana, SNS |
| CDN / DNS         | CloudFront, Route 53                  |
| Cost Optimization | Spot Instances, S3 Tiering            |

---

## 🛡️ Architecture Diagram

> See `DEVOPSTASK.png` above for a detailed view of the entire multi-region setup.

---

## 👩‍💻 Author

**Sara Taha**  
Senior DevOps Engineer  
📍 Jordan | 🌍 Remote-Friendly  
🚀 Passionate about cloud architecture, observability, and scalable systems.

---

## 📄 License

This project is for demonstration purposes as part of a test task. All rights reserved.

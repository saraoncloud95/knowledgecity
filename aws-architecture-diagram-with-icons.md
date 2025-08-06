# 🏗️ **KnowledgeCity AWS Architecture Diagram**

## **🌍 Multi-Region AWS Infrastructure Overview**

```mermaid
graph TB
    %% AWS Icons and Services
    subgraph "🌍 AWS Global Infrastructure"
        subgraph "🇺🇸 US-East-1 (Primary Region)"
            subgraph "🏢 VPC: 10.0.0.0/16"
                subgraph "🌐 Public Subnets"
                    subgraph "📡 Public Subnet 1 (10.0.1.0/24)"
                        IGW1["🌐<br/>Internet Gateway"]
                        NAT1["🌐<br/>NAT Gateway"]
                        ALB1["⚖️<br/>Application Load Balancer<br/>Port 80/443"]
                    end
                    subgraph "📡 Public Subnet 2 (10.0.2.0/24)"
                        NAT2["🌐<br/>NAT Gateway"]
                    end
                    subgraph "📡 Public Subnet 3 (10.0.3.0/24)"
                        NAT3["🌐<br/>NAT Gateway"]
                    end
                end
                
                subgraph "🏠 Private Subnets"
                    subgraph "🏠 Private Subnet 1 (10.0.11.0/24)"
                        EKS1["🐳<br/>EKS Node Group 1<br/>t3.micro/small<br/>General Purpose"]
                        APP1["🚀<br/>Application Pods<br/>Web Services"]
                    end
                    subgraph "🏠 Private Subnet 2 (10.0.12.0/24)"
                        EKS2["🐳<br/>EKS Node Group 2<br/>t3.micro/small<br/>General Purpose"]
                        APP2["🚀<br/>Application Pods<br/>API Services"]
                    end
                    subgraph "🏠 Private Subnet 3 (10.0.13.0/24)"
                        EKS3["🐳<br/>EKS Node Group 3<br/>t3.small/medium<br/>Video Processing"]
                        APP3["🎥<br/>Video Processing Pods<br/>Transcoding Services"]
                    end
                end
                
                subgraph "🗄️ Database Subnets"
                    subgraph "🗄️ DB Subnet 1 (10.0.21.0/24)"
                        RDS1["🐘<br/>RDS MySQL Primary<br/>db.t3.micro<br/>Multi-AZ"]
                        CH1["📊<br/>ClickHouse Node 1<br/>t3.micro"]
                    end
                    subgraph "🗄️ DB Subnet 2 (10.0.22.0/24)"
                        RDS2["🐘<br/>RDS MySQL Read Replica<br/>db.t3.micro"]
                        CH2["📊<br/>ClickHouse Node 2<br/>t3.micro"]
                    end
                    subgraph "🗄️ DB Subnet 3 (10.0.23.0/24)"
                        CH3["📊<br/>ClickHouse Node 3<br/>t3.micro"]
                    end
                end
            end
            
            %% Security Services
            subgraph "🛡️ Security Services"
                WAF1["🛡️<br/>AWS WAF<br/>Web Application Firewall"]
                SHIELD1["🛡️<br/>AWS Shield<br/>DDoS Protection"]
                GUARDDUTY1["🔍<br/>Amazon GuardDuty<br/>Threat Detection"]
                KMS1["🔐<br/>AWS KMS<br/>Key Management"]
            end
            
            %% Storage Services
            subgraph "📦 Storage Services"
                S3_GLOBAL["📦<br/>S3 Global Content<br/>Static Assets<br/>Images, CSS, JS"]
                S3_VIDEO["🎥<br/>S3 Video Storage<br/>Video Files<br/>Lifecycle Policies"]
                S3_USERDATA["👤<br/>S3 User Data<br/>User Uploads<br/>Backup Data"]
            end
            
            %% Monitoring Services
            subgraph "📊 Monitoring & Observability"
                CLOUDWATCH1["📊<br/>CloudWatch<br/>Metrics & Logs"]
                PROMETHEUS1["📈<br/>Prometheus<br/>Application Metrics"]
                GRAFANA1["📊<br/>Grafana<br/>Dashboards"]
                SNS1["📢<br/>SNS<br/>Notifications"]
            end
        end
        
        subgraph "🇦🇪 ME-South-1 (Secondary Region)"
            subgraph "🏢 VPC: 10.1.0.0/16"
                subgraph "🌐 Public Subnets"
                    subgraph "📡 Public Subnet 1 (10.1.1.0/24)"
                        IGW2["🌐<br/>Internet Gateway"]
                        NAT4["🌐<br/>NAT Gateway"]
                        ALB2["⚖️<br/>Application Load Balancer<br/>Port 80/443"]
                    end
                    subgraph "📡 Public Subnet 2 (10.1.2.0/24)"
                        NAT5["🌐<br/>NAT Gateway"]
                    end
                    subgraph "📡 Public Subnet 3 (10.1.3.0/24)"
                        NAT6["🌐<br/>NAT Gateway"]
                    end
                end
                
                subgraph "🏠 Private Subnets"
                    subgraph "🏠 Private Subnet 1 (10.1.11.0/24)"
                        EKS4["🐳<br/>EKS Node Group 1<br/>t3.micro/small<br/>General Purpose"]
                        APP4["🚀<br/>Application Pods<br/>Web Services"]
                    end
                    subgraph "🏠 Private Subnet 2 (10.1.12.0/24)"
                        EKS5["🐳<br/>EKS Node Group 2<br/>t3.micro/small<br/>General Purpose"]
                        APP5["🚀<br/>Application Pods<br/>API Services"]
                    end
                    subgraph "🏠 Private Subnet 3 (10.1.13.0/24)"
                        EKS6["🐳<br/>EKS Node Group 3<br/>t3.small/medium<br/>Video Processing"]
                        APP6["🎥<br/>Video Processing Pods<br/>Transcoding Services"]
                    end
                end
                
                subgraph "🗄️ Database Subnets"
                    subgraph "🗄️ DB Subnet 1 (10.1.21.0/24)"
                        RDS3["🐘<br/>RDS MySQL Secondary<br/>db.t3.micro<br/>Read Replica"]
                        CH4["📊<br/>ClickHouse Node 1<br/>t3.micro"]
                    end
                    subgraph "🗄️ DB Subnet 2 (10.1.22.0/24)"
                        CH5["📊<br/>ClickHouse Node 2<br/>t3.micro"]
                    end
                    subgraph "🗄️ DB Subnet 3 (10.1.23.0/24)"
                        CH6["📊<br/>ClickHouse Node 3<br/>t3.micro"]
                    end
                end
            end
            
            %% Security Services
            subgraph "🛡️ Security Services"
                WAF2["🛡️<br/>AWS WAF<br/>Web Application Firewall"]
                SHIELD2["🛡️<br/>AWS Shield<br/>DDoS Protection"]
                GUARDDUTY2["🔍<br/>Amazon GuardDuty<br/>Threat Detection"]
                KMS2["🔐<br/>AWS KMS<br/>Key Management"]
            end
            
            %% Storage Services
            subgraph "📦 Storage Services"
                S3_GLOBAL_REPLICA["📦<br/>S3 Global Content Replica<br/>Cross-Region Replication"]
                S3_VIDEO_REPLICA["🎥<br/>S3 Video Storage Replica<br/>Cross-Region Replication"]
                S3_USERDATA_REPLICA["👤<br/>S3 User Data Replica<br/>Cross-Region Replication"]
            end
            
            %% Monitoring Services
            subgraph "📊 Monitoring & Observability"
                CLOUDWATCH2["📊<br/>CloudWatch<br/>Metrics & Logs"]
                PROMETHEUS2["📈<br/>Prometheus<br/>Application Metrics"]
                GRAFANA2["📊<br/>Grafana<br/>Dashboards"]
                SNS2["📢<br/>SNS<br/>Notifications"]
            end
        end
    end
    
    %% Global AWS Services
    subgraph "🌐 Global AWS Services"
        CLOUDFRONT["🌍<br/>CloudFront CDN<br/>Global Content Delivery<br/>Video Streaming<br/>API Acceleration"]
        
        ROUTE53["🌍<br/>Route 53<br/>Global DNS<br/>Health Checks<br/>Failover Routing"]
        
        IAM["👤<br/>AWS IAM<br/>Identity & Access Management<br/>Roles & Policies"]
        
        FIREHOSE["📊<br/>Kinesis Firehose<br/>WAF Logs Delivery<br/>Real-time Analytics"]
    end
    
    %% Internet
    subgraph "🌍 Internet"
        INTERNET["🌐<br/>Global Internet<br/>End Users<br/>Mobile Apps<br/>Web Browsers"]
    end
    
    %% Connections - Primary Region
    INTERNET --> CLOUDFRONT
    CLOUDFRONT --> ALB1
    ALB1 --> APP1
    ALB1 --> APP2
    ALB1 --> APP3
    
    %% Database Connections
    APP1 --> RDS1
    APP2 --> RDS1
    APP3 --> CH1
    
    %% Storage Connections
    APP1 --> S3_GLOBAL
    APP2 --> S3_GLOBAL
    APP3 --> S3_VIDEO
    
    %% Security Connections
    CLOUDFRONT --> WAF1
    WAF1 --> FIREHOSE
    
    %% Cross-Region Connections
    RDS1 -.->|"🔄 Multi-Region<br/>Replication"| RDS3
    CH1 -.->|"🔄 Cross-Region<br/>Sync"| CH4
    S3_GLOBAL -.->|"🔄 Cross-Region<br/>Replication"| S3_GLOBAL_REPLICA
    S3_VIDEO -.->|"🔄 Cross-Region<br/>Replication"| S3_VIDEO_REPLICA
    
    %% Secondary Region Connections
    CLOUDFRONT --> ALB2
    ALB2 --> APP4
    ALB2 --> APP5
    ALB2 --> APP6
    
    APP4 --> RDS3
    APP5 --> RDS3
    APP6 --> CH4
    
    APP4 --> S3_GLOBAL_REPLICA
    APP5 --> S3_GLOBAL_REPLICA
    APP6 --> S3_VIDEO_REPLICA
    
    CLOUDFRONT --> WAF2
    WAF2 --> FIREHOSE
    
    %% Styling
    classDef regionStyle fill:#e1f5fe,stroke:#01579b,stroke-width:3px
    classDef vpcStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef publicStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef privateStyle fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef dbStyle fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef securityStyle fill:#fff8e1,stroke:#f57f17,stroke-width:2px
    classDef storageStyle fill:#e0f2f1,stroke:#004d40,stroke-width:2px
    classDef monitoringStyle fill:#f1f8e9,stroke:#33691e,stroke-width:2px
    classDef globalStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:3px
    classDef internetStyle fill:#fafafa,stroke:#424242,stroke-width:2px
    
    class "🇺🇸 US-East-1 (Primary Region)","🇦🇪 ME-South-1 (Secondary Region)" regionStyle
    class "🏢 VPC: 10.0.0.0/16","🏢 VPC: 10.1.0.0/16" vpcStyle
    class "🌐 Public Subnets" publicStyle
    class "🏠 Private Subnets" privateStyle
    class "🗄️ Database Subnets" dbStyle
    class "🛡️ Security Services" securityStyle
    class "📦 Storage Services" storageStyle
    class "📊 Monitoring & Observability" monitoringStyle
    class "🌐 Global AWS Services" globalStyle
    class "🌍 Internet" internetStyle
```

## **🔒 Security Architecture with AWS Icons**

```mermaid
graph TB
    subgraph "🛡️ AWS Security Stack"
        subgraph "🌐 Edge Security"
            CLOUDFRONT_SEC["🌍<br/>CloudFront<br/>DDoS Protection<br/>SSL/TLS Termination"]
            
            WAF_EDGE["🛡️<br/>AWS WAF<br/>Web Application Firewall<br/>Rate Limiting<br/>Geo-blocking<br/>SQL Injection Protection"]
            
            SHIELD_EDGE["🛡️<br/>AWS Shield<br/>Advanced DDoS Protection<br/>Always-on Detection<br/>Real-time Mitigation"]
        end
        
        subgraph "🔐 Identity & Access"
            IAM_CENTER["👤<br/>AWS IAM<br/>User Management<br/>Role-based Access<br/>Policy Enforcement"]
            
            KMS_CENTER["🔐<br/>AWS KMS<br/>Encryption Keys<br/>Data Protection<br/>Compliance"]
            
            COGNITO["👥<br/>Amazon Cognito<br/>User Authentication<br/>Federation<br/>MFA Support"]
        end
        
        subgraph "🔍 Threat Detection"
            GUARDDUTY_CENTER["🔍<br/>Amazon GuardDuty<br/>Threat Detection<br/>ML-based Analysis<br/>Continuous Monitoring"]
            
            CLOUDTRAIL["📝<br/>AWS CloudTrail<br/>API Logging<br/>Audit Trail<br/>Compliance"]
            
            CONFIG["⚙️<br/>AWS Config<br/>Resource Inventory<br/>Configuration History<br/>Compliance Rules"]
        end
        
        subgraph "🏢 Network Security"
            VPC_SEC["🏢<br/>Amazon VPC<br/>Network Isolation<br/>Private Subnets<br/>Security Groups"]
            
            NACL_SEC["🔒<br/>Network ACLs<br/>Stateless Firewall<br/>Subnet-level Security<br/>IP-based Rules"]
            
            SG_SEC["🛡️<br/>Security Groups<br/>Stateful Firewall<br/>Instance-level Security<br/>Port-based Rules"]
        end
    end
    
    %% Security Flow
    CLOUDFRONT_SEC --> WAF_EDGE
    WAF_EDGE --> SHIELD_EDGE
    SHIELD_EDGE --> VPC_SEC
    
    VPC_SEC --> NACL_SEC
    NACL_SEC --> SG_SEC
    
    IAM_CENTER --> KMS_CENTER
    KMS_CENTER --> COGNITO
    
    GUARDDUTY_CENTER --> CLOUDTRAIL
    CLOUDTRAIL --> CONFIG
    
    %% Styling
    classDef edgeStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef identityStyle fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef threatStyle fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef networkStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    
    class "🌐 Edge Security" edgeStyle
    class "🔐 Identity & Access" identityStyle
    class "🔍 Threat Detection" threatStyle
    class "🏢 Network Security" networkStyle
```

## **📊 Data Flow Architecture with AWS Icons**

```mermaid
graph LR
    subgraph "👥 End Users"
        USERS["👥<br/>End Users<br/>Students<br/>Instructors<br/>Administrators"]
    end
    
    subgraph "🌐 Global Delivery"
        CLOUDFRONT_FLOW["🌍<br/>CloudFront CDN<br/>Global Edge Locations<br/>Low Latency Delivery<br/>Caching"]
        
        ROUTE53_FLOW["🌍<br/>Route 53<br/>DNS Resolution<br/>Health Checks<br/>Failover"]
    end
    
    subgraph "⚖️ Load Balancing"
        ALB_FLOW["⚖️<br/>Application Load Balancer<br/>Traffic Distribution<br/>Health Checks<br/>SSL Termination"]
    end
    
    subgraph "🐳 Container Orchestration"
        EKS_FLOW["🐳<br/>Amazon EKS<br/>Kubernetes Cluster<br/>Auto Scaling<br/>High Availability"]
        
        PODS_FLOW["🚀<br/>Application Pods<br/>Web Services<br/>API Services<br/>Video Processing"]
    end
    
    subgraph "🗄️ Data Storage"
        RDS_FLOW["🐘<br/>Amazon RDS<br/>MySQL Database<br/>Multi-AZ<br/>Read Replicas"]
        
        CLICKHOUSE_FLOW["📊<br/>ClickHouse<br/>Analytics Database<br/>Real-time Queries<br/>Data Warehousing"]
        
        S3_FLOW["📦<br/>Amazon S3<br/>Object Storage<br/>Global Content<br/>Video Files<br/>User Data"]
    end
    
    subgraph "📊 Analytics & Monitoring"
        CLOUDWATCH_FLOW["📊<br/>CloudWatch<br/>Metrics & Logs<br/>Performance Monitoring<br/>Alerts"]
        
        PROMETHEUS_FLOW["📈<br/>Prometheus<br/>Application Metrics<br/>Custom Dashboards<br/>Alerting"]
        
        GRAFANA_FLOW["📊<br/>Grafana<br/>Visualization<br/>Real-time Dashboards<br/>Business Intelligence"]
    end
    
    %% Data Flow
    USERS --> ROUTE53_FLOW
    ROUTE53_FLOW --> CLOUDFRONT_FLOW
    CLOUDFRONT_FLOW --> ALB_FLOW
    ALB_FLOW --> EKS_FLOW
    EKS_FLOW --> PODS_FLOW
    
    PODS_FLOW --> RDS_FLOW
    PODS_FLOW --> CLICKHOUSE_FLOW
    PODS_FLOW --> S3_FLOW
    
    PODS_FLOW --> CLOUDWATCH_FLOW
    CLOUDWATCH_FLOW --> PROMETHEUS_FLOW
    PROMETHEUS_FLOW --> GRAFANA_FLOW
    
    %% Styling
    classDef userStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef deliveryStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef loadStyle fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef containerStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef storageStyle fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef monitoringStyle fill:#e0f2f1,stroke:#004d40,stroke-width:2px
    
    class "👥 End Users" userStyle
    class "🌐 Global Delivery" deliveryStyle
    class "⚖️ Load Balancing" loadStyle
    class "🐳 Container Orchestration" containerStyle
    class "🗄️ Data Storage" storageStyle
    class "📊 Analytics & Monitoring" monitoringStyle
```

## **💰 Cost Optimization Architecture with AWS Icons**

```mermaid
graph TB
    subgraph "💰 AWS Cost Optimization Strategy"
        subgraph "🔄 Auto Scaling"
            ASG_COST["📈<br/>Auto Scaling Groups<br/>Scale based on demand<br/>Reduce idle resources<br/>Cost savings: 40-60%"]
            
            EKS_COST["🐳<br/>EKS Cluster Autoscaler<br/>Dynamic node scaling<br/>Spot Instance integration<br/>Cost savings: 50-70%"]
        end
        
        subgraph "💾 Storage Optimization"
            S3_LIFECYCLE["📦<br/>S3 Lifecycle Policies<br/>Automatic tiering<br/>Infrequent Access<br/>Cost savings: 60-80%"]
            
            RDS_COST["🐘<br/>RDS Reserved Instances<br/>1-3 year commitments<br/>Predictable workloads<br/>Cost savings: 30-60%"]
        end
        
        subgraph "⚡ Instance Optimization"
            SPOT_COST["⚡<br/>Spot Instances<br/>Interruptible workloads<br/>Video processing<br/>Cost savings: 70-90%"]
            
            SAVINGS_PLANS["💡<br/>Savings Plans<br/>Flexible pricing<br/>Compute & EC2<br/>Cost savings: 20-50%"]
        end
        
        subgraph "🌐 CDN Optimization"
            CLOUDFRONT_COST["🌍<br/>CloudFront CDN<br/>Reduce origin load<br/>Global caching<br/>Cost savings: 30-50%"]
            
            COMPRESSION["🗜️<br/>Data Compression<br/>Reduce bandwidth<br/>Faster delivery<br/>Cost savings: 20-40%"]
        end
    end
    
    %% Cost Optimization Flow
    ASG_COST --> EKS_COST
    EKS_COST --> SPOT_COST
    SPOT_COST --> SAVINGS_PLANS
    
    S3_LIFECYCLE --> RDS_COST
    RDS_COST --> CLOUDFRONT_COST
    CLOUDFRONT_COST --> COMPRESSION
    
    %% Styling
    classDef scalingStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef storageStyle fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef instanceStyle fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef cdnStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    
    class "🔄 Auto Scaling" scalingStyle
    class "💾 Storage Optimization" storageStyle
    class "⚡ Instance Optimization" instanceStyle
    class "🌐 CDN Optimization" cdnStyle
```

## **📋 AWS Services Summary**

### **🏗️ Compute Services**
- **🐳 Amazon EKS**: Kubernetes orchestration
- **⚖️ Application Load Balancer**: Traffic distribution
- **📈 Auto Scaling Groups**: Dynamic scaling

### **🗄️ Database Services**
- **🐘 Amazon RDS**: MySQL database
- **📊 ClickHouse**: Analytics database
- **🔄 Multi-Region Replication**: Disaster recovery

### **📦 Storage Services**
- **📦 Amazon S3**: Object storage
- **🎥 Video Storage**: Lifecycle policies
- **🔄 Cross-Region Replication**: Data redundancy

### **🌐 Global Services**
- **🌍 CloudFront**: Content delivery network
- **🌍 Route 53**: DNS and health checks
- **🛡️ AWS WAF**: Web application firewall

### **🔒 Security Services**
- **🛡️ AWS Shield**: DDoS protection
- **🔍 Amazon GuardDuty**: Threat detection
- **🔐 AWS KMS**: Key management
- **👤 AWS IAM**: Identity management

### **📊 Monitoring Services**
- **📊 CloudWatch**: Metrics and logs
- **📈 Prometheus**: Application metrics
- **📊 Grafana**: Dashboards
- **📢 SNS**: Notifications

### **💰 Cost Optimization**
- **⚡ Spot Instances**: 70-90% savings
- **📦 S3 Lifecycle**: 60-80% savings
- **🐘 Reserved Instances**: 30-60% savings
- **🌍 CloudFront**: 30-50% savings

**Total Estimated Cost**: ~$275/month (90% savings from original design)

This architecture provides **enterprise-grade scalability**, **security**, and **cost optimization** for your KnowledgeCity platform! 🚀 
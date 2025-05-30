# CloudFront SSL Setup - Architecture Documentation

This document describes the architecture, components, and design decisions behind the CloudFront SSL Setup solution for the Xignals observability platform.

## 📋 Table of Contents

- [Overview](#overview)
- [High-Level Architecture](#high-level-architecture)
- [Component Architecture](#component-architecture)
- [Data Flow](#data-flow)
- [Security Architecture](#security-architecture)
- [Network Architecture](#network-architecture)
- [Deployment Architecture](#deployment-architecture)
- [Scaling Architecture](#scaling-architecture)
- [Disaster Recovery Architecture](#disaster-recovery-architecture)

## 🏗️ Overview

The CloudFront SSL Setup solution provides automated deployment and management of AWS CloudFront distributions with SSL certificates, specifically optimized for observability platforms like Xignals. The architecture follows cloud-native best practices with emphasis on security, scalability, and reliability.

### Core Design Principles

- **Security First**: Multi-layered security with custom headers and WAF integration
- **High Availability**: Multi-region support with automated failover
- **Performance Optimized**: Edge caching with observability-specific optimizations
- **Cost Efficient**: Intelligent caching strategies and resource optimization
- **Automation Ready**: CI/CD integration with comprehensive testing
- **Observability Native**: Self-monitoring and integration with monitoring tools

## 🌐 High-Level Architecture

```mermaid
graph TB
    subgraph "User Traffic"
        Users[Global Users]
        DNS[Route 53 DNS]
    end

    subgraph "CloudFront Edge Network"
        Edge1[Edge Location US]
        Edge2[Edge Location EU]
        Edge3[Edge Location APAC]
        WAF[AWS WAF]
    end

    subgraph "AWS Infrastructure"
        subgraph "Certificate Management"
            ACM[AWS Certificate Manager]
            Validation[DNS Validation]
        end

        subgraph "Load Balancing"
            ALB[Application Load Balancer]
            SG[Security Groups]
        end

        subgraph "Origin Servers"
            XignalsApp[Xignals Application]
            HealthCheck[Health Checks]
        end
    end

    subgraph "Monitoring & Logging"
        CloudWatch[CloudWatch Metrics]
        Logs[CloudFront Logs]
        Alerts[SNS Alerts]
    end

    Users --> DNS
    DNS --> Edge1
    DNS --> Edge2
    DNS --> Edge3

    Edge1 --> WAF
    Edge2 --> WAF
    Edge3 --> WAF

    WAF --> ALB
    ALB --> SG
    SG --> XignalsApp

    ACM --> Validation
    Validation --> DNS

    Edge1 --> CloudWatch
    Edge2 --> CloudWatch
    Edge3 --> CloudWatch

    Edge1 --> Logs
    Edge2 --> Logs
    Edge3 --> Logs

    CloudWatch --> Alerts
```

## 🧩 Component Architecture

### Core Components

```mermaid
graph TB
    subgraph "CloudFront SSL Setup Solution"
        subgraph "Core Scripts"
            MainScript[cloudfront-ssl-setup.sh]
            ConfigTemplate[cloudfront-config.template]
        end

        subgraph "Utility Scripts"
            InstallDeps[scripts/install-deps.sh]
            RunTests[scripts/run-tests.sh]
            DisasterRecovery[scripts/disaster-recovery.sh]
        end

        subgraph "Configuration Examples"
            DevConfig[examples/dev.conf]
            StagingConfig[examples/staging.conf]
            ProdConfig[examples/production.conf]
            XignalsConfig[examples/xignals-prod.conf]
        end

        subgraph "Documentation"
            README[README.md]
            HowTo[HOW-TO.md]
            Contributing[CONTRIBUTING.md]
            Architecture[docs/architecture.md]
            Security[docs/security.md]
            Troubleshooting[docs/troubleshooting.md]
        end
    end

    MainScript --> ConfigTemplate
    MainScript --> InstallDeps
    MainScript --> RunTests
    MainScript --> DisasterRecovery

    ConfigTemplate --> DevConfig
    ConfigTemplate --> StagingConfig
    ConfigTemplate --> ProdConfig
    ConfigTemplate --> XignalsConfig
```

### AWS Service Integration

```mermaid
graph LR
    subgraph "AWS Services"
        subgraph "Content Delivery"
            CloudFront[AWS CloudFront]
            EdgeLocations[Edge Locations]
        end

        subgraph "Security"
            ACM[Certificate Manager]
            WAF[AWS WAF]
            SecurityGroups[Security Groups]
        end

        subgraph "DNS & Networking"
            Route53[Route 53]
            VPC[Amazon VPC]
            ALB[Application Load Balancer]
        end

        subgraph "Monitoring"
            CloudWatch[CloudWatch]
            SNS[Simple Notification Service]
            S3Logs[S3 Access Logs]
        end

        subgraph "Compute"
            EC2[EC2 Instances]
            ECS[ECS/Fargate]
        end
    end

    CloudFront --> EdgeLocations
    CloudFront --> ACM
    CloudFront --> WAF
    CloudFront --> Route53
    CloudFront --> CloudWatch
    CloudFront --> S3Logs

    ALB --> SecurityGroups
    ALB --> VPC
    ALB --> EC2
    ALB --> ECS

    Route53 --> ACM
    CloudWatch --> SNS
```

## 🔄 Data Flow

### Request Flow Architecture

```mermaid
sequenceDiagram
    participant User
    participant DNS as Route 53
    participant Edge as CloudFront Edge
    participant WAF as AWS WAF
    participant ALB as Load Balancer
    participant App as Xignals App
    participant Monitor as CloudWatch

    User->>DNS: 1. DNS Query (xignals.xapiens.id)
    DNS->>User: 2. CloudFront Edge IP

    User->>Edge: 3. HTTPS Request
    Edge->>Edge: 4. Check Cache

    alt Cache Miss
        Edge->>WAF: 5. Forward to WAF
        WAF->>WAF: 6. Security Rules Check
        WAF->>ALB: 7. Forward Request
        ALB->>ALB: 8. Health Check
        ALB->>App: 9. Route to Healthy Instance
        App->>ALB: 10. Response
        ALB->>WAF: 11. Response
        WAF->>Edge: 12. Response
        Edge->>Edge: 13. Cache Response
    end

    Edge->>User: 14. Final Response
    Edge->>Monitor: 15. Metrics & Logs
    Monitor->>Monitor: 16. Process Metrics
```

### SSL Certificate Provisioning Flow

```mermaid
sequenceDiagram
    participant Script as Setup Script
    participant ACM as Certificate Manager
    participant DNS as Route 53
    participant CF as CloudFront

    Script->>ACM: 1. Request Certificate
    ACM->>Script: 2. DNS Validation Records
    Script->>DNS: 3. Create Validation Records
    DNS->>ACM: 4. DNS Validation
    ACM->>ACM: 5. Certificate Issued
    Script->>CF: 6. Create Distribution
    CF->>ACM: 7. Attach Certificate
    Script->>DNS: 8. Create CNAME Record
    DNS->>CF: 9. Route Traffic
```

## 🔒 Security Architecture

### Multi-Layer Security Model

```mermaid
graph TB
    subgraph "Security Layers"
        subgraph "Edge Security"
            TLS[TLS 1.2+ Termination]
            DDoS[DDoS Protection]
            GeoBlock[Geo Blocking]
        end

        subgraph "Application Security"
            WAF[AWS WAF Rules]
            RateLimit[Rate Limiting]
            IPWhitelist[IP Whitelisting]
        end

        subgraph "Origin Security"
            CustomHeaders[Custom Headers]
            SecurityGroups[Security Groups]
            NetworkACL[Network ACLs]
        end

        subgraph "Data Security"
            Encryption[Data Encryption]
            Headers[Security Headers]
            HSTS[HSTS Policy]
        end
    end

    TLS --> WAF
    DDoS --> WAF
    GeoBlock --> WAF

    WAF --> CustomHeaders
    RateLimit --> CustomHeaders
    IPWhitelist --> CustomHeaders

    CustomHeaders --> Encryption
    SecurityGroups --> Encryption
    NetworkACL --> Encryption
```

### Security Controls Flow

```mermaid
flowchart TD
    Request[Incoming Request] --> TLSCheck{TLS 1.2+?}
    TLSCheck -->|No| Reject1[Reject - Upgrade Required]
    TLSCheck -->|Yes| GeoCheck{Geo Allowed?}

    GeoCheck -->|No| Reject2[Reject - Geo Blocked]
    GeoCheck -->|Yes| WAFCheck{WAF Rules Pass?}

    WAFCheck -->|No| Reject3[Reject - WAF Block]
    WAFCheck -->|Yes| RateCheck{Rate Limit OK?}

    RateCheck -->|No| Reject4[Reject - Rate Limited]
    RateCheck -->|Yes| HeaderCheck{Custom Header Present?}

    HeaderCheck -->|No| Reject5[Reject - Missing Header]
    HeaderCheck -->|Yes| SGCheck{Security Group Allows?}

    SGCheck -->|No| Reject6[Reject - Network Block]
    SGCheck -->|Yes| Forward[Forward to Origin]

    Forward --> App[Xignals Application]
```

## 🌍 Network Architecture

### Multi-Region Network Topology

```mermaid
graph TB
    subgraph "Global Infrastructure"
        subgraph "Primary Region (ap-southeast-1)"
            VPC1[Production VPC]
            subgraph "Public Subnets"
                ALB1[Application Load Balancer]
                NAT1[NAT Gateway]
            end
            subgraph "Private Subnets"
                App1[Xignals Applications]
                DB1[Database Cluster]
            end
        end

        subgraph "Secondary Region (us-west-2)"
            VPC2[DR VPC]
            subgraph "Public Subnets DR"
                ALB2[Backup Load Balancer]
                NAT2[NAT Gateway]
            end
            subgraph "Private Subnets DR"
                App2[Backup Applications]
                DB2[Database Replica]
            end
        end

        subgraph "Certificate Region (us-east-1)"
            ACM[Certificate Manager]
            CloudFront[CloudFront Distribution]
        end
    end

    subgraph "Global Edge Network"
        Edge1[US East Edge]
        Edge2[Europe Edge]
        Edge3[Asia Pacific Edge]
        Edge4[Australia Edge]
    end

    CloudFront --> Edge1
    CloudFront --> Edge2
    CloudFront --> Edge3
    CloudFront --> Edge4

    Edge1 --> ALB1
    Edge2 --> ALB1
    Edge3 --> ALB1
    Edge4 --> ALB1

    ALB1 --> App1
    App1 --> DB1

    DB1 -.->|Replication| DB2
    ALB1 -.->|Failover| ALB2
```

### Security Group Architecture

```mermaid
graph LR
    subgraph "Security Groups"
        subgraph "CloudFront Security"
            CFSG[CloudFront Managed Prefix List]
            CFPorts[Ports: 80, 443]
        end

        subgraph "ALB Security"
            ALBSG[ALB Security Group]
            ALBPorts[Ports: 80, 443]
            ALBSources[Sources: CloudFront Only]
        end

        subgraph "Application Security"
            AppSG[Application Security Group]
            AppPorts[Ports: 8080, 8443]
            AppSources[Sources: ALB Only]
        end

        subgraph "Database Security"
            DBSG[Database Security Group]
            DBPorts[Ports: 5432, 3306]
            DBSources[Sources: App Only]
        end
    end

    CFSG --> ALBSG
    CFPorts --> ALBPorts

    ALBSG --> AppSG
    ALBSources --> AppSources

    AppSG --> DBSG
    AppSources --> DBSources
```

## 🚀 Deployment Architecture

### CI/CD Pipeline Architecture

```mermaid
graph LR
    subgraph "Source Control"
        GitHub[GitHub Repository]
        PR[Pull Request]
    end

    subgraph "CI/CD Pipeline"
        subgraph "Build Stage"
            Lint[Linting & Validation]
            UnitTest[Unit Tests]
            Security[Security Scan]
        end

        subgraph "Test Stage"
            Integration[Integration Tests]
            E2E[E2E Tests]
            Performance[Performance Tests]
        end

        subgraph "Deploy Stage"
            Staging[Deploy to Staging]
            Production[Deploy to Production]
            Rollback[Rollback Capability]
        end
    end

    subgraph "Environments"
        Dev[Development]
        Stage[Staging]
        Prod[Production]
    end

    GitHub --> Lint
    PR --> Lint

    Lint --> UnitTest
    UnitTest --> Security
    Security --> Integration

    Integration --> E2E
    E2E --> Performance

    Performance --> Staging
    Staging --> Stage

    Stage --> Production
    Production --> Prod

    Production --> Rollback
    Rollback --> Prod
```

### Blue/Green Deployment Model

```mermaid
graph TB
    subgraph "Blue/Green Deployment"
        subgraph "Current (Blue)"
            BlueALB[Blue ALB]
            BlueApp[Blue Application v1.0]
            BlueCF[Blue CloudFront]
        end

        subgraph "New (Green)"
            GreenALB[Green ALB]
            GreenApp[Green Application v1.1]
            GreenCF[Green CloudFront]
        end

        subgraph "Traffic Management"
            DNS[Route 53 DNS]
            HealthCheck[Health Checks]
            Monitor[Monitoring]
        end
    end

    DNS --> BlueCF
    DNS -.->|Switchover| GreenCF

    BlueCF --> BlueALB
    GreenCF --> GreenALB

    BlueALB --> BlueApp
    GreenALB --> GreenApp

    HealthCheck --> BlueApp
    HealthCheck --> GreenApp

    Monitor --> HealthCheck
```

## 📈 Scaling Architecture

### Auto-Scaling Model

```mermaid
graph TB
    subgraph "Scaling Components"
        subgraph "CloudFront Scaling"
            GlobalEdges[Global Edge Locations]
            AutoScale[Automatic Edge Scaling]
        end

        subgraph "Origin Scaling"
            ALBScaling[ALB Auto Scaling]
            ASG[Auto Scaling Group]
            TargetTracking[Target Tracking Policy]
        end

        subgraph "Database Scaling"
            ReadReplicas[Read Replicas]
            ConnectionPooling[Connection Pooling]
            QueryOptimization[Query Optimization]
        end

        subgraph "Monitoring & Triggers"
            CloudWatch[CloudWatch Metrics]
            Alarms[CloudWatch Alarms]
            Notifications[SNS Notifications]
        end
    end

    GlobalEdges --> ALBScaling
    AutoScale --> ALBScaling

    ALBScaling --> ASG
    ASG --> TargetTracking

    ASG --> ReadReplicas
    TargetTracking --> ConnectionPooling

    CloudWatch --> Alarms
    Alarms --> Notifications
    Alarms --> ASG
```

### Performance Optimization Architecture

```mermaid
graph LR
    subgraph "Performance Layers"
        subgraph "Edge Optimization"
            Compression[Gzip Compression]
            HTTP2[HTTP/2 Support]
            EdgeCaching[Edge Caching]
        end

        subgraph "Origin Optimization"
            KeepAlive[Connection Keep-Alive]
            LoadBalancing[Intelligent Load Balancing]
            HealthChecks[Advanced Health Checks]
        end

        subgraph "Application Optimization"
            Caching[Application Caching]
            CDNOptimized[CDN-Optimized Responses]
            AssetOptimization[Asset Optimization]
        end

        subgraph "Database Optimization"
            QueryCache[Query Caching]
            IndexOptimization[Index Optimization]
            ConnectionPool[Connection Pooling]
        end
    end

    Compression --> KeepAlive
    HTTP2 --> LoadBalancing
    EdgeCaching --> HealthChecks

    KeepAlive --> Caching
    LoadBalancing --> CDNOptimized
    HealthChecks --> AssetOptimization

    Caching --> QueryCache
    CDNOptimized --> IndexOptimization
    AssetOptimization --> ConnectionPool
```

## 🔄 Disaster Recovery Architecture

### Multi-Region DR Strategy

```mermaid
graph TB
    subgraph "Primary Region (ap-southeast-1)"
        PrimaryVPC[Primary VPC]
        PrimaryALB[Primary ALB]
        PrimaryApp[Primary Application]
        PrimaryDB[Primary Database]
        PrimaryBackup[Automated Backups]
    end

    subgraph "DR Region (us-west-2)"
        DRVPC[DR VPC]
        DRALB[DR ALB]
        DRApp[DR Application]
        DRDB[DR Database Replica]
        DRRestore[Restore Capability]
    end

    subgraph "Global Services"
        Route53[Route 53 Health Checks]
        CloudFront[CloudFront Distribution]
        S3Backup[S3 Cross-Region Backup]
    end

    subgraph "Recovery Process"
        FailureDetection[Failure Detection]
        AutoFailover[Automatic Failover]
        ManualFailover[Manual Failover]
        Rollback[Rollback Process]
    end

    PrimaryDB -.->|Continuous Replication| DRDB
    PrimaryBackup -.->|Cross-Region Backup| S3Backup

    Route53 --> FailureDetection
    FailureDetection --> AutoFailover
    AutoFailover --> DRALB

    CloudFront --> PrimaryALB
    CloudFront -.->|Failover| DRALB

    ManualFailover --> DRRestore
    Rollback --> PrimaryALB
```

### Backup and Recovery Flow

```mermaid
sequenceDiagram
    participant Admin
    participant Script as DR Script
    participant Primary as Primary Region
    participant Backup as Backup Storage
    participant DR as DR Region
    participant Monitor as Monitoring

    Admin->>Script: 1. Initiate Backup
    Script->>Primary: 2. Snapshot Resources
    Primary->>Backup: 3. Store Snapshots
    Script->>DR: 4. Replicate Configuration
    Script->>Monitor: 5. Verify Backup

    Note over Monitor: Failure Detected

    Monitor->>Script: 6. Trigger Failover
    Script->>DR: 7. Activate DR Environment
    DR->>Backup: 8. Restore from Snapshots
    Script->>Admin: 9. Notify Failover Complete

    Note over Primary: Recovery Complete

    Admin->>Script: 10. Initiate Failback
    Script->>Primary: 11. Restore Primary
    Script->>DR: 12. Sync Changes
    Script->>Monitor: 13. Switch Traffic Back
```

## 🔍 Observability Architecture

### Xignals Self-Monitoring

```mermaid
graph TB
    subgraph "Xignals Observability Stack"
        subgraph "Data Collection"
            Metrics[Metrics Collection]
            Logs[Log Aggregation]
            Traces[Distributed Tracing]
            Events[Event Processing]
        end

        subgraph "Data Processing"
            ETL[ETL Pipeline]
            Aggregation[Data Aggregation]
            Enrichment[Data Enrichment]
            Storage[Time Series Storage]
        end

        subgraph "Visualization"
            Dashboards[Real-time Dashboards]
            Alerts[Alert Management]
            Reports[Custom Reports]
            APIs[Query APIs]
        end

        subgraph "Self-Monitoring"
            SelfMetrics[Self Metrics]
            HealthChecks[Health Monitoring]
            Performance[Performance Tracking]
            SLA[SLA Monitoring]
        end
    end

    Metrics --> ETL
    Logs --> ETL
    Traces --> ETL
    Events --> ETL

    ETL --> Aggregation
    Aggregation --> Enrichment
    Enrichment --> Storage

    Storage --> Dashboards
    Storage --> Alerts
    Storage --> Reports
    Storage --> APIs

    Dashboards --> SelfMetrics
    Performance --> HealthChecks
    SLA --> Performance
```

## 📊 Cost Optimization Architecture

### Cost Management Strategy

```mermaid
graph LR
    subgraph "Cost Optimization"
        subgraph "CloudFront Optimization"
            PriceClass[Price Class Selection]
            CacheOptimization[Cache Optimization]
            CompressionConfig[Compression Configuration]
        end

        subgraph "Origin Optimization"
            RightSizing[Instance Right-Sizing]
            AutoScaling[Auto Scaling Policies]
            SpotInstances[Spot Instance Usage]
        end

        subgraph "Storage Optimization"
            DataLifecycle[Data Lifecycle Management]
            StorageTiers[Storage Tier Optimization]
            BackupOptimization[Backup Optimization]
        end

        subgraph "Monitoring & Governance"
            CostMonitoring[Cost Monitoring]
            BudgetAlerts[Budget Alerts]
            ResourceTagging[Resource Tagging]
        end
    end

    PriceClass --> RightSizing
    CacheOptimization --> AutoScaling
    CompressionConfig --> SpotInstances

    RightSizing --> DataLifecycle
    AutoScaling --> StorageTiers
    SpotInstances --> BackupOptimization

    DataLifecycle --> CostMonitoring
    StorageTiers --> BudgetAlerts
    BackupOptimization --> ResourceTagging
```

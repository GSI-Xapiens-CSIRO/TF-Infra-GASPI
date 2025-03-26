# Terraform Infra for GASPI

Terraform Infra for Genetic Analysis Support Platform Indonesia (GASPI)

## AWS Control Tower

<div align="center">
    <img src="./docs/assets/ct.png" width="800px">
</div>


## AWS Organization

```
.
├── GXC-Management
│   ├── gxc-consortium-logarchived   (123456789890 | gxc-consortium-logarchived@domain.com)
│   ├── gxc-consortium-management    (112233445566 | gxc-consortium-management@domain.com)
│   └── gxc-consortium-securityaudit (223344556677 | gxc-consortium-securityaudit@domain.com)
└── GXC-OrganizationUnit
    ├── GXC-Billing
    │   └── gxc-consortium-billing   (098765432123 | gxc-consortium-billing@domain.com)
    ├── gxc-consortium-hub01         (438465168484 | gxc-consortium-hub01@domain.com)
    └── gxc-consortium-hub02         (127214202110 | gxc-consortium-hub02@domain.com)
```

## Terraform Structure

```
tree -L 3    # three-levels show
---
.
├── LICENSE
├── README.md
├── docs
│   └── assets
│       └── ct.png
├── environments
│   ├── gxc-consortium-hub01
│   │   ├── _tfstate
│   │   ├── budget
│   │   ├── cloudtrails
│   │   ├── core-ec2
│   │   ├── iam-logging
│   │   ├── iam-tfuser-executor
│   │   └── iam-user
│   ├── gxc-consortium-hub02
│   │   ├── _tfstate
│   │   ├── budget
│   │   ├── cloudtrails
│   │   ├── core-ec2
│   │   ├── iam-logging
│   │   ├── iam-tfuser-executor
│   │   └── iam-user
│   └── gxc-management
│       ├── _kms_cmk-gxc-staging
│       ├── _tfstate
│       ├── budget
│       ├── core-ec2
│       ├── iam-tfuser-executor
│       └── iam-user
├── modules
│   ├── audit
│   │   └── cloudtrails-opensearch
│   ├── budget
│   ├── core-igw-ec2
│   ├── core-nat-ec2
│   ├── iam-tfuser-executor
│   ├── iam-user
│   ├── s3-logs
│   ├── storage-efs
│   ├── storage-s3
│   └── tfstate
└── scripts
    └── cleanup-resources
        ├── cleanup.py
        └── requirements.txt

42 directories, 113 files
```

## Copyright

- Author: **DevOps Engineer (devops@xapiens.id)**
- Vendor: **Xapiens Teknologi Indonesia (xapiens.id)**
- License: **Apache v2**

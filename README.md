# Terraform Infra for GASPI

Terraform Infra for Genetic Analysis Support Platform Indonesia (GASPI)

[![ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![all contributors](https://img.shields.io/github/contributors/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![tags](https://img.shields.io/github/v/tag/GSI-Xapiens-CSIRO/TF-Infra-GASPI?sort=semver)
![view](https://views.whatilearened.today/views/github/GSI-Xapiens-CSIRO/TF-Infra-GASPI.svg)
![issues](https://img.shields.io/github/issues/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![pull requests](https://img.shields.io/github/issues-pr/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![forks](https://img.shields.io/github/forks/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![stars](https://img.shields.io/github/stars/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
[![license](https://img.shields.io/github/license/GSI-Xapiens-CSIRO/TF-Infra-GASPI)](https://img.shields.io/github/license/GSI-Xapiens-CSIRO/TF-Infra-GASPI)

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
├── atlantis-bgsi
│   ├── HOW-TO.md
│   ├── assets
│   ├── atlantis-nginx-basic-auth.conf
│   ├── atlantis-nginx.conf
│   └── docker
│       ├── DockerHub.md
│       ├── Dockerfile
│       ├── config
│       ├── docker-compose-db-memory.yml
│       ├── docker-compose-db-psql.yml
│       ├── docker-compose-nonginx.yml
│       ├── docker-compose.yml
│       ├── docker-entrypoint.sh
│       ├── package-lock.json
│       ├── package.json
│       ├── requirements.txt
│       └── scripts
├── atlantis-gxc
│   ├── HOW-TO.md
│   ├── assets
│   ├── atlantis-nginx-basic-auth.conf
│   ├── atlantis-nginx.conf
│   └── docker
│       ├── DockerHub.md
│       ├── Dockerfile
│       ├── config
│       ├── docker-compose-db-memory.yml
│       ├── docker-compose-db-psql.yml
│       ├── docker-compose.yml
│       ├── docker-entrypoint.sh
│       ├── package-lock.json
│       ├── package.json
│       ├── requirements.txt
│       └── scripts
├── docs
│   └── assets
│       └── ct.png
├── environments
│   ├── ct
│   │   └── gxc-management
│   ├── dev
│   │   ├── gxc-consortium-hub01
│   │   └── gxc-consortium-hub02
│   └── uat
│       ├── gxc-consortium-uat03
│       └── gxc-consortium-uat04
├── gen-docs.sh
├── modules
│   ├── audit
│   │   └── cloudtrails-opensearch
│   ├── budget
│   ├── cloudfront-ssl
│   ├── core-igw-ec2
│   ├── core-nat-ec2
│   ├── iam-tfuser-executor
│   ├── iam-user
│   ├── s3-logs
│   ├── storage-efs
│   ├── storage-s3
│   └── tfstate
└── scripts
    ├── cleanup-resources
    │   ├── cleanup.py
    │   └── requirements.txt
    └── cloudfront-ssl

43 directories, 171 files
```

## Copyright

- Author: **DevOps Engineer (devops@xapiens.id)**
- Vendor: **Xapiens Teknologi Indonesia (xapiens.id)**
- License: **Apache v2**

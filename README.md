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
    ├── hub01-438465168484           (438465168484 | gxc-consortium-hub01@domain.com)
    ├── hub03-111122223333           (111122223333 | gxc-consortium-hub03@domain.com)
    ├── uat03-444455556666           (444455556666 | gxc-consortium-uat03@domain.com)
    ├── uat04-777788889999           (777788889999 | gxc-consortium-uat04@domain.com)
    └── uat05-123412341234           (123412341234 | gxc-consortium-uat05@domain.com)
```

## Terraform Structure

```
tree -L 3    # three-levels show
---
.
├── atlantis-bgsi
│   ├── assets
│   │   ├── atlantis-pr-github-webhook.png
│   │   ├── atlantis-pr-state-diagram.png
│   │   ├── atlantis-sequence-gaspi-process.png
│   │   ├── atlantis-sequence-process.png
│   │   └── atlantis-state-diagram-process.png
│   ├── atlantis-nginx-basic-auth.conf
│   ├── atlantis-nginx.conf
│   ├── docker
│   │   ├── build-atlantis.sh
│   │   ├── config
│   │   ├── docker-compose.yml
│   │   ├── docker-entrypoint.sh
│   │   ├── Dockerfile
│   │   ├── DockerHub.md
│   │   ├── package-lock.json
│   │   ├── package.json
│   │   ├── requirements.txt
│   │   └── scripts
│   └── HOW-TO.md
├── atlantis-gxc
│   ├── assets
│   │   ├── atlantis-pr-github-webhook.png
│   │   ├── atlantis-pr-state-diagram.png
│   │   ├── atlantis-sequence-gaspi-process.png
│   │   ├── atlantis-sequence-process.png
│   │   └── atlantis-state-diagram-process.png
│   ├── atlantis-nginx-basic-auth.conf
│   ├── atlantis-nginx.conf
│   ├── Atlantis-Tfvars.md
│   ├── docker
│   │   ├── build-atlantis.sh
│   │   ├── config
│   │   ├── docker-compose.yml
│   │   ├── docker-entrypoint.sh
│   │   ├── Dockerfile
│   │   ├── DockerHub.md
│   │   ├── package-lock.json
│   │   ├── package.json
│   │   ├── requirements.txt
│   │   └── scripts
│   └── HOW-TO.md
├── CHANGELOG.md
├── docs
│   └── assets
│       └── ct.png
├── environments
│   ├── ct
│   │   └── gxc-management
│   ├── dev
│   │   ├── hub01-438465168484
│   │   ├── hub02-209479276142
│   │   └── hub03-111122223333
│   └── uat
│       ├── uat03-444455556666
│       ├── uat04-777788889999
│       └── uat05-123412341234
├── gen-docs.sh
├── LICENSE
├── modules
│   ├── audit
│   │   ├── cloudtrails-cleanup
│   │   └── cloudtrails-opensearch
│   ├── budget
│   ├── cloudfront-ssl
│   ├── core-cfn-ml
│   ├── core-igw-ec2
│   ├── core-nat-ec2
│   ├── iam-tfuser-executor
│   ├── iam-user
│   ├── s3-logs
│   ├── storage-efs
│   ├── storage-s3
│   └── tfstate
├── README.md
└── scripts
    ├── cleanup-resources
    │   ├── cleanup.py
    │   └── requirements.txt
    └── cloudfront-ssl

47 directories, 187 files
```

## Copyright

- Author: **DevOps Engineer (support.gxc@xapiens.id)**
- Vendor: **Xapiens Teknologi Indonesia (xapiens.id)**
- License: **Apache v2**

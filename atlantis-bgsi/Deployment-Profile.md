# Deployment Profile for BGSI

## Defining Workflow Code
- HUB01: `RSCM`
- HUB02: `RSPON`
- HUB03: `SARDJITO`
- HUB04: `IGNG`
- HUB05: `RSJPD`
- UAT01: `RSCM-UAT`
- UAT02: `RSPON-UAT`
- UAT03: `SARDJITO-UAT`
- UAT04: `IGNG-UAT`
- UAT05: `RSJPD-UAT`


## AWS Config Profile

```
$HOME/.aws/config
------------------------------------------------------------------------------
##### HUB #####
[profile BGSI-TF-User-Executor-RSCM]
role_arn = arn:aws:iam::442799077487:role/TF-Central-Role_442799077487
source_profile = BGSI-TF-User-Executor-RSCM
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSPON]
role_arn = arn:aws:iam::AWS_RSPON_ACCOUNT:role/TF-Central-Role_AWS_RSPON_ACCOUNT
source_profile = BGSI-TF-User-Executor-RSPON
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-SARDJITO]
role_arn = arn:aws:iam::AWS_SARDJITO_ACCOUNT:role/TF-Central-Role_AWS_SARDJITO_ACCOUNT
source_profile = BGSI-TF-User-Executor-SARDJITO
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-IGNG]
role_arn = arn:aws:iam::AWS_IGNG_ACCOUNT:role/TF-Central-Role_AWS_IGNG_ACCOUNT
source_profile = BGSI-TF-User-Executor-IGNG
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSJPD]
role_arn = arn:aws:iam::AWS_RSJPD_ACCOUNT:role/TF-Central-Role_AWS_RSJPD_ACCOUNT
source_profile = BGSI-TF-User-Executor-RSJPD
region = ap-southeast-3
output = json

##### UAT #####
[profile BGSI-TF-User-Executor-RSCM-UAT]
role_arn = arn:aws:iam::AWS_RSCM-UAT_ACCOUNT:role/TF-Central-Role_AWS_RSCM-UAT_ACCOUNT
source_profile = BGSI-TF-User-Executor-RSCM-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSPON-UAT]
role_arn = arn:aws:iam::AWS_RSPON-UAT_ACCOUNT:role/TF-Central-Role_AWS_RSPON-UAT_ACCOUNT
source_profile = BGSI-TF-User-Executor-RSPON-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-SARDJITO-UAT]
role_arn = arn:aws:iam::AWS_SARDJITO-UAT_ACCOUNT:role/TF-Central-Role_AWS_SARDJITO-UAT_ACCOUNT
source_profile = BGSI-TF-User-Executor-SARDJITO-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-IGNG-UAT]
role_arn = arn:aws:iam::AWS_IGNG-UAT_ACCOUNT:role/TF-Central-Role_AWS_IGNG-UAT_ACCOUNT
source_profile = BGSI-TF-User-Executor-IGNG-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSJPD-UAT]
role_arn = arn:aws:iam::AWS_RSJPD-UAT_ACCOUNT:role/Temp-TF-Central-Role_AWS_RSJPD-UAT_ACCOUNT
source_profile = BGSI-TF-User-Executor-RSJPD-UAT
region = ap-southeast-3
output = json
```

## AWS Credentials Profile

```
$HOME/.aws/credentials
------------------------------------------------------------------------------
[BGSI-TF-User-Executor-RSCM]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-RSPON]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-SARDJITO]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-IGNG]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-RSJPD]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-RSCM-UAT]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-RSPON-UAT]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-SARDJITO-UAT]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-IGNG-UAT]
aws_access_key_id =
aws_secret_access_key =

[BGSI-TF-User-Executor-RSJPD-UAT]
#aws_access_key_id =
#aws_secret_access_key =
```

## Atlantis Config
- Repository (repo.yaml)

```
# Repository configurations
repos:
- id: github.com/bgsi-id/satusehat-research
  branch: /.*/
  apply_requirements: [approved, mergeable]
  allowed_overrides: [workflow, plan_requirements, apply_requirements]
  allow_custom_workflows: true
  delete_source_branch_on_merge: true
  workflow: dynamic-workflow

workflows:
  dynamic-workflow:
    plan:
      steps:
      - run: atlantis-deploy rscm plan
    apply:
      steps:
      - run: atlantis-deploy rscm apply

  # HUB Workflows
  rscm-workflow:
    plan:
      steps:
      - run: atlantis-deploy rscm plan
    apply:
      steps:
      - run: atlantis-deploy rscm apply

  rspon-workflow:
    plan:
      steps:
      - run: atlantis-deploy rspon plan
    apply:
      steps:
      - run: atlantis-deploy rspon apply

  sardjito-workflow:
    plan:
      steps:
      - run: atlantis-deploy sardjito plan
    apply:
      steps:
      - run: atlantis-deploy sardjito apply

  igng-workflow:
    plan:
      steps:
      - run: atlantis-deploy igng plan
    apply:
      steps:
      - run: atlantis-deploy igng apply

  rsjpd-workflow:
    plan:
      steps:
      - run: atlantis-deploy rsjpd plan
    apply:
      steps:
      - run: atlantis-deploy rsjpd apply


  # UAT Workflows
  rscm-uat-workflow:
    plan:
      steps:
      - run: atlantis-deploy rscm-uat plan
    apply:
      steps:
      - run: atlantis-deploy rscm-uat apply

  rspon-uat-workflow:
    plan:
      steps:
      - run: atlantis-deploy rspon-uat plan
    apply:
      steps:
      - run: atlantis-deploy rspon-uat apply

  sardjito-uat-workflow:
    plan:
      steps:
      - run: atlantis-deploy sardjito-uat plan
    apply:
      steps:
      - run: atlantis-deploy sardjito-uat apply

  igng-uat-workflow:
    plan:
      steps:
      - run: atlantis-deploy igng-uat plan
    apply:
      steps:
      - run: atlantis-deploy igng-uat apply

  rsjpd-uat-workflow:
    plan:
      steps:
      - run: atlantis-deploy rsjpd-uat plan
    apply:
      steps:
      - run: atlantis-deploy rsjpd-uat apply
```

- Atlantis Serverside (atlantis.yaml)

```
version: 3

automerge: true
autodiscover:
  mode: auto
delete_source_branch_on_merge: true
parallel_plan: true
parallel_apply: true
abort_on_execution_order_fail: true

projects:
- name: bgsi-main
  branch: /main/
  dir: .
  workspace: default
  terraform_version: &tf_version v1.9.4
  execution_order_group: 1
  autoplan:
    when_modified: &tf_files
      - "../modules/**/*.tf"
      - ".terraform.lock.hcl"
      - "*.json"
      - "*.yaml"
      - "*.js"
      - "*.tf"
      - "*.tfvars"
      - "*.hcl"
    enabled: true
  plan_requirements: [approved]
  apply_requirements: [approved]
  workflow: rscm-workflow

- name: bgsi-rscm
  branch: /rscm/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 2
  autoplan:
    when_modified: *tf_files
  workflow: rscm-workflow

- name: bgsi-rspon
  branch: /rspon/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 3
  autoplan:
    when_modified: *tf_files
  workflow: rspon-workflow

- name: bgsi-sardjito
  branch: /sardjito/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 4
  autoplan:
    when_modified: *tf_files
  workflow: sardjito-workflow

- name: bgsi-igng
  branch: /igng/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 5
  autoplan:
    when_modified: *tf_files
  workflow: igng-workflow

- name: bgsi-rsjpd
  branch: /rsjpd/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 6
  autoplan:
    when_modified: *tf_files
  workflow: rsjpd-workflow

- name: bgsi-rscm-uat
  branch: /rscm-uat/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 7
  autoplan:
    when_modified: *tf_files
  workflow: rscm-uat-workflow

- name: bgsi-rspon-uat
  branch: /rspon-uat/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 8
  autoplan:
    when_modified: *tf_files
  workflow: rspon-uat-workflow

- name: bgsi-sardjito-uat
  branch: /sardjito-uat/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 9
  autoplan:
    when_modified: *tf_files
  workflow: sardjito-uat-workflow

- name: bgsi-igng-uat
  branch: /igng-uat/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 10
  autoplan:
    when_modified: *tf_files
  workflow: igng-uat-workflow

- name: bgsi-rsjpd-uat
  branch: /rsjpd-uat/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 11
  autoplan:
    when_modified: *tf_files
  workflow: rsjpd-uat-workflow
```
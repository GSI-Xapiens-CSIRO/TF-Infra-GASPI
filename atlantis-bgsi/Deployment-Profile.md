# Deployment Profile for BGSI

## Defining Workflow Code
- HUB01: `RSCM`
- HUB02: `RSPON`
- HUB03: `SARDJITO`
- HUB04: `RSNGOERAH`
- HUB05: `RSJPD`
- UAT01: `RSCM-UAT`
- UAT02: `RSPON-UAT`
- UAT03: `SARDJITO-UAT`
- UAT04: `RSNGOERAH-UAT`
- UAT05: `RSJPD-UAT`


## AWS Config Profile

```
#  $HOME/.aws/config #

## PROD ##
[profile BGSI-TF-User-Executor-RSCM]
role_arn = arn:aws:iam::442799077487:role/TF-Central-Role_442799077487
source_profile = BGSI-TF-User-Executor-RSCM
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSPON]
role_arn = arn:aws:iam::829990487185:role/TF-Central-Role_829990487185
source_profile = BGSI-TF-User-Executor-RSPON
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-SARDJITO]
role_arn = arn:aws:iam::938674806253:role/TF-Central-Role_AWS_ACCOUNT_ID
source_profile = BGSI-TF-User-Executor-SARDJITO
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSNGOERAH]
role_arn = arn:aws:iam::136839993415:role/TF-Central-Role_136839993415
source_profile = BGSI-TF-User-Executor-RSNGOERAH
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSJPD]
role_arn = arn:aws:iam::602006056899:role/TF-Central-Role_602006056899
source_profile = BGSI-TF-User-Executor-RSJPD
region = ap-southeast-3
output = json


## UAT ##
[profile BGSI-TF-User-Executor-RSCM-UAT]
role_arn = arn:aws:iam::695094375681:role/TF-Central-Role_695094375681
source_profile = BGSI-TF-User-Executor-RSCM-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSPON-UAT]
role_arn = arn:aws:iam::741464515101:role/TF-Central-Role_741464515101
source_profile = BGSI-TF-User-Executor-RSPON-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-SARDJITO-UAT]
role_arn = arn:aws:iam::819520291687:role/TF-Central-Role_819520291687
source_profile = BGSI-TF-User-Executor-SARDJITO-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSNGOERAH-UAT]
role_arn = arn:aws:iam::899630542732:role/TF-Central-Role_899630542732
source_profile = BGSI-TF-User-Executor-RSNGOERAH-UAT
region = ap-southeast-3
output = json

[profile BGSI-TF-User-Executor-RSJPD-UAT]
role_arn = arn:aws:iam::148450585096:role/TF-Central-Role_148450585096
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

[BGSI-TF-User-Executor-RSNGOERAH]
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

[BGSI-TF-User-Executor-RSNGOERAH-UAT]
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

  rsngoerah-workflow:
    plan:
      steps:
      - run: atlantis-deploy rsngoerah plan
    apply:
      steps:
      - run: atlantis-deploy rsngoerah apply

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

  rsngoerah-uat-workflow:
    plan:
      steps:
      - run: atlantis-deploy rsngoerah-uat plan
    apply:
      steps:
      - run: atlantis-deploy rsngoerah-uat apply

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

- name: bgsi-rsngoerah
  branch: /rsngoerah/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 5
  autoplan:
    when_modified: *tf_files
  workflow: rsngoerah-workflow

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

- name: bgsi-rsngoerah-uat
  branch: /rsngoerah-uat/
  dir: .
  workspace: default
  terraform_version: *tf_version
  execution_order_group: 10
  autoplan:
    when_modified: *tf_files
  workflow: rsngoerah-uat-workflow

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
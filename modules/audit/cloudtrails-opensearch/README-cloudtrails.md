

## Folder Structure

```
modules/
└── cloudtrail/
    ├── README.md
    ├── athena.tf
    ├── cloudwatch.tf
    ├── data.tf
    ├── examples/
    │   ├── complete/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   └── simple/
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── terraform.tfvars
    │       └── variables.tf
    ├── iam.tf
    ├── kms.tf
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── queries/
    │   ├── analysis/
    │   │   ├── api_activity.sql
    │   │   ├── error_analysis.sql
    │   │   ├── service_usage.sql
    │   │   └── user_activity.sql
    │   └── tables/
    │       └── create_tables.sql
    ├── s3.tf
    ├── sns.tf
    ├── templates/
    │   ├── bucket_policy.json.tpl
    │   ├── cloudwatch_policy.json.tpl
    │   ├── kms_policy.json.tpl
    │   └── trust_policy.json.tpl
    ├── tests/
    │   └── cloudtrail_test.go
    ├── variables.tf
    └── versions.tf
```
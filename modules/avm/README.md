# AWS AVM (Account Vending Machine)

Terraform module to provision an AWS account with a TFE workspace backed by a VCS project.

Overview of Account setup: 

<img src="../../images/MCAF_landing_zone_account_setup_v040.png" width="800"> 

## AWS Config Rules

If you would like to authorize other accounts to aggregate AWS Config data, the account IDs and regions can be passed via the variable `aws_config` using the attributes `aggregator_account_ids` and `aggregator_regions` respectively.

NOTE: Control Tower already authorizes the `audit` account to aggregate Config data from all other accounts in the organization, so there is no need to specify the `audit` account ID in the `aggregator_account_ids` list.

Example:

```hcl
aws_config = {
  aggregator_account_ids = ["123456789012"]
  aggregator_regions     = ["eu-west-1"]
}
```

## Datadog Integration

This module supports an optional Datadog-AWS integration. This integration makes it easier for you to forward metrics and logs from your AWS account to Datadog.

In order to enable the integration, you can pass an object to the variable `datadog` containing the following attributes:

- `api_key`: sets the Datadog API key
- `enable_integration`: set to `true` to configure the [Datadog AWS integration](https://docs.datadoghq.com/integrations/amazon_web_services/)
- `install_log_forwarder`: set to `true` to install the [Datadog Forwarder](https://docs.datadoghq.com/serverless/forwarder/)
- `site_url`: set to `datadoghq.com` for US region or `datadoghq.eu` for EU region [Datadog Forwarder](https://docs.datadoghq.com/serverless/forwarder/)

In case you don't want to use the integration, you can configure the Datadog provider like in the example below:

```hcl
provider "datadog" {
  validate = false
}
```

This should prevent the provider from asking you for a Datadog API Key and allow the module to be provisioned without the integration resources.

## Monitoring IAM Activity

This module offers the capability of monitoring IAM activity of both the Root user and AWS SSO roles. To enable this feature, you have to provide the ARN of the SNS Topic that should receive events in case any activity is detected.

The topic ARN can be set using the variable `monitor_iam_activity_sns_topic_arn`.

These are the type of events that will be monitored:

- Any activity made by the root user of the account.
- Any manual changes made by AWS SSO roles (read-only operations and console logins are not taken into account).

In case you would like to NOT monitor AWS SSO roles, you can set `monitor_iam_activity_sso` to `false`.

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.16.0 |
| datadog | >= 2.14 |
| github | >= 3.1.0 |
| tfe | >= 0.21.0 |

## Providers

| Name | Version |
|------|---------|
| aws.managed\_by\_inception | >= 3.16.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| defaults | Default options for this module | <pre>object({<br>    account_iam_prefix     = string<br>    email_prefix           = string<br>    github_organization    = string<br>    sso_email              = string<br>    terraform_organization = string<br>    terraform_version      = string<br>  })</pre> | n/a | yes |
| name | Stack name | `string` | n/a | yes |
| oauth\_token\_id | The OAuth token ID of the VCS provider | `string` | n/a | yes |
| tags | Map of tags | `map(string)` | n/a | yes |
| account\_name | Name of the AWS Service Catalog provisioned account (overrides computed name from the `name` variable) | `string` | `null` | no |
| account\_password\_policy | AWS account password policy parameters | <pre>object({<br>    allow_users_to_change        = bool<br>    max_age                      = number<br>    minimum_length               = number<br>    require_lowercase_characters = bool<br>    require_numbers              = bool<br>    require_symbols              = bool<br>    require_uppercase_characters = bool<br>    reuse_prevention_history     = number<br>  })</pre> | <pre>{<br>  "allow_users_to_change": true,<br>  "max_age": 90,<br>  "minimum_length": 14,<br>  "require_lowercase_characters": true,<br>  "require_numbers": true,<br>  "require_symbols": true,<br>  "require_uppercase_characters": true,<br>  "reuse_prevention_history": 24<br>}</pre> | no |
| aws\_config | AWS Config settings | <pre>object({<br>    aggregator_account_ids = list(string)<br>    aggregator_regions     = list(string)<br>  })</pre> | `null` | no |
| aws\_ebs\_encryption\_by\_default | Set to true to enable AWS Elastic Block Store encryption by default | `bool` | `true` | no |
| create\_account\_password\_policy | Set to true to create the AWS account password policy | `bool` | `true` | no |
| create\_workspace | Set to true to create a Terraform Cloud workspace | `bool` | `true` | no |
| datadog | Datadog integration options | <pre>object({<br>    api_key               = string<br>    datadog_tags          = list(string)<br>    enable_integration    = bool<br>    install_log_forwarder = bool<br>    site_url              = string<br>  })</pre> | `null` | no |
| email | Email address of the account | `string` | `null` | no |
| environment | Stack environment | `string` | `null` | no |
| kms\_key\_id | The KMS key ID used to encrypt the SSM parameters | `string` | `null` | no |
| monitor\_iam\_activity\_sns\_topic\_arn | SNS Topic that should receive captured IAM activity events | `string` | `null` | no |
| monitor\_iam\_activity\_sso | Whether IAM activity from SSO roles should be monitored | `bool` | `true` | no |
| organizational\_unit | Organizational Unit to place account in | `string` | `null` | no |
| provisioned\_product\_name | A custom name for the provisioned product | `string` | `null` | no |
| region | The default region of the account | `string` | `"eu-west-1"` | no |
| ssh\_key\_id | The SSH key ID to assign to the TFE workspace | `string` | `null` | no |
| sso\_firstname | The firstname of the Control Tower SSO account | `string` | `"AWS Control Tower"` | no |
| sso\_lastname | The lastname of the Control Tower SSO account | `string` | `"Admin"` | no |
| terraform\_auto\_apply | Whether to automatically apply changes when a Terraform plan is successful | `bool` | `false` | no |
| terraform\_version | Terraform version to use | `string` | `null` | no |
| tfe\_agent\_pool\_id | Terraform agent pool ID | `string` | `null` | no |
| tfe\_vcs\_branch | Terraform VCS branch to use | `string` | `"master"` | no |
| trigger\_prefixes | List of repository-root-relative paths which should be tracked for changes | `list(string)` | <pre>[<br>  "modules"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The AWS account ID |
| workspace\_id | The TFE workspace ID |

<!--- END_TF_DOCS --->

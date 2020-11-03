locals {
  aws_config_rules = concat(
    var.aws_config_rules,
    [
      "CLOUD_TRAIL_ENABLED",
      "ENCRYPTED_VOLUMES",
      "ROOT_ACCOUNT_MFA_ENABLED",
      "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    ]
  )
}

resource "aws_config_organization_managed_rule" "default" {
  for_each        = toset(local.aws_config_rules)
  name            = each.value
  rule_identifier = each.value
}

module "datadog_master" {
  count                 = var.datadog_integration.master.enabled == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  api_key               = var.datadog_api_key
  install_log_forwarder = var.datadog_integration.master.forward_logs
  tags                  = var.tags
}

module "kms_key" {
  source      = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.1.5"
  name        = "inception"
  description = "KMS key used for encrypting SSM parameters"
  tags        = var.tags
}

module "security_hub_master" {
  source = "./modules/security_hub"
}

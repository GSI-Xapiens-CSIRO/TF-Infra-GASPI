# ==========================================================================
#  Module Budget: output.tf
# --------------------------------------------------------------------------
#  Description:
#    Output Terraform Value
# --------------------------------------------------------------------------
#    - Billing Monthly Forcasted Info
#    - Billing Monthly Forcasted Notif
#    - Billing Monthly Billing Info
#    - Billing Monthly Billing Notif
# ==========================================================================

output "billing_monthly_forcasted_info" {
  description = "Monthly forcasted billing info"
  value = {
    billing_name        = aws_budgets_budget.monthly_forcasted.name
    billing_type        = aws_budgets_budget.monthly_forcasted.budget_type
    billing_limit       = aws_budgets_budget.monthly_forcasted.limit_amount
    billing_limit_unit  = aws_budgets_budget.monthly_forcasted.limit_unit
    billing_time_unit   = aws_budgets_budget.monthly_forcasted.time_unit
    billing_time_period = aws_budgets_budget.monthly_forcasted.time_period_start
  }
}

output "billing_monthly_forcasted_notif" {
  description = "Monthly forcasted billing notification email"
  value = {
    notif_operator = aws_budgets_budget.monthly_forcasted.notification
  }
}

output "billing_monthly_billing_info" {
  description = "Monthly budget billing info"
  value = {
    billing_name        = aws_budgets_budget.monthly_budget.name
    billing_type        = aws_budgets_budget.monthly_budget.budget_type
    billing_limit       = aws_budgets_budget.monthly_budget.limit_amount
    billing_limit_unit  = aws_budgets_budget.monthly_budget.limit_unit
    billing_time_unit   = aws_budgets_budget.monthly_budget.time_unit
    billing_time_period = aws_budgets_budget.monthly_budget.time_period_start
  }
}

output "billing_monthly_billing_notif" {
  description = "Monthly budget billing notification email"
  value = {
    notif_operator = aws_budgets_budget.monthly_budget.notification
  }
}

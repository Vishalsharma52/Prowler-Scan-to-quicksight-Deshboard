variable "access_key" {
  type    = string
  default = ""
}
variable "secret_key" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "ConfigBucketName" {
  type    = string
  default = "configbucketforsecurityprowler"

}
variable "create_topic" {
  type    = bool
  default = true
}

variable "post_fix" {
  type    = string
  default = "ProwlerWithQuicksight"
}

variable "notification_email" {
  type    = string
  default = ""
}

variable "all_supported" {
  type    = bool
  default = true
}

variable "include_global_resource_types" {
  type    = bool
  default = true
}

variable "resource_types" {
  type    = list(string)
  default = []
}

variable "securityhub_standards" {
  type    = list(string)
  default = ["arn:aws:securityhub:ap-south-1::standards/cis-aws-foundations-benchmark/v/1.4.0", "arn:aws:securityhub:ap-south-1::standards/aws-foundational-security-best-practices/v/1.0.0"]
}

variable "securityhub_standards_count" {
  type    = number
  default = 2
}

variable "column_definitions" {
  type = list(object({
    name = string
    type = string
  }))
  default = [
    { name = "id", type = "STRING" },
    { name = "awsaccountid", type = "STRING" },
    { name = "createdat", type = "STRING" },
    { name = "updatedat", type = "STRING" },
    { name = "productarn", type = "STRING" },
    { name = "checkid", type = "STRING" },
    { name = "region", type = "STRING" },
    { name = "worflowstatus", type = "STRING" },
    { name = "compliancestatus", type = "STRING" },
    { name = "findingtype", type = "STRING" },
    { name = "findingtitle", type = "STRING" },
    { name = "findingdescription", type = "STRING" },
    { name = "severity", type = "STRING" },
    { name = "resourcetype", type = "STRING" },
    { name = "resourceid", type = "STRING" },
    { name = "notes", type = "STRING" },
  ]
}

variable "dashboardname" {
  type    = string
  default = "SecurityProwlerDashboard"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to get subnets from"
  default     = ""
}

variable "subnet_ids" {
  type    = list(string)
  default = [""]
}

variable "security_groups" {
  type    = list(string)
  default = [""]
}


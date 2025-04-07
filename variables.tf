# Origin Access Identities

variable "origin_access_identities" {
  description = "List of CloudFront origin access identities (value as a comment)"
  type        = map(string)
  default     = {}
}

# Origin Access Controls

variable "create_origin_access_control" {
  description = "Controls if CloudFront origin access control should be created"
  type        = bool
  default     = false
}

variable "origin_access_control" {
  description = "Map of CloudFront origin access control"
  type = map(object({
    description      = optional(string)
    origin_type      = string
    signing_behavior = string
    signing_protocol = string
  }))

  default = {
    s3 = {
      origin_type      = "s3",
      signing_behavior = "always",
      signing_protocol = "sigv4"
    }
  }
}

# VPC Origins

variable "create_vpc_origin" {
  description = "If enabled, the resource for VPC origin will be created."
  type        = bool
  default     = false
}

variable "vpc_origin" {
  description = "Map of CloudFront VPC origin name to configuration"
  type = map(object({
    arn                    = string
    http_port              = number
    https_port             = number
    origin_protocol_policy = string
    origin_ssl_protocols = object({
      items    = list(string)
      quantity = number
    })
  }))
  default = {}
}

# Distribution

variable "create_distribution" {
  description = "Controls if CloudFront distribution should be created"
  type        = bool
  default     = true
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
  default     = null
}

variable "comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = null
}

variable "continuous_deployment_policy_id" {
  description = "Identifier of a continuous deployment policy. This argument should only be set on a production distribution."
  type        = string
  default     = null
}

variable "custom_error_responses" {
  description = "One or more custom error response elements"
  type = map(object({
    error_caching_min_ttl = optional(number)
    # error_code            = number # specified as map key
    response_code      = optional(number)
    response_page_path = optional(string)
  }))
  default = {}
}

variable "default_cache_behavior" {
  description = "The default cache behavior for this distribution"
  type = object({
    allowed_methods           = list(string)
    cached_methods            = list(string)
    cache_policy_id           = optional(string)
    compress                  = optional(bool)
    default_ttl               = optional(number)
    field_level_encryption_id = optional(string)
    lambda_function_associations = optional(map(object({
      lambda_arn   = string
      include_body = optional(bool)
    })), {})
    function_associations = optional(map(object({
      function_arn = string
    })), {})
    max_ttl                    = optional(number)
    min_ttl                    = optional(number)
    origin_request_policy_id   = optional(string)
    realtime_log_config_arn    = optional(string)
    response_headers_policy_id = optional(string)
    smooth_streaming           = optional(bool)
    target_origin_id           = string
    trusted_key_groups         = optional(list(string))
    trusted_signers            = optional(list(string))
    viewer_protocol_policy     = string
    grpc_config = optional(object({
      enabled = bool
    }))
  })
  default = null
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = null
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = null
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3, and http3. The default is http2."
  type        = string
  default     = null
}

variable "logging_config" {
  description = "The logging configuration that controls how logs are written to your distribution (maximum one)."
  type = object({
    bucket          = string
    prefix          = optional(string)
    include_cookies = optional(bool)
  })
  default = null
}

variable "ordered_cache_behavior" {
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  type = list(object({
    allowed_methods           = list(string)
    cached_methods            = list(string)
    cache_policy_id           = optional(string)
    compress                  = optional(bool)
    default_ttl               = optional(number)
    field_level_encryption_id = optional(string)
    lambda_function_associations = optional(map(object({
      lambda_arn   = string
      include_body = optional(bool)
    })), {})
    function_associations = optional(map(object({
      function_arn = string
    })), {})
    max_ttl                    = optional(number)
    min_ttl                    = optional(number)
    origin_request_policy_id   = optional(string)
    path_pattern               = string
    realtime_log_config_arn    = optional(string)
    response_headers_policy_id = optional(string)
    smooth_streaming           = optional(bool)
    target_origin_id           = string
    trusted_key_groups         = optional(list(string))
    trusted_signers            = optional(list(string))
    viewer_protocol_policy     = string
    grpc_config = optional(object({
      enabled = bool
    }))
  }))
  default = []
}

variable "origins" {
  description = "One or more origins for this distribution (multiples allowed)."
  type = map(object({
    connection_attempts = optional(number)
    connection_timeout  = optional(number)
    custom_origin_config = optional(object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number)
      origin_read_timeout      = optional(number)
    }))
    domain_name = string
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    origin_access_control_id = optional(string)
    # origin_id                = string # specified as map key
    origin_path = optional(string)
    origin_shield = optional(object({
      enabled              = bool
      origin_shield_region = optional(string)
    }))
    s3_origin_config = optional(object({
      origin_access_identity = optional(string)
    }))
    vpc_origin_config = optional(object({
      origin_keepalive_timeout = optional(number)
      origin_read_timeout      = optional(number)
      vpc_origin_id            = string
    }))
  }))
  default = {}
}

variable "origin_group" {
  description = "One or more origin_group for this distribution (multiples allowed)."
  type = list(object({
    origin_id = string
    failover_criteria = object({
      status_codes = list(number)
    })
    members = list(object({
      origin_id = string
    }))
  }))
  default = []
  validation {
    condition     = alltrue([for group in var.origin_group : length(group.members) == 2])
    error_message = "Each origin_group must have exactly 2 members"
  }
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = null
}

variable "geo_restriction" {
  description = "The restriction configuration for this distribution (geo_restrictions)"
  type = object({
    locations        = list(string)
    restriction_type = string
  })
  default = {
    restriction_type = "none"
    locations        = []
  }
}

variable "staging" {
  description = "Whether the distribution is a staging distribution."
  type        = bool
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = null
}

variable "viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type = object({
    acm_certificate_arn            = optional(string)
    cloudfront_default_certificate = optional(bool)
    iam_certificate_id             = optional(string)
    minimum_protocol_version       = optional(string)
    ssl_support_method             = optional(string)
  })
  default = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

variable "web_acl_id" {
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  type        = string
  default     = null
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = null
}

variable "wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this to false will skip the process."
  type        = bool
  default     = null
}

variable "create_monitoring_subscription" {
  description = "If enabled, the resource for monitoring subscription will created."
  type        = bool
  default     = false
}

variable "realtime_metrics_subscription_status" {
  description = "A flag that indicates whether additional CloudWatch metrics are enabled for a given CloudFront distribution. Valid values are `Enabled` and `Disabled`."
  type        = string
  default     = "Enabled"
}

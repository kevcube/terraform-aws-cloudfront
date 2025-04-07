resource "aws_cloudfront_origin_access_identity" "this" {
  for_each = var.create_origin_access_identity ? toset(var.origin_access_identities) : []

  comment = each.value

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = var.create_origin_access_control ? var.origin_access_control : {}

  name = each.key

  description                       = each.value.description
  origin_access_control_origin_type = each.value.origin_type
  signing_behavior                  = each.value.signing_behavior
  signing_protocol                  = each.value.signing_protocol
}

resource "aws_cloudfront_vpc_origin" "this" {
  for_each = var.create_vpc_origin ? var.vpc_origin : {}

  vpc_origin_endpoint_config {
    name                   = each.key
    arn                    = each.value.arn
    http_port              = each.value.http_port
    https_port             = each.value.https_port
    origin_protocol_policy = each.value.origin_protocol_policy

    origin_ssl_protocols {
      items    = each.value.origin_ssl_protocols.items
      quantity = each.value.origin_ssl_protocols.quantity
    }
  }

  tags = var.tags
}

resource "aws_cloudfront_distribution" "this" {
  count = var.create_distribution ? 1 : 0

  aliases = var.aliases
  comment = var.comment

  continuous_deployment_policy_id = var.continuous_deployment_policy_id

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  default_cache_behavior {
    allowed_methods           = var.default_cache_behavior.allowed_methods
    cached_methods            = var.default_cache_behavior.cached_methods
    cache_policy_id           = var.default_cache_behavior.cache_policy_id
    compress                  = var.default_cache_behavior.compress
    default_ttl               = var.default_cache_behavior.default_ttl
    field_level_encryption_id = var.default_cache_behavior.field_level_encryption_id

    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_associations

      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }

    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_associations

      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }

    max_ttl                    = var.default_cache_behavior.max_ttl
    min_ttl                    = var.default_cache_behavior.min_ttl
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    realtime_log_config_arn    = var.default_cache_behavior.realtime_log_config_arn
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id
    smooth_streaming           = var.default_cache_behavior.smooth_streaming
    target_origin_id           = var.default_cache_behavior.target_origin_id
    trusted_key_groups         = var.default_cache_behavior.trusted_key_groups
    trusted_signers            = var.default_cache_behavior.trusted_signers
    viewer_protocol_policy     = var.default_cache_behavior.viewer_protocol_policy

    dynamic "grpc_config" {
      for_each = coalesce(var.default_cache_behavior.grpc_config, {})
      content {
        enabled = grpc_config.value.enabled
      }
    }
  }

  default_root_object = var.default_root_object
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  http_version        = var.http_version

  dynamic "logging_config" {
    for_each = coalesce(var.logging_config, {})

    content {
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
      include_cookies = logging_config.value.include_cookies
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior

    content {
      allowed_methods           = ordered_cache_behavior.value.allowed_methods
      cached_methods            = ordered_cache_behavior.value.cached_methods
      cache_policy_id           = ordered_cache_behavior.value.cache_policy_id
      compress                  = ordered_cache_behavior.value.compress
      default_ttl               = ordered_cache_behavior.value.default_ttl
      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association

        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_association

        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      max_ttl                    = ordered_cache_behavior.value.max_ttl
      min_ttl                    = ordered_cache_behavior.value.min_ttl
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      path_pattern               = ordered_cache_behavior.value.path_pattern
      realtime_log_config_arn    = ordered_cache_behavior.value.realtime_log_config_arn
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
      smooth_streaming           = ordered_cache_behavior.value.smooth_streaming
      target_origin_id           = ordered_cache_behavior.value.target_origin_id
      trusted_key_groups         = ordered_cache_behavior.value.trusted_key_groups
      trusted_signers            = ordered_cache_behavior.value.trusted_signers
      viewer_protocol_policy     = ordered_cache_behavior.value.viewer_protocol_policy

      dynamic "grpc_config" {
        for_each = coalesce(ordered_cache_behavior.value.grpc_config, {})
        content {
          enabled = grpc_config.value.enabled
        }
      }
    }
  }

  dynamic "origin" {
    for_each = var.origins

    content {
      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout

      dynamic "custom_origin_config" {
        for_each = coalesce(origin.value.custom_origin_config, {})

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      domain_name = origin.value.domain_name

      dynamic "custom_header" {
        for_each = compact([origin.value.custom_headers])

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      origin_access_control_id = origin.value.origin_access_control_id
      origin_id                = origin.value.origin_id
      origin_path              = origin.value.origin_path

      dynamic "origin_shield" {
        for_each = compact([origin.value.origin_shield])

        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }

      dynamic "s3_origin_config" {
        for_each = compact([origin.value.s3_origin_config])

        content {
          origin_access_identity = origin.value.origin_access_identity
        }
      }

      dynamic "vpc_origin_config" {
        for_each = compact([origin.value.vpc_origin_config])

        content {
          origin_keepalive_timeout = origin.value.origin_keepalive_timeout
          origin_read_timeout      = origin.value.origin_read_timeout
          vpc_origin_id            = origin.value.vpc_origin_id
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.origin_group

    content {
      origin_id = origin_group.value.origin_id

      failover_criteria {
        status_codes = origin_group.value.failover_status_codes
      }

      member {
        origin_id = origin_group.value.primary_member_origin_id
      }

      member {
        origin_id = origin_group.value.secondary_member_origin_id
      }
    }
  }

  price_class = var.price_class

  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.geo_restriction]

      content {
        restriction_type = geo_restriction.value.restriction_type
        locations        = geo_restriction.value.locations
      }
    }
  }

  staging = var.staging
  tags    = var.tags

  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate.acm_certificate_arn
    cloudfront_default_certificate = var.viewer_certificate.cloudfront_default_certificate
    iam_certificate_id             = var.viewer_certificate.iam_certificate_id
    minimum_protocol_version       = var.viewer_certificate.minimum_protocol_version
    ssl_support_method             = var.viewer_certificate.ssl_support_method
  }

  web_acl_id          = var.web_acl_id
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
}

resource "aws_cloudfront_monitoring_subscription" "this" {
  count = var.create_distribution && var.create_monitoring_subscription ? 1 : 0

  distribution_id = aws_cloudfront_distribution.this[0].id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = var.realtime_metrics_subscription_status
    }
  }
}

data "aws_cloudfront_cache_policy" "this" {
  for_each = toset([for v in concat([var.default_cache_behavior], var.ordered_cache_behavior) : v.cache_policy_name if can(v.cache_policy_name)])

  name = each.key
}

data "aws_cloudfront_origin_request_policy" "this" {
  for_each = toset([for v in concat([var.default_cache_behavior], var.ordered_cache_behavior) : v.origin_request_policy_name if can(v.origin_request_policy_name)])

  name = each.key
}

data "aws_cloudfront_response_headers_policy" "this" {
  for_each = toset([for v in concat([var.default_cache_behavior], var.ordered_cache_behavior) : v.response_headers_policy_name if can(v.response_headers_policy_name)])

  name = each.key
}

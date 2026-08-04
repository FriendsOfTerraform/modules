resource "aws_instance" "ec2_instance" {
  ami = var.ami_id

  dynamic "cpu_options" {
    for_each = var.cpu_options != null ? [1] : []

    content {
      amd_sev_snp           = var.cpu_options.enable_amd_sev_snp ? "enabled" : "disabled"
      core_count            = var.cpu_options.core_count
      threads_per_core      = var.cpu_options.threads_per_core
      nested_virtualization = var.cpu_options.enable_nested_virtualization ? "enabled" : "disabled"
    }
  }

  dynamic "credit_specification" {
    for_each = startswith(var.instance_type, "t") ? [1] : []

    content {
      cpu_credits = var.cpu_credit_specification
    }
  }

  associate_public_ip_address = var.network_interface.auto_assign_public_ip
  disable_api_stop            = var.enable_instance_stop_protection
  disable_api_termination     = var.enable_instance_termination_protection
  get_password_data           = var.get_windows_password
  hibernation                 = var.enable_instance_hibernation
  iam_instance_profile        = var.iam_role_name != null ? aws_iam_instance_profile.iam_instance_profile[0].id : null
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name

  maintenance_options {
    auto_recovery = var.enable_auto_recovery ? "default" : "disabled"
  }

  dynamic "metadata_options" {
    for_each = var.instance_metadata_options != null ? [1] : []

    content {
      http_endpoint          = var.instance_metadata_options.enable_instance_metadata_service ? "enabled" : "disabled"
      http_tokens            = var.instance_metadata_options.requires_imdsv2 ? "required" : "optional"
      instance_metadata_tags = var.instance_metadata_options.allow_tags_in_instance_metadata ? "enabled" : "disabled"
    }
  }

  monitoring = var.enable_detailed_monitoring

  enclave_options {
    enabled = var.enable_nitro_enclaves
  }

  primary_network_interface {
    network_interface_id = aws_network_interface.primary_network_interface.id
  }

  dynamic "private_dns_name_options" {
    for_each = var.resource_based_naming_options != null ? [1] : []

    content {
      hostname_type                     = var.resource_based_naming_options.use_resource_based_naming_as_os_hostname ? "resource-name" : "ip-name"
      enable_resource_name_dns_a_record = var.resource_based_naming_options.answer_dns_hostname_ipv4_request
    }
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = var.ebs_volume.kms_key_id != null
    iops                  = var.ebs_volume.provisioned_iops
    kms_key_id            = var.ebs_volume.kms_key_id

    tags = merge(
      { Name = "${var.name}-root" },
      local.common_tags,
      var.ebs_volume.additional_tags,
      var.additional_tags_all
    )

    throughput  = var.ebs_volume.throughput
    volume_size = var.ebs_volume.size
    volume_type = var.ebs_volume.volume_type
  }

  dynamic "instance_market_options" {
    for_each = var.purchasing_option != null ? [1] : []

    content {
      market_type = var.purchasing_option.spot_instance != null ? "spot" : "spot" // Default to spot if not specified

      dynamic "spot_options" {
        for_each = var.purchasing_option.spot_instance != null ? [1] : []

        content {
          instance_interruption_behavior = var.purchasing_option.spot_instance.interruption_behavior
          max_price                      = var.purchasing_option.spot_instance.maximum_price
          spot_instance_type             = var.purchasing_option.spot_instance.request_type
          valid_until                    = var.purchasing_option.spot_instance.request_expiry_date
        }
      }
    }
  }

  tags = merge(
    { Name = var.name },
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )

  user_data        = var.user_data_config != null ? var.user_data_config.user_data : null
  user_data_base64 = var.user_data_config != null ? var.user_data_config.user_data_base64 : null
}

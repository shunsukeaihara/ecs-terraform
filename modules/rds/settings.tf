resource "aws_db_subnet_group" "this" {
  name        = var.name
  description = var.name
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name = var.name
    Made = "terraform"
  }
}

resource "aws_db_parameter_group" "this" {
  name        = var.name
  description = var.name
  family      = var.family

  dynamic parameter {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name = var.name
    Made = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_option_group" "this" {
  name                     = var.name
  option_group_description = var.name

  engine_name          = var.engine
  major_engine_version = var.major_engine_version

  dynamic option {
    for_each = var.options
    content {
      option_name = option.name
      option_settings {
        name  = option.name
        value = option.value
      }
    }
  }

  tags = {
    Name = var.name
    Made = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

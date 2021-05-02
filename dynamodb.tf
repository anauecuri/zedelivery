## tabela cliente
resource "aws_dynamodb_table" "cliente" {
  name             = "cliente"
  hash_key         = "CPFcliente"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
      enabled = true
  }

  server_side_encryption {
      enabled = true
  }

  attribute {
    name = "CPFcliente"
    type = "S"
  }

  replica {
    region_name = "us-east-2"
  }

  replica {
    region_name = "us-west-2"
  }

  tags = {
      Environment = "${var.Env}"
      region = "${var.region}"
  }
}

## tabela entregador
resource "aws_dynamodb_table" "entregador" {
  name             = "entregador"
  hash_key         = "CPFentregador"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
      enabled = true
  }

  server_side_encryption {
      enabled = true
  }

  attribute {
    name = "CPFentregador"
    type = "S"
  }

  replica {
    region_name = "us-east-2"
  }

  replica {
    region_name = "us-west-2"
  }

  tags = {
      Environment = "${var.Env}"
      region = "${var.region}"
  }
}

## tabela parceiro
resource "aws_dynamodb_table" "parceiro" {
  name             = "parceiro"
  hash_key         = "CNPJparceiro"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
      enabled = true
  }

  server_side_encryption {
      enabled = true
  }

  attribute {
    name = "CNPJparceiro"
    type = "S"
  }

  replica {
    region_name = "us-east-2"
  }

  replica {
    region_name = "us-west-2"
  }

  tags = {
      Environment = "${var.Env}"
      region = "${var.region}"
  }
}
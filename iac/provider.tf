provider "aws" {
  region  = "${var.region}"
  #version = "~> 2.0"
  version = "~> 3.13.0"
}

provider "aws" {
  alias   = "us"
  region  = "us-east-1"
}
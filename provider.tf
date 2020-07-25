### Backend ###

# terraform {
#    backend "s3" {
#        bucket = "anaue-bucket"
#        key = "anaue-bucket.tfstate"
#        region = "sa-east-1"
#        encrypt = true 
#        dynamodb_table = "ze-delivery-app"
#        
#    }
#        
#}

### Cloud Provider ###

provider "aws" {
  region     = "sa-east-1"
  version    = "~> 2.70.0"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}





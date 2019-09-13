provider "aws" {
  region  = var.region
  profile = var.profile
}
//Calling Network Module to root module
module "network" {
  source              = "./network"
  myvpc_cidr          = var.myvpc_cidr
  myvpc_tenancy       = var.myvpc_tenancy
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}
resource "aws_key_pair" "myssh_key" {
  key_name   = "myssh_key"
  public_key = file(var.path-to-public-key)
}
resource "aws_instance" "terraform-ansible-testbox" {
  ami                         = lookup(var.amis, var.region)
  key_name                    = aws_key_pair.myssh_key.key_name
  instance_type               = var.ec2type
  availability_zone           = data.aws_availability_zones.azone.names[0]
  vpc_security_group_ids      = [module.network.sg_id]
  subnet_id                   = module.network.public_subnet_id
  associate_public_ip_address = true
  tags = {
    Name = "Terraform-Ansible-Testbox"
  }
  provisioner "local-exec" {
    command = "sleep 30 && ansible-playbook -i ${self.public_ip}, master-playbook.yml --key-file=./${aws_key_pair.myssh_key.key_name} -u ${var.username}"
  }
}
# // create a dynamodb table for locking the state file
# resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
#   name           = "terraform-state-lock-dynamo"
#   hash_key       = "LockID"
#   read_capacity  = 20
#   write_capacity = 20
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   tags = {
#     Name = "DynamoDB Terraform State Lock Table"
#   }
# }
// Create Remote s3 Backend
# terraform {
#   backend "s3" {
#     bucket         = "my-tftest-s3bucket"
#     encrypt        = true
#     region         = "ap-south-1"
#     key            = "terraform.tfstate"
#     dynamodb_table = "terraform-state-lock-dynamo"
#   }
# }
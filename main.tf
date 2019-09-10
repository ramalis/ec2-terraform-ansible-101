variable "region" {}
variable "profile" {}
variable "ami" {}
variable "ec2type" {}
variable "keyname" {}
variable "username" {}
variable "path-to-public-key" {}

data "aws_availability_zones" "azone" {}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}
resource "aws_key_pair" "myssh_key" {
  key_name   = var.keyname
  public_key = file(var.path-to-public-key)
}
resource "aws_instance" "terraform-ansible-testbox" {
  ami                         = "${var.ami}"
  key_name                    = "${var.keyname}"
  instance_type               = "${var.ec2type}"
  availability_zone           = "${data.aws_availability_zones.azone.names[0]}"
  associate_public_ip_address = true
  tags = {
    Name = "Terraform-Ansible-Testbox"
  }
  provisioner "local-exec" {
    command = "sleep 30 && ansible-playbook -i ${self.public_ip}, master-playbook.yml --key-file=./${var.keyname} -u ${var.username}"
  }
}
# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  tags   = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
terraform {
  backend "s3" {
    bucket         = "my-tftest-s3bucket"
    encrypt        = true
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}



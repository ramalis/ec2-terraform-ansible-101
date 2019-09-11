// Variable Definition
variable "region" {}
variable "profile" {}
variable "myvpc_cidr" {}
variable "myvpc_tenancy" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "ami" {}
variable "ec2type" {}
variable "username" {}
variable "path-to-public-key" {}
data "aws_availability_zones" "azone" {}
//Outputs
output "myvpc" {
  value       = module.network.vpc_id
}
output "public_subnet" {
  value       = module.network.public_subnet_id
}
output "private_subnet" {
  value       = module.network.private_subnet_id
}
output "mysecurity_group" {
  value       = module.network.sg_id
}
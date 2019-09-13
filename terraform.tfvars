region              = "ap-south-1"
profile             = "test"
myvpc_cidr          = "10.0.0.0/16"
myvpc_tenancy       = "default"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
amis = {
  "ap-south-1" = "ami-020ca1ee6a0f716a9"
  "us-west-1"  = "ami-056ee704806822732"
  "us-east-1"  = "ami-035b3c7efe6d061d5"
}
ec2type            = "t2.micro"
username           = "ubuntu"
path-to-public-key = "/Users/ramalis/GDrive-arc/DevOps/ec2-terraform-ansible-101/myssh_key.pub"
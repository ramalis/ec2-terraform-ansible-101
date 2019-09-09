
provider "aws" {
  region  = "ap-south-1"
  profile = "test"
}
resource "aws_instance" "test_box" {
  ami               = "ami-020ca1ee6a0f716a9"
  key_name           = "terraform_keypair"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "ec2-TF-Ansible"
  }
  provisioner "local-exec" {
    command = "sleep 30 && ansible-playbook -i ${self.public_ip}, master-playbook.yml --key-file=./terraform_keypair.pem -u ubuntu"
  }
}



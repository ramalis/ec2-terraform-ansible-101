# ec2-terraform-ansible-101

cofigure aws access and secret keys in local system: 

aws configure --profile <aws iam userid>

verify the profile: 

aws configure list

view your aws configuration : 

cat ~/.aws/config

view your aws credentials : 

cat ~/.aws/credentials

project module structure:

ec2-terraform-ansible-101:

        |==>main
                |==>main.tf

                |==>vars.tf

                |==>terraform.tfvars

                |==>ansible.cfg
                
                |==>hosts
                
                |==>limits.conf

                |==>master-playbook.yml

                |==>vagrantfile

                |==>network module
                        |==>network.tf
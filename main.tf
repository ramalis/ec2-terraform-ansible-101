resource "aws_instance" "test_box" {
  ami = "ami-020ca1ee6a0f716a9"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  user_data = <<EOF
                  #!/bin/bash
                  apt-get install python
                EOF

  //  connection {
//    host = self.public_ip
//    user = "ubuntu"
//  }

  provisioner "ansible" {
    plays {
      playbook {
        file_path = "master-playbook.yml"
      }
      hosts = [aws_instance.test_box.public_ip]

      remote {
        use_sudo = true
        skip_install = false
        skip_cleanup = false
        install_version = ""
        local_installer_path = ""
        remote_installer_directory = "/tmp"
        bootstrap_directory = "/tmp"
      }
    }
  }
}



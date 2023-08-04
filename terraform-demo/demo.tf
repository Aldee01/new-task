terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider 
provider "aws" {
  region = "ca-central-1" 
}

resource "aws_efs_file_system" "AldeeEfs" {
  creation_token = "aldee-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true
}

resource "aws_efs_mount_target" "AldeeEfs" {
  file_system_id = aws_efs_file_system.AldeeEfs.id
  subnet_id      = "subnet-0282dfbe514f7f21f"  
  security_groups = ["sg-062df878bd4bab201"]  
}

resource "aws_instance" "aldeeweb" {
  ami           = " ami-0c63a96dc83836290"  
  instance_type = "t2.micro"      
  
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y amazon-efs-utils",  
      "sudo mkdir /efs",                        
      "sudo mount -t efs ${aws_efs_file_system.AldeeEfs.id}:/ /efs",  
      "echo '${aws_efs_file_system.AldeeEfs.id}:/ /efs efs defaults,_netdev 0 0' | sudo tee -a /etc/fstab"  
    ]
  }
}
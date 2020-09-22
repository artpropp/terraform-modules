provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "ssh-example" {
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = ["88.152.1.66/32"]
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "generated_key" {
  public_key = tls_private_key.example.public_key_openssh
}
resource "aws_instance" "ssh-example" {
  ami = "ami-0c960b947cbb2dd16"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh-example.id]
  key_name = aws_key_pair.generated_key.key_name

  provisioner "remote-exec" {
    inline = ["echo \"Hello, World - from $(uname -smn)\""]
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = tls_private_key.example.private_key_pem
  }
}
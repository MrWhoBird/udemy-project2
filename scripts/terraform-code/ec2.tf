provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ansible-server" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name = "udemy-projects"
  security_groups = ["udemy2-ttrend-sg"]
  user_data = file("${path.cwd}/../ansible/ansible-setup.sh")
  tags = {
    Name = "ansible-server"
  }
}

resource "aws_instance" "jenkins" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name = "udemy-projects"
  security_groups = ["udemy2-ttrend-sg"]
  for_each = toset(["jenkins-master", "jenkins-slave"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "udemy2-ttrend-sg" {
  name        = "udemy2-ttrend-sg"
  description = "Allow ssh and jenkins traffic"
  tags = {
    Name = "udemy2-ttrend-sg"
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jenkins access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# data "aws_vpc" "vpc" {
#    filter {
#     name   = "tag:Name"
#     values = ["stage-vpc"]
#   }
# }

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "bastion" {
  name        = "bastion-stg"
  description = "Allow admin inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "allow admin in bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Stg-Bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-091a58610910a87a9"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public[0].id
  security_groups = [aws_security_group.bastion.id]

  tags = {
    Name = "Bastion",
    Program = "true"
  }
}

resource "aws_security_group" "Apache" {
  name        = "Apache-Stg"
  description = "Allow admin inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "allow admin in Apache"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [ aws_security_group.bastion.id ]
  }
  ingress {
    description      = "allow alb-end user in Apache"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [ aws_security_group.alb.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Stg-Apache-sg"
  }
}

resource "aws_instance" "apache" {
  ami           = "ami-091a58610910a87a9"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private[0].id
  security_groups = [aws_security_group.Apache.id]

  tags = {
    Name = "Apache",
    Program = "true"
  }
}
resource "aws_instance" "grafana" {
  ami           = "ami-091a58610910a87a9"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private[0].id
  security_groups = [aws_security_group.Apache.id]

  tags = {
    Name = "Grafana",
    Program = "true"
  }
}

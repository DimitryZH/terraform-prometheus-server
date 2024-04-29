data "aws_ami" "latest_ubuntu" {
  most_recent = true

  filter {
    name   = "description"
    values = ["Canonical, Ubuntu, 24.04 LTS, amd64 noble image build on 2024-04-23"]
  }

  owners = ["099720109477"] # Canonical owner ID for Ubuntu AMIs
}

resource "aws_instance" "web" {
  ami                    = "ami-04b70fa74e45c3917"  # Use the specific AMI ID
  instance_type          = var.server_size
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    Name  = "${var.server_name}-WebServer"
    Owner = "Dmitry Zhuravlev"
  }
}


resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_security_group" "web" {
  name_prefix = "${var.server_name}-WebServer-SG"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.server_name}-WebServer SecurityGroup"
    Owner = "Dmitry Zhuravlev"
  }
}

resource "aws_eip" "web" {
 domain    = "vpc" # Need to add in new AWS Provider version
  instance = aws_instance.web.id
  tags = {
    Name  = "${var.server_name}-WebServer-IP"
    Owner = "Dmitry Zhuravlev"
  }
}

provider "aws"{
  access_key =""
  secret_key =""
  region = "${var.region}"
}

resource "aws_vpc" "tk_main_vpc"{
  cidr_block = "${var.vpc-cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "TK_VPC"
  }
}

resource "aws_subnet" "tk_public_subnet" {
  vpc_id     = "${aws_vpc.tk_main_vpc.id}"
  cidr_block = "${var.subnet-cidr}"

  tags = {
    Name = "TKPUB"
  }
}

resource "aws_subnet" "tk_private_subnet" {
  vpc_id     = "${aws_vpc.tk_main_vpc.id}"
  cidr_block = "${var.subnet-private-cidr}"

  tags = {
    Name = "TKPRI"
  }
}

resource "aws_internet_gateway" "tk_igw" {
  vpc_id = "${aws_vpc.tk_main_vpc.id}"

  tags {
    Name = "TK_IGW"
  }
}

resource "aws_route_table" "tk_rt" {
  vpc_id = "${aws_vpc.tk_main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tk_igw.id}"
  }

  tags {
    Name = "TK_PublicSubnetRT"
  }
}

resource "aws_route_table_association" "tk_rt" {
  subnet_id = "${aws_subnet.tk_public_subnet.id}"
  route_table_id = "${aws_route_table.tk_rt.id}"
}

resource "aws_security_group" "tk_sgdb"{
  name = "tk_sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.subnet-cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.subnet-cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.subnet-cidr}"]
  }

  vpc_id = "${aws_vpc.tk_main_vpc.id}"

  tags {
    Name = "TK Private SG"
  }
}

resource "aws_key_pair" "tk_default" {
  key_name = "tkhanterraform"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "tk_web" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.tk_default.id}"
   subnet_id = "${aws_subnet.tk_public_subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.tk_sgdb.id}"]
   associate_public_ip_address = true

  tags {
    Name = "tk_webserver"
  }
}

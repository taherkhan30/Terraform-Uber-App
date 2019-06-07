
variable "region" {
  default = "eu-west-1"
}
variable "vpc-cidr" {
  default = "10.15.0.0/16"
}
variable "subnet-cidr"{
  default = "10.15.1.0/24"
}
variable "subnet-private-cidr"{
  default = "10.15.2.0/24"
}
variable "ami" {
  description = "Amazon Linux AMI uber"
  default = "ami-0b45d039456f24807"
}
variable "key_path" {
  description = "SSH Public Key path"
  default = "~/.ssh/id_rsa.pub"
}

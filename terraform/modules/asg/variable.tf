variable "ami_id" {
  type = string
  default = "ami-007ec828a062d87a5"
}

variable "vpc_zone_identifier" {
  type = list(string)
  default = [ "vpc-01543" ]
}

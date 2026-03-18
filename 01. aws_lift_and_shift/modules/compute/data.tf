data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

data "aws_region" "current" {}

locals {
  my_local_ip = chomp(data.http.icanhazip.response_body)
}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

locals {
  my_local_ip = chomp(data.http.icanhazip.response_body)
}

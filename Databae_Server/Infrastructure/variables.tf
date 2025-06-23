variable "region" {
  description = "Region to deploy resources in"
  default     = "us-east-1"
}
variable "zone" {
  description = "Availability zone to deploy resources in"
  default     = "us-east-1a"
}
variable "amiID" {
  type        = map(any)
  description = "value of amiID"
  default = {
    "us-east-1" = "ami-07db26ec72b770f6e"
    "us-east-2" = "ami-058a8a5ab36292159"
  }
}
variable "webuser" {
  default = "ubuntu"
}
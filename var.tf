variable "region" {
  description = "The AWS region to deploy the resources in"
  default     = "us-east-1"

}
variable "zone" {
  description = "The availability zone to deploy the resources in"
  default     = "us-east-1a"

}
variable "amiID" {
  type = map(any)
  default = {
    "us-east-1" = "ami-084568db4383264d4"
    "us-east-2" = "ami-058a8a5ab36292159"
  }
}
variable "webuser" {
  default = "ubuntu"
}
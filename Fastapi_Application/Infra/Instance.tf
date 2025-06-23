resource "aws_instance" "fastapi" {
  ami                    = var.amiID[var.region]
  instance_type          = "t3.medium"
  key_name               = "FastApi-key"
  vpc_security_group_ids = [aws_security_group.fastapi-sg.id]
  availability_zone      = var.zone
  count                  = 1
  tags = {
    Name    = "FastaApi-Instance"
    Project = "FastApi"
  }
  provisioner "file" {
    source      = "/Users/hemantkumar/Developer/backend/Fastapi-Application-Deployement-using-Terraform/Fastapi_Application/Configuration/web.sh"
    destination = "/tmp/web.sh"
  }
  connection {
    type        = "ssh"
    user        = var.webuser
    private_key = file(("fastapi-key.pem"))
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> ips.txt"
  }
}
resource "aws_ec2_instance_state" "web_state" {
  count       = length(aws_instance.fastapi)
  instance_id = aws_instance.fastapi[count.index].id
  state       = "running"
}
resource "aws_eip" "fastapi_eip" {
  count      = length(aws_instance.fastapi)
  instance   = aws_instance.fastapi[count.index].id
  depends_on = [aws_instance.fastapi]
}

output "Fastapi_public_ip" {
  value = aws_instance.fastapi.*.public_ip
}
output "fastapi_private_ip" {
  value = aws_instance.fastapi.*.private_ip
}
output "fastapi_elastic_ip" {
  value = aws_eip.fastapi_eip[*].public_ip
}
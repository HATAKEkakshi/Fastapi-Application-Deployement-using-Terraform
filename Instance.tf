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
    source      = "web.sh"
    destination = "/root/web.sh"
  }
  connection {
    type        = "ssh"
    user        = var.webuser
    private_key = file(("fastapi-key.pem"))
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/web.sh",
      "sudo /root/web.sh"
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
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.fastapi[0].id
}
output "Fastapi_public_ip" {
  value = aws_instance.fastapi.*.public_ip
}
output "fastapi_private_ip" {
  value = aws_instance.fastapi.*.private_ip
}
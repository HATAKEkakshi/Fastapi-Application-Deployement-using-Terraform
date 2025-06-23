resource "aws_instance" "Fastapi" {
  ami                    = var.amiID[var.region]
  instance_type          = "t3.micro"
  key_name               = "Fastapi-key"
  availability_zone      = var.zone
  vpc_security_group_ids = [aws_security_group.Fastapi.id]
  count                  = 1
  tags = {
    Name    = "Fastapi"
    Project = "Version-1"
  }
  provisioner "file" {
    source      = "/Users/hemantkumar/Developer/CuraDocs/CuraDocs_Depolyment/Dev/Cache_Server/Configuration/redis-docker-services.service"
    destination = "/tmp/redis-docker-services.service"
  }
  provisioner "file" {
    source      = "/Users/hemantkumar/Developer/backend/Fastapi-Application-Deployement-using-Terraform/Cache_Server/Configuration/redis-docker-cleanup.service"
    destination = "/tmp/redis-docker-cleanup.service"
  }
  provisioner "file" {
    source      = "/Users/hemantkumar/Developer/CuraDocs/CuraDocs_Depolyment/Dev/Cache_Server/Installation/cache.sh"
    destination = "/tmp/cache.sh"
  }
  connection {
    type        = "ssh"
    user        = var.webuser
    private_key = file("/Users/hemantkumar/Developer/CuraDocs/CuraDocs_Depolyment/Dev/Cache_Server/Infrastructure/Auth/Fastapi.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/cache.sh",
      "sudo /tmp/cache.sh"
    ]
  }
  provisioner "local-exec" {
    command = "echo Fastapi_Private_IP: ${self.private_ip} >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo Fastapi_Public_IP:${self.public_ip} >> ips.txt"
  }
}
resource "aws_ec2_instance_state" "web_state" {
  count       = length(aws_instance.Fastapi)
  instance_id = aws_instance.Fastapi[count.index].id
  state       = "running"
}
output "Fastapi_public_ip" {
  value = aws_instance.Fastapi.*.public_ip
}
output "fastapi_private_ip" {
  value = aws_instance.Fastapi.*.private_ip
}

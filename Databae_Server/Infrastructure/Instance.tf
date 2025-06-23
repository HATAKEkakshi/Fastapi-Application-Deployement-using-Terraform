resource "aws_instance" "Fastapi-Dev-Database" {
  ami                    = var.amiID[var.region]
  instance_type          = "t3.micro"
  key_name               = "Fastapi-Dev-Database-key"
  availability_zone      = var.zone
  vpc_security_group_ids = [aws_security_group.Fastapi-Dev-Database.id]
  count                  = 1
  tags = {
    Name    = "Fastapi-Dev-Database"
    Project = "Version-1"
  }
  provisioner "file" {
    source      = "/Users/hemantkumar/Developer/backend/Fastapi-Application-Deployement-using-Terraform/Databae_Server/Configuration/mongod.conf"
    destination = "/tmp/mongod.conf"
  }
  provisioner "file" {
    source      = "/Users/hemantkumar/Developer/backend/Fastapi-Application-Deployement-using-Terraform/Databae_Server/Infrastructure/database.sh"
    destination = "/tmp/database.sh"
  }
  provisioner "file" {
    source      = "/Users/hemantkumar/Developer/backend/Fastapi-Application-Deployement-using-Terraform/Databae_Server/Infrastructure/fast.pem"
    destination = "/tmp/fast.pem"
  }
  connection {
    type        = "ssh"
    user        = var.webuser
    private_key = file("/Users/hemantkumar/Developer/backend/Fastapi-Application-Deployement-using-Terraform/Databae_Server/Infrastructure/fast.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/database.sh",
      "sudo /tmp/database.sh"
    ]
  }
  provisioner "local-exec" {
    command = "echo Database_Private_IP: ${self.private_ip} >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo Database_Public_IP:${self.public_ip} >> ips.txt"
  }
   provisioner "local-exec" {
    command = "echo Database_Public_DNS:${self.public_dns} >> ips.txt"
  }
}
resource "aws_ec2_instance_state" "web_state" {
  count       = length(aws_instance.Fastapi-Dev-Database)
  instance_id = aws_instance.Fastapi-Dev-Database[count.index].id
  state       = "running"
}
output "Fastapi_public_ip" {
  value = aws_instance.Fastapi-Dev-Database.*.public_ip
}
output "fastapi_private_ip" {
  value = aws_instance.Fastapi-Dev-Database.*.private_ip
}
output "fastapi_public_dns" {
  value = aws_instance.Fastapi-Dev-Database.*.public_dns
}

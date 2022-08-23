resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM7g44yNLDwN9NxR7NLUvDA4UG63zDL4LUPGdVWJDqdpVmmbofRLNwX4GPFZNvwcvEyVySTGR0x0GxidIbjxG6hdurynDDOzgBkVtWGSn0dPGYV7iuL6G6vAhnzIW7M+8yf5Qs5G3OOxgBij+Luj9NrhwhZNLTJkbqO0ilqBiPwEIixrOT7jFLyVtgiMehMcPn4BwjpPiCkZwpg0oP+O4ljBeLevFbOaiKxb1SaeLDC4CAdlDEt+Z30OXx215FoMWMaJMEmfLizz8Ws140QviPrHHAz9UHOy+q3EdzwIT9u5NI/6/Og+TMG4wVYp9no3DDoPLZ4WJeFR063gFaX/vvJT0RvUkVpbk2onWWfJMDgPRT6552qGACo/KI6y/4ePP4da2IdMciu8h1NpYbzkwyxmEVqiIvXHuT7WbWmx/JJBckhpPoz+dMPYQonOvEWompemWuHexIUFwkdwvkFwE2V0XRCkBaEWh0k5Rw8/NsWaKQFCbPZkuaid0Z3oQxV/c= ivanovyuriy@demo"
}

resource "aws_instance" "vpn-server" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.vpn_security.id]

  # the public SSH key
  key_name = aws_key_pair.mykey.key_name

  # proviaioning the script

  provisioner "file" {
    source      = "scripts/strongvpn.sh"
    destination = "/tmp/strongvpn.sh"
    connection {
     type     = "ssh"
     user     = "ubuntu"
     private_key = file("/home/ivanovyuriy/vpn-app/mykey.pem")
     host     = aws_instance.vpn-server.public_ip

    }
 
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/strongvpn.sh",
      "sudo /tmp/strongvpn.sh",
    ]
    connection {
     type     = "ssh"
     user     = "ubuntu"
     private_key = file("/home/ivanovyuriy/vpn-app/mykey.pem")
     host     = aws_instance.vpn-server.public_ip

    }
  }
}


output "instances" {
  value       = "aws_instance.vpn-server.public_ip"
  description = "PublicIP address details"
}

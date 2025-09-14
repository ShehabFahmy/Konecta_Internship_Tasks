output "EC2_IP" {
  value = aws_instance.backend-ec2.public_ip
}

resource "local_file" "ansible_inventory_file_creation" {
  content  = <<-EOT
    [all:vars]
    ansible_user = ec2-user

    [servers]
    backend-ec2 ansible_host=${aws_instance.backend-ec2.public_ip}
  EOT
  filename = "${path.module}/../Ansible/inventory.ini"
}

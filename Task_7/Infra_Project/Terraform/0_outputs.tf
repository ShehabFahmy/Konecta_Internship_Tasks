output "vpc-id" {
  value = module.vpc.id
}

output "backend-subnet-id" {
  value = module.pb_subnets[1].id
}

output "key-pair-name" {
  value = module.key-pair.key-name
}

output "jenkins-secgrp-id" {
  value = module.jenkins-secgrp.id
}

output "private-key-path" {
  value = module.key-pair.private-key-path
}

resource "local_file" "ansible_inventory_file_creation" {
  content  = <<-EOT
    [all:vars]
    ansible_user = ubuntu

    [servers]
    jenkins ansible_host=${aws_instance.jenkins-ec2.public_ip}
  EOT
  filename = "${path.module}/../Ansible/inventory.ini"
}

resource "local_file" "ansible_cfg_file_creation" {
  content  = <<-EOT
    [defaults]
    inventory = inventory.ini
    private_key_file = ${path.cwd}/${module.key-pair.key-name}.pem
    host_key_checking = False
  EOT
  filename = "${path.module}/../Ansible/ansible.cfg"
}
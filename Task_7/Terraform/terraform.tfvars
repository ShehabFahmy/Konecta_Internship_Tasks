aws_region = "us-east-1"

backend_secgrp_name = "konecta-task7-backend-secgrp"
backend_instance_tags = {
  "Name"     = "ci-ephemeral"
  "lifespan" = "ephemeral"
  "owner"    = "jenkins"
}
instance_ami  = "ami-00ca32bbc84273381"  # Amazon Linux
instance_type = "t3.micro"
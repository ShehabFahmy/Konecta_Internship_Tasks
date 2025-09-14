data "http" "my-public-ip" {
  url = "http://checkip.amazonaws.com"
}

module "key-pair" {
  source   = "../../Terraform/Modules/key_pair"
  key-name = var.key_pair_name
}

module "jenkins-secgrp" {
  source      = "../../Terraform/Modules/security_group"
  secgrp-name = var.jenkins_secgrp_name
  vpc-id      = module.vpc.id
  # Allow SSH for your local machine's public IP
  ingress-data = [{ from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["${trimspace(data.http.my-public-ip.response_body)}/32"], security_groups = [] },
  { from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }]
  egress-data = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "jenkins_policy" {
  name        = "jenkins-ec2-policy"
  description = "Permissions for Jenkins EC2 to run Terraform with restricted S3 and EC2 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # Full EC2 access but only for resources with Name starting with konecta-task7
      {
        Effect = "Allow"
        Action = "ec2:*"
        Resource = "*"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/Name"     = "konecta-task7*"
          }
          StringEquals = {
            "ec2:ResourceTag/lifespan" = "ephemeral"
            "ec2:ResourceTag/owner"    = "jenkins"
          }
        }
      },

      # Read-only EC2 Describe* for all resources (safe)
      {
        Effect = "Allow"
        Action = "ec2:Describe*"
        Resource = "*"
      },

      # Allow lifecycle actions globally (cannot restrict by tags)
      {
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:RebootInstances",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },

      # S3 restricted to backend bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::konecta-task7-statefiles-bucket/*"
      },
      {
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = "arn:aws:s3:::konecta-task7-statefiles-bucket"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-ec2-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

resource "aws_instance" "jenkins-ec2" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  subnet_id                   = module.pb_subnets[0].id
  security_groups             = [module.jenkins-secgrp.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    "Name" = var.jenkins_instance_name
  }
}
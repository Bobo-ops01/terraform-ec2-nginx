# Terraform EC2 Nginx

A Terraform project that launches a web server on AWS.

## What it builds
- A key pair for SSH access
- A security group: SSH allowed only from my IP, HTTP open to the web
- A t3.micro Amazon Linux 2023 instance that installs Nginx on boot (user_data)
- An output with the server's public IP

## How to run it
```bash
terraform init
terraform plan
terraform apply
terraform destroy   # clean up when done
```

## What I learned
- Lock SSH to your own IP instead of opening it to everyone
- user_data lets a server configure itself on first boot
- Always destroy practice infrastructure to save credits

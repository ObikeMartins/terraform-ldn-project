# Terraform EC2 Deployment with Specific Parameters

This project sets up an EC2 instance in the London region with the following specifications:

- Instance Type: T2.Micro
- Storage: 12GB
- Region: London (eu-west-2)
- Access:
  - SSH and RDP from a single IP
  - HTTPS from anywhere

## Infrastructure

- Cloud: AWS
- Tools: Terraform
- IDE: VS Code.

- Steps

- #1 Create a VPC
- #2 Create IGW
- #3 Create a custom RT
- #4 Create a subnet
- #5 Associate the subnet with the RT
- #6 Create a security group
- #7 Create a network interface with an IP in the subnet that was created in step 4
- #8 Assign an elastic IP to the network interface created in step 7
- #9 Launch an EC2 instance.

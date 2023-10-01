# Terraform Infrastructure

This project demonstrates the setup of infrastructure as code (IAC) using Terraform to create two distinct environments (dev and prod) in AWS. It includes the following components:

- Creation of two workspaces: `dev` and `prod`.
- Definition of environment-specific variables in `.tfvars` files.
- Network resources separated into a reusable module.
- Deployment of resources in `us-east-1` and `eu-central-1` regions.
- Local execution of a provisioner to print the public IP of a Bastion EC2 instance.
- Integration with Jenkins for automated provisioning.
- Integration with AWS Simple Email Service (SES) for email notifications.
- A Lambda function to send email notifications triggered by state file changes.


## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- Terraform
- AWS CLI
- Jenkins (Docker image recommended)
- Python
- Docker

## How To configure AWS credentials after installing the AWS CLI
Open a terminal window.
Run the following command
```
aws configure
```

You will be prompted to enter the following information:

AWS Access Key ID: This is your AWS access key.
AWS Secret Access Key: This is your AWS secret access key.
Default region name: Enter your desired AWS region (e.g., us-east-1, eu-centeral-a).
Default output format: defult json.

How to get AWS Access Key ID & AWS Secret Access Key
You will go to your aws account 
On the top right you will find a drop down menu that has your account name
Hover on it and select "Security Credentials"
Find Access keys 
Select Create Access key
And you will have your AWS Access Key ID & AWS Secret Access Key 
Copy them and paste them in your terminal after runing 'aws configure' from the previous step


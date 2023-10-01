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

### How To configure AWS credentials after installing the AWS CLI
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

### Create Workspaces

By Default you are on the default workspace, you can make sure by running the following command : 
```
terraform workspace list
```
Now you know which workspace you are on.

Now You want to create the  `dev` and `prod` workspaces, and you can do that by executing the following command.
```
terraform workspace new dev # the dev workspace
terraform workspace new prod # the prod workspace
```
Now you have created the desired workspaces
To Switch Between Workspaces
```
terraform workspace select dev # the dev workspace
terraform workspace select prod # the prod workspace
```

We use the ```terraform apply``` command to Apply Configurations for Each Workspace.


### Definition of environment-specific variables in `.tfvars` files.

Creating 2 .tfvar files with the desired variables for each enviroment

when we want to Use the Variable Files with each enviroment, we execute the apply command by specifying the ```var-file``` for the command.
Example:
```
terraform apply -var-file=dev.tfvars #for the "dev" environment
terraform apply -var-file=prod.tfvars #for the "prod" environment
```
[!WARNING]  
You might encounter this problem now and in the future.
[!IMPORTANT]  
When going into diffrent workspaces you might need to import your key in the selected workspace before running in our case here is the command you need to run to import the key
```
terraform import aws_key_pair.tf-key-pairz tf-key-pairz
```

### Network resources separated into a reusable module.

These are the steps if you want to create your own module it is already defined in the provided code

 First we create a directory for the terraform files responsible for network resources example vpcs subnets route tables internet gatewayes
 inside the created directory we need to create 2 files Variables.tf and output.tf
 variables.tf: Define the input variables for your network module.
 outputs.tf: Define any outputs that you want to expose from the network module. For example, you might want to expose the VPC ID or subnet IDs for use in other parts of your configuration.

 then in the parent directory we create network.tf that has the module
 it should look like this
 ```
 module "mynetwork" {
  source               = "./name-of-the-created-dir"
  region               = var.region
  vpc_cidr             = var.vpc_cidr_block 
  availability_zones   = var.availability_zones
  public_subnets_cidr  = var.public_subnets_cidr_blocks
  private_subnets_cidr = var.private_subnets_cidr_blocks
}
 ```
the variables should be the same name as the variables in the ```outputs.tf```
then we use the variables from the ```mynetwork``` module example
```
 subnet_id = module.mynetwork.public_subnets[count.index].id
```
Then apply the configuration For each enviroment
```
terraform apply -var-file=dev.tfvars #for the "dev" environment
terraform apply -var-file=prod.tfvars #for the "prod" environment
```

### Deployment of resources in `us-east-1` and `eu-central-1` regions.

in the .tfvar file specify the region and run with the ```var-file``` option 
Example:
dev.tfvars:
```
region                      = "us-east-1"
vpc_cidr_block              = "10.1.0.0/16"
public_subnets_cidr_blocks  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets_cidr_blocks = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones          = ["us-east-1a", "us-east-1b"]
bastion_ami_id              = "ami-03a6eaae9938c858c"
application_ami_id          = "ami-03a6eaae9938c858c"
```
prod.tfvars
```
region                      = "eu-central-1"
vpc_cidr_block              = "10.1.0.0/16"
public_subnets_cidr_blocks  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets_cidr_blocks = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones          = ["eu-central-1a", "eu-central-1b"]
bastion_ami_id              = "ami-01342111f883d5e4e"
application_ami_id          = "ami-01342111f883d5e4e"
```
Then apply the configuration For each enviroment
```
terraform apply -var-file=dev.tfvars #for the "dev" environment
terraform apply -var-file=prod.tfvars #for the "prod" environment
```
 [!NOTE]  
 the ami_id you can find it by going to aws ec2 go to launch instance you will find on the right info about the machine and the ami id starting by ```ami-``` followed by unique id copy it and add it as your ami_id no need to create the instance
  [!NOTE]  
  you can find that the ami is diffrent for both region that is because you need to specify the region first and then get the ami-id for the selected region.

### Local execution of a provisioner to print the public IP of a Bastion EC2 instance.

you will need to add a provisioner in the terraform file for creating the Bastion EC2 instance Example
```
 provisioner "local-exec" {
    command = "echo 'Bastion Public IP: ${self.public_ip}' > inventory.txt"
  }
```
[!NOTE]  
Make Sure to apply the configuration in the default workspace to get the inventory.txt file & also make sure that the generated ip is the same as the public ip in the Bastion EC2 instance on the AWS console.


### Integration with Jenkins for automated provisioning.

 First We Created a dir called jenkins-terraform and created a Dockerfile inside it
 This Dockerfile uses the official Jenkins base image, installs the necessary packages (curl and unzip), and then installs Terraform.
 Build the Docker Image
 ```
  docker build -t jenkins-terraform:latest .
 ```
 Run the Jenkins Container
 ```
  docker run -d -p 8080:8080 -p 50000:50000 --name my-jenkins jenkins-terraform:latest
 ```
 Access the Container's Shell
  ```
  docker exec -it my-jenkins /bin/bash
  ```
 Access Jenkins Homepage [Jenkins](https://localhost:8080).

 Retrieve the Jenkins Admin Password:
 ```
  cat /var/jenkins_home/secrets/initialAdminPassword
 ```
  Enter the generated text from your terminal into your initial password on jenkins and then press install suggested plugins and create the admin user Now you have configured Jenkins.
  
  Exit the Container : ```exit```

  inisde jenkins the first thing you need to do is to Configure AWS Credentials
  Go to manage jenkins
  Select Credentials
  Press the global Hyperlink
  Choose "Add Credentials"
  Choose "Secret text" as the kind
  in the first field enter your AWS Access Key ID and then name it
  then create onther credential and repeat the same steps for the AWS Secret Access Key
  
  [!NOTE] 
   you can get your keys by finding the credentials file
   ```
   ~/.aws/credentials on Linux or macOS
   C:\Users\ USERNAME \.aws\credentials on Windows.
   ```
  
  Then Create a New Jenkins Pipeline Job:  
  Go to your Dashboard.
  Click on "New Item" to create a new Jenkins job.
  Enter a name for your job (e.g., "TerraformPipeline").
  Choose "Pipeline" as the job type and click "OK." 
  
  Configure the Pipeline:
  In the job configuration page:
  Scroll down to the "Pipeline" section and choose the "Pipeline script" option.
  Then Add the code in the ```pipeline.groovy``` file.
  Then save the job.
  chooe build with paramaters
  choose the desired enviroment and then build
  Check you AWS account and you will find that all the instances have been created successfully

  ### Integration with AWS Simple Email Service (SES) for email notifications

  Sign in to AWS Console:
  Log in to the AWS Management Console using your AWS account credentials.
  Navigate to SES:
  Go to the Amazon SES console.
  Verify a New Email Address:
  In the SES console, navigate to the "Email Addresses" section, and click the "Verify a New Email Address" button.
  Enter the Email Address:
  Enter the email address that you want to verify and click the "Verify This Email Address" button.
  Check Your Email:
  Amazon SES will send a verification email to the address you specified. Open your email client and look for the verification message.
  Click the Verification Link:
  Open the email and click on the verification link provided in the message. This action confirms the email address.
  Confirmation in SES:
  After clicking the link, return to the SES console. You should see a message indicating that the email address has been successfully verified

  ###  A Lambda function to send email notifications triggered by state file changes.
  Sign in to AWS Console:
  Log in to the AWS Management Console using your AWS account credentials.
  Navigate to IAM:
  Create A new role
  Add Policy:
  Add AmazonS3FullAccess & AmazonSESFullAccess permission policies
  Navigate to S3:
  Create a bucket with default configurations.
  Navigate to Lambda:
  Create function
  Choose "Author from scratch
  Choose Python 3.10 or higher is recommended (I chose 3.10)
  Press the "Change default execution role" Dropdown
  Choose an existing role and choose the name of the created role from the previous steps
  Then press Create Function button
  next you will need to add trigger
  Choose S3
  and then choose the created S3 bucket From the Bucket DropDown menu
  then press "Add" button.
  put the code from the ```mail_script.py``` then press Deploy
  then Press test in the Execution result if you get response "Email Sent Successfuly" go check for the mail
  [!NOTE] 
  You need to change the recipient mail and the sender mail in the ```mail_script.py```, The mail will only be sent from or to an email that has been verified in the SES step.

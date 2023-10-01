# Terraform Infrastructure

This project showcases the power of Infrastructure as Code (IAC) through Terraform, enabling the creation of two distinct AWS environments: development (dev) and production (prod).

It orchestrates the deployment of a Virtual Private Cloud (VPC) with two public and two private subnets, setting up internet gateways, and configuring public and private route tables.

The project encompasses the following components:

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

1. Open a terminal window.
2. Run the following command:
```
aws configure
```

3. You will be prompted to enter the following information:

- AWS Access Key ID: This is your AWS access key.
- AWS Secret Access Key: This is your AWS secret access key.
- Default region name: Enter your desired AWS region (e.g., us-east-1, eu-central-1).
- Default output format: Default JSON.

#### How to Get AWS Access Key ID & AWS Secret Access Key

- Log in to your AWS account.
- Click on your account name in the top right corner.
- Hover over "Security Credentials."
- Find "Access keys" and click "Create Access key."
- Copy and paste the AWS Access Key ID & AWS Secret Access Key into the terminal after running 'aws configure'.

### Create Workspaces

1. By default, you are on the default workspace. Verify your current workspace by running:

```
terraform workspace list
```
Now you know which workspace you are on.

1. Now You want to create the  `dev` and `prod` workspaces, and you can do that by executing the following command.
```
terraform workspace new dev # the dev workspace
terraform workspace new prod # the prod workspace
```
Now you have created the desired workspaces

3. To switch between workspaces:

```
terraform workspace select dev # the dev workspace
terraform workspace select prod # the prod workspace
```


4. Use the `terraform apply` command to apply configurations for each workspace.

### Definition of environment-specific variables in `.tfvars` files

1. Create two `.tfvars` files with the desired variables for each environment (e.g., `dev.tfvars` and `prod.tfvars`).

2. Use the Variable Files with each enviroment, we execute the apply command by specifying the ```var-file``` for the command:

Example:
```
terraform apply -var-file=dev.tfvars #for the "dev" environment
terraform apply -var-file=prod.tfvars #for the "prod" environment
```
> [!WARNING]
>  You might encounter this problem now and in the future.

> [!WARNING]
>  If you encounter issues switching between workspaces, import your key in the selected workspace:
> ```
> terraform import aws_key_pair.tf-key-pairz tf-key-pairz
> ```

### Network resources separated into a reusable module

1. Create a directory for the Terraform files responsible for network resources, such as VPCs, subnets, route tables, and internet gateways.

2. Inside the created directory, create two files: `variables.tf` and `outputs.tf`.

- `variables.tf`: Define the input variables for your network module.
- `outputs.tf`: Define any outputs you want to expose from the network module.

3. In the parent directory, create a `network.tf` file that references the module:
 
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
1. Use the variables from the mynetwork module in your configuration:
- the variables should be the same name as the variables in the ```outputs.tf```
- then we use the variables from the ```mynetwork``` module example
```
 subnet_id = module.mynetwork.public_subnets[count.index].id
```
2. Then apply the configuration For each enviroment
```
terraform apply -var-file=dev.tfvars #for the "dev" environment
terraform apply -var-file=prod.tfvars #for the "prod" environment
```

### Deployment of resources in `us-east-1` and `eu-central-1` regions.

1. Specify the region in the .tfvars file and run with the -var-file option.

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
 > [!NOTE]
>   the ami_id you can find it by going to aws ec2 go to launch instance you will find on the right info about the machine and the ami id starting by ```ami-``` followed by unique id
>   copy it and add it as your ami_id no need to create the instance
>   you can find that the ami is diffrent for both region that is because you need to specify the region first and then get the ami-id for the selected region.

### Local execution of a provisioner to print the public IP of a Bastion EC2 instance.

- you will need to add a provisioner in the terraform file for creating the Bastion EC2 instance Example
```
 provisioner "local-exec" {
    command = "echo 'Bastion Public IP: ${self.public_ip}' > inventory.txt"
  }
```
> [!NOTE]
> Make Sure to apply the configuration in the default workspace to get the inventory.txt file & also make sure that the generated ip is the same as the public ip in the Bastion EC2 instance on the AWS console.


### Integration with Jenkins for automated provisioning.
1. Create a directory called jenkins-terraform and place a Dockerfile inside it.
2. This Dockerfile uses the official Jenkins base image, installs the necessary packages (curl and unzip), and then installs Terraform.
3. Build the Docker Image
 ```
  docker build -t jenkins-terraform:latest .
 ```
4. Run the Jenkins Container
 ```
  docker run -d -p 8080:8080 -p 50000:50000 --name my-jenkins jenkins-terraform:latest
 ```
5. Access the Container's Shell
  ```
  docker exec -it my-jenkins /bin/bash
  ```
6. Access Jenkins Homepage [Jenkins](https://localhost:8080).

7. Retrieve the Jenkins Admin Password:
 ```
  cat /var/jenkins_home/secrets/initialAdminPassword
 ```
 8. Enter the generated password from your terminal into your initial password on Jenkins and press "Install Suggested Plugins" and create the admin user.
  
 9. Exit the Container : ```exit```

 10. inisde jenkins the first thing you need to do is to Configure AWS Credentials
     - Go to manage jenkins
     - Select Credentials
     - Press the global Hyperlink
     - Choose "Add Credentials"
     - Choose "Secret text" as the kind
     - in the first field enter your AWS Access Key ID and then name it
     - then create onther credential and repeat the same steps for the AWS Secret Access Key
  
> [!NOTE]
> you can get your keys by finding the credentials file
>    ```
>     ~/.aws/credentials on Linux or macOS
>    C:\Users\ USERNAME \.aws\credentials on Windows
>    ```
  
  11. Then Create a New Jenkins Pipeline Job:  
      - Go to your Dashboard.
      - Click on "New Item" to create a new Jenkins job.
      - Enter a name for your job (e.g., "TerraformPipeline").
      - Choose "Pipeline" as the job type and click "OK." 
  
  12. Configure the Pipeline:
      - In the job configuration page:
      - Scroll down to the "Pipeline" section and choose the "Pipeline script" option.
      - Then Add the code in the ```pipeline.groovy``` file.
      - Then save the job.
      - Chooe build with paramaters
      - Choose the desired enviroment and then build
      - Check your AWS account to ensure all instances have been created successfully.


  ### Integration with AWS Simple Email Service (SES) for email notifications

  1. Sign in to the AWS Management Console using your AWS account credentials.
  2. Go to the Amazon SES console.
  3. Verify a new email address:
     - In the SES console, navigate to the "Email Addresses" section.
     - Click the "Verify a New Email Address" button.
     - Enter the email address you want to verify and click "Verify This Email Address."
  4. Check your email for a verification message sent by Amazon SES.
  5. Click the verification link provided in the message to confirm the email address.
  6. Return to the SES console, where you should see a message indicating that the email address has been successfully verified.
  
  ###  A Lambda function to send email notifications triggered by state file changes.
  1. Sign in to the AWS Management Console using your AWS account credentials.
  2. Navigate to IAM and create a new role.
  3. Add the AmazonS3FullAccess and AmazonSESFullAccess permission policies to the role.
  4. Navigate to S3 and create a bucket with default configurations.
  5. Navigate to Lambda and create a new function:
   - Choose "Author from scratch."
   - Select Python 3.10 or higher.
   - Choose an existing role and select the name of the created role.
   - Press the "Create Function" button.
  6. Add a trigger for S3 and choose the created S3 bucket from the Bucket dropdown menu.
  7. Add the code from the ```mail_script.py``` and deploy the Lambda function.
  8. Test the function by pressing "Test" in the execution result. If you receive the response "Email Sent Successfully," check your email
  >[!NOTE]
  >You need to change the recipient mail and the sender mail in the ```mail_script.py```, The mail will only be sent from or to an email that has been verified in the SES step.


## Questions or Need Help?

If you have any questions, suggestions, or need assistance, please don't hesitate to Contact Me [Seif Hendawy](mailto:seifhendawy1@gmail.com).

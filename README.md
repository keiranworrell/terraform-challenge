To create this solution I have moved the provided network.tf file to create a module which can be reused, allowing various applications and services to create their own VPC. 

### Assumptions

SSH access control for connecting to EC2 instances is already established, and a new key doesn't need to be provisioned. This existing key can be set under ssh_key_name in the environments/<dev/prod>/terraform.tfvars file.

I have also assumed that SSH access for prod environments is not required for security purposes, and so ssh_key_name is set to null for that environment.

In data.tf we get the latest version of the AL2023 AMI for use in the EC2 instances. I have left this at the root of the repository so that the ec2-asg module can be reused with different AMIs, but for this application I assume both dev and prod environments will use the same AMI. If dev and prod environments need to use different AMIs, this data.tf could be parameterised and the relevant variables passed in via the terraform.tfvars for each env.

Minimal environment setup is done through the user_data script. I've left this user_data variable empty by default in the ec2-asg module, for maximum flexibility. I've then defined a simple variable ec2_user_data in the root variables.tf which does a yum update and sets up an environment variable for database access via the RDS endpoint. If further set up is required before installing a product, this variable could be replaced with a larger script rather than writing the user_data inline in the root variables.tf file.

I have assumed that a terraform-states S3 bucket exists to store the state file for each environment. I've also put each environment into the eu-west-1 region for simplicity, but this could be parameterised.

I've also assumed minimal difference in environment config for dev and prod, so their terraform.tfvars files are relatively small. If further differences in configuration are needed, such as different vpc_cidr block, then the default in the root variables.tf could be removed and the variable set in each terraform.tfvars file.


### Additions

I've created reusable modules for each resource being created. These modules are fully parameterised, so they can be configured for each application that consumes them. For simplicity I've kept these modules in this repo, but they could be moved to a separate repo for a better separation of application and module code.

I've also created a module for a security group which can be reused. I've used this multiple times for this application, creating a security group for each of the ALB, EC2s, and RDS. This ensures that the ALB can recieve any incoming traffic, the EC2s can only be contacted via the ALB, and the RDS can only be reached from these EC2s.

locals.tf contains a tag definition that is passed into each module, so other applications that use the modules can follow their own tagging structure. By keeping the tags defined in locals.tf it will be easy to add new tags to this environment, such as details on infrastructure ownership and cost tracking. 

This application can be deployed using the root main.tf file, but I have set up the environments directory to define different backends and variables for a dev and prod environment. To deploy this application you could run the following commands from the root directory:

```
terraform init -backend-config=./environments/dev/backend.tf
terraform apply -var-file="./environments/dev/terraform.tfvars" -var "db_password=${DB_PASSWORD}"-var "db_username=${DB_USERNAME}"
```

This command also sets the database username and password variables. I haven't included these credentials in any file, and enforced that they must be supplied in the terraform apply command, to ensure that they are sourced correctly from a secret manager upon runtime. 


### Further Use

For other applications to make use of the deployed service, they should just need the ALB DNS name. I have exposed the ALB DNS name in the outputs.tf file, so if another application is being deployed it should be able to retrieve the state file from the terraform-states S3 bucket and run the command `terraform output -raw alb_dns_name` to get this value.

Another approach would be to set up the AWS Parameter Store, and have the ALB module create a parameter entry with the following code block:

```
resource "aws_ssm_parameter" "alb_dns" {
  name  = "/${var.name}/alb_dns"
  type  = "String"
  value = aws_lb.alb.dns_name
}

```

This would mean that later applications could retrieve the DNS name with the command: `aws ssm get-parameter --name "/app/dev/alb_dns" --query Parameter.Value --output text`


### CD Integration

To integrate continuous deployment of this application, GitHub actions could be set up to execute a Terraform Plan on PR creation. The output of this plan could then be added to the PR as a comment for review. Once this PR has been approved and merged, further automation could be set up to execute the Terraform apply command for the dev environment.

With this system, sensitive variables such as db_username and db_password could be injected into the apply command from Github secrets manager. 

A separate pipeline could then be set up to execute the same Terraform plan and apply for the prod environment, ensuring that any changes are rolled out and tested in dev before promotion to prod.

Another consideration to take is to limit the IAM role used for this automation to ensure that this CD process only has permissions to interact with these resources, aligned with least-privilege principles.


An additional pipeline could be set up to run the command:

```
terraform plan -detailed-exitcode
```

Which would check for any drift between the Infrastructure as Code definition and the actual environment in AWS. This could be configured to run as a daily sanity check.

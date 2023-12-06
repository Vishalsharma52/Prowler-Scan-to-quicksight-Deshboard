# Prowler-Scan-to-quicksight-Deshboard
This is Iac where we are creating a beautiful dashboard with the help of quicksight to show the AWS Infra vulnerability. 

Just update the terraform.tfvars with the mandatory variables and apply the terraform using cmd.


                             # terraform apply --auto-approve

Install the awscli tool and configure it through

                             # aws configure
                             
Install the prowler in any on the same system and scan with the "-S" flag to send the scan vulnerability to the security Hub and -f for the specific region.

                             # prolwer -S -f "AWS region where all the above terraform applied"

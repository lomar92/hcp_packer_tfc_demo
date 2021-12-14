<<<<<<< HEAD
# HCP Packer & Terraform Cloud Integration

This is demo is showing how to integrate HCP Packer with Terraform Cloud and how Packer & HCP Packer can fit in your CI Golden Image Pipeline using Github Actions.

HCP Packer is currently a free beta offering, you can access it on HCP Cloud Platform.
HCP Packer require packer 1.7.7 or above, please download it from our [releases](https://releases.hashicorp.com/packer/).
For further details consult our [Learning Guide](https://learn.hashicorp.com/tutorials/packer/hcp-push-image-metadata?in=packer/hcp-get-started).

# What is HCP Packer?
Check here: [Announcing HCP Packer](https://www.hashicorp.com/blog/announcing-hcp-packer)
Read carefully!

## Installing / Getting started

This Repository is separated in two workflows. First we are creating a Golden Image with Packer and GitHub Actions. After Image is created, we are fetching the Meta Data of our newly created AMI in AWS and store it in our Repository. You can find your Repository in HCP Packer. 

Second part is we are using our newly created image and deploy our infrastructure with the help of Terraform Cloud(TFC). You can use Terraform CLI as well, but for security manners it is better to use TFC for storing your statefile and you can connect it with your favorite Version Control System e.g. GitHub and there some more Enterprise Features as well you can test it.

### Initial Configuration
1. Install Packer [releases](https://releases.hashicorp.com/packer/)

2. Download Terraform if you want to use CLI [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

3. [Create an Account on HashiCorp Cloud Platform](https://portal.cloud.hashicorp.com/sign-in) - you will get 50$ for free testing. You will not need it for our Purpose.

4. Create Service Principals under your IAM Seetings. Assign a Role and generate new secrets. Set your ENV Var under Secrets in your GitHub Repo Settings. You will need AWS credentials as well to trigger GitHub Actions for Packer. 

- HCP_CLIENT_ID: `your CLIENT_ID` 
- HCP_CLIENT_SECRET: `your CLIENT SECRET` 
- AWS_SECRET_KEY: `your AWS SECRET KEY`
- AWS_SECRET_ACCESS_KEY; `your AWS SECRET KEY`

4. [Create Terraform Cloud Account](https://app.terraform.io/session)

5. [Connect your VCS with TFC](https://www.terraform.io/docs/cloud/vcs/index.html) 

6. Fork or clone this Repository! 

Some projects require initial configuration (e.g. access tokens or keys, `npm i`).
This is the section where you would document those requirements.

## Download Repo

```shell
git clone https://github.com/lomar92/hcp_packer_tfc_demo
cd hcp_packer_tfc_demo
```

### Building your image

You can build, make changes to this image on Visual Studio Code or in your preffered CLI:

```shell
cd hcp_packer_tfc_demo/images
nano aws-ubuntu-apache.pkr.hcl
```
In aws-ubuntu-apache.pkr.hcl you will see a building block hcp_registry. This source in your building block will create a bucket with an iteration. Following additional creations, new images will be created under a new version of it and it will be listed in your respository.

  hcp_packer_registry {
    bucket_name = "hashitalk"
    description = <<EOT
    This image is a Apache Web Service running on ubuntu
        EOT
    labels = {
      "target-use" = "Website",
      "service"    = "apache_server",
      "os"         = "ubuntu_latest_version",
    }
  }

Check HCP Packer Docs for more Information. 

Now you can change pkr.hcl code for example replaced it with another ubuntu version or leave it like this. Start packer build or commit your changes to your repository. If you push your code, GitHub Actions will trigger your CI Pipeline. Packer allows you to intergrate external [provisioner](https://www.packer.io/docs/provisioners) to bootstrap your VM's/Images for e.g. Chef, Ansible, Puppet etc. I recommend to do so, if configuration becomes more complex. 

### Push your pkr.config.

```shell
git add . 
git commit -m "ubuntu"
git push
```

Build Process will take some time. Aproximately 4-5min. You can check your building process in HCP Packer under your bucket. When build process is done you can then assign your newly created image to a channel. You will need this, so that Terraform can pull the latest image. 

## Integration HCP Packer and Terraform

```shell
cd terraform 
nano terraform ec2test.tf
nano variables
```

#### Specify HCP Provider in your Terraform Config
Specify HCP Provider and HCP Packer Iteration so you can use the API of HCP Packer
  provider "hcp" {
  }

This is already done, just in case if you want to integrate HCP packer in other terraform configs.

#### HCP Data Block 
data "hcp_packer_iteration" "hashitalk" {
  bucket_name = var.bucket
  channel     = var.channel
}

data "hcp_packer_image" "hashitalk-image" {
  bucket_name    = var.bucket
  iteration_id   = data.hcp_packer_iteration.hashitalk.ulid
  cloud_provider = "aws"
  region         = var.region
}

resource "aws_instance" "hashitalk" {
  ami                         = data.hcp_packer_image.hashitalk-image.cloud_image_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.hashitalk.id
  vpc_security_group_ids      = [aws_security_group.hashitalk.id]

Normally you would copy and paste your newly created AMI in your ressource block for creating an ec2 instance. You don't have to do it anymore, as terraform understands to pull the newly created AMI from a specific channel where you assigend your interation earlier.


## Links

Usefull links for your own Golden Image CI Pipeline.

- GitHub Action Templates: [Packer Action Template](https://github.com/lomar92/github-actions-packer)
- Blog:[How to securely build and deploy with Vault and dynamic credentials](https://medium.com/hashicorp-engineering/a-moving-window-of-trust-dfcda514af58)
- [Learn Packer](https://learn.hashicorp.com/collections/packer/hcp-get-started)
- [Vault OIDC Integration:](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault)
- [HCP Packer Golden Image in Production](https://learn.hashicorp.com/tutorials/packer/golden-image-with-hcp-packer?in=packer/cloud-production)
=======

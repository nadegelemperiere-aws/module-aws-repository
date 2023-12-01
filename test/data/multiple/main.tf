# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Simple deployment for testing
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# -------------------------------------------------------


# -------------------------------------------------------
# Local test variables
# -------------------------------------------------------
resource "aws_iam_user" "test" {
  	name = "test"
  	path = "/"
}
locals {
	test_repositories = [
		{ 	name = "test-1", expiration=30},
		{ 	name = "test-2", expiration=60},
		{ 	name = "test-3", rights = [
				{ description = "AllowUserAccess", actions = ["ecr:PutImage"], principal = { aws = [aws_iam_user.test.arn]} }
			]
		},
	]
}

# -------------------------------------------------------
# Create repositories using the current module
# -------------------------------------------------------
module "repositories" {

	count 				= length(local.test_repositories)

	source 				= "../../../"
	email 				= "moi.moi@moi.fr"
	project 			= "test"
	module 				= "test"
	git_version 		= "test"
	environment			= "test"
	region 				= var.region
	rights 				= lookup(local.test_repositories[count.index], "rights", null)
	name 				= local.test_repositories[count.index].name
	expiration          = lookup(local.test_repositories[count.index], "expiration", null)
	account 			= var.account
	service_principal	= var.service_principal

}

# -------------------------------------------------------
# Terraform configuration
# -------------------------------------------------------
provider "aws" {
	region		= var.region
	access_key 	= var.access_key
	secret_key	= var.secret_key
}

terraform {
	required_version = ">=1.6.4"
	backend "local"	{
		path="terraform.tfstate"
	}
}

# -------------------------------------------------------
# Region for this deployment
# -------------------------------------------------------
variable "region" {
	type    = string
}

# -------------------------------------------------------
# AWS credentials
# -------------------------------------------------------
variable "access_key" {
	type    	= string
	sensitive 	= true
}
variable "secret_key" {
	type    	= string
	sensitive 	= true
}
variable "service_principal" {
	type = string
	nullable = false
}
variable "account" {
	type = string
	nullable = false
}

# -------------------------------------------------------
# Test outputs
# -------------------------------------------------------
output "repository" {
	value = {
		registries	= module.repositories[*].registry
		arns		= module.repositories[*].arn
		urls		= module.repositories[*].url
		keys 		= module.repositories[*].key
	}
}

output "user" {
	value = aws_iam_user.test.arn
}

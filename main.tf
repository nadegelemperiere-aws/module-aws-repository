# -------------------------------------------------------
# Copyright (c) [2023] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws ecr repository with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# -------------------------------------------------------

# -------------------------------------------------------
# Create the ecr repository
# -------------------------------------------------------
resource "aws_ecr_repository" "repository" {

	name                 = "${var.project}-${var.environment}-${var.region}-${var.name}"
  	image_tag_mutability = "IMMUTABLE"

  	image_scanning_configuration {
    	scan_on_push = true
  	}

	encryption_configuration {
		encryption_type = "KMS"
		kms_key         = aws_kms_key.repository.arn
	}

  	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.${var.region}.${var.name}.repository"
		Owner   		= var.email
		Environment		= var.environment
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}

}

# -------------------------------------------------------
# Create the ecr repository policy
# -------------------------------------------------------
locals {
	repository_statements = concat([
		for i,right in ((var.rights != null) ? var.rights : []) :
		{
			Sid 		= right.description
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ((right.principal.aws != null) ? right.principal.aws : [])
				"Service" 	: ((right.principal.services != null) ? right.principal.services : [])
			}
			Action 		= right.actions
		}
	],
	[
		{
			Sid 		= "AllowRootAndServicePrincipal"
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:user/${var.service_principal}"]
			}
			Action 		= "ecr:*"
		}
	])
}
resource "aws_ecr_repository_policy" "repository" {

	repository = aws_ecr_repository.repository.name
  	policy = jsonencode({
    	Version = "2012-10-17"
		Statement = local.repository_statements
	})

}

# -------------------------------------------------------
# Create the ecr repository life cycle
# -------------------------------------------------------
resource "aws_ecr_lifecycle_policy" "policy" {

	repository = aws_ecr_repository.repository.name

  	policy = jsonencode({
  		rules = [
			{
            	"rulePriority": 1,
            	"description": "Expire old images",
            	"selection": {
                	"tagStatus": "untagged",
                	"countType": "sinceImagePushed",
                	"countUnit": "days",
                	"countNumber": var.expiration
            	},
            	"action": {
               		"type": "expire"
            	}
        	}
		]
	})
}


# -------------------------------------------------------
# Repository encryption key
# -------------------------------------------------------
locals {
	kms_statements = concat([
		for i,right in ((var.rights != null) ? var.rights : []) :
		{
			Sid 		= right.description
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ((right.principal.aws != null) ? right.principal.aws : [])
				"Service" 	: ((right.principal.services != null) ? right.principal.services : [])
			}
			Action 		= ["kms:Decrypt","kms:GenerateDataKey"],
			Resource	= ["*"]
		}
	],
	[
		{
			Sid 		= "AllowRootAndServicePrincipal"
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:user/${var.service_principal}"]
			}
			Action 		= "kms:*",
			Resource	= ["*"]
		}
	])
}
resource "aws_kms_key" "repository" {

	description             	= "Bucket ${var.name} encryption key"
	key_usage					= "ENCRYPT_DECRYPT"
	customer_master_key_spec	= "SYMMETRIC_DEFAULT"
	deletion_window_in_days		= 7
	enable_key_rotation			= true
  	policy						= jsonencode({
  		Version = "2012-10-17",
  		Statement = local.kms_statements
	})

	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.${var.region}.${var.name}.repository.key"
		Owner   		= var.email
		Environment		= var.environment
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}

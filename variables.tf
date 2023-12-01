# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws s3 bucket with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# -------------------------------------------------------

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type     = string
	nullable = false
}
variable "module" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	= string
	nullable = false
}
variable "region" {
	type 	= string
	nullable = false
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type     = string
	default  = "unmanaged"
	nullable = false
}

# -------------------------------------------------------
# Repository parameters
# -------------------------------------------------------
variable "name" {
	type     = string
	nullable = false
}
variable "expiration" {
	type 	 = number
	default  = 14
	nullable = false
}


# --------------------------------------------------------
# Repository bucket access rights + Service principal and account
# to ensure root and service principal can access
# --------------------------------------------------------
variable "rights" {
	type = list(object({
		description = string,
		principal 	= object({
			aws 		= optional(list(string))
			services 	= optional(list(string))
		}),
		actions 	= list(string)
	}))
	default = null
}
variable "service_principal" {
	type = string
	nullable = false
}
variable "account" {
	type = string
	nullable = false
}
# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check multiple subnets creation using module
Library         aws_iac_keywords.terraform
Library         aws_iac_keywords.ecr
Library         aws_iac_keywords.kms
Library         aws_iac_keywords.keepass
Library         ../keywords/data.py
Library         OperatingSystem

*** Variables ***
${KEEPASS_DATABASE}                 ${vault_database}
${KEEPASS_KEY_ENV}                  ${vault_key_env}
${KEEPASS_PRINCIPAL_KEY_ENTRY}      /aws/aws-principal-access-key
${KEEPASS_ACCOUNT_ENTRY}            /aws/aws-account
${KEEPASS_PRINCIPAL_USERNAME}       /aws/aws-principal-credentials
${REGION}                           eu-west-1

*** Test Cases ***
Prepare environment
    [Documentation]         Retrieve god credential from database and initialize python tests keywords
    ${vault_key}            Get Environment Variable    ${KEEPASS_KEY_ENV}
    ${principal_access}     Load Keepass Database Secret      ${KEEPASS_DATABASE}    ${vault_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}   username
    ${principal_secret}     Load Keepass Database Secret      ${KEEPASS_DATABASE}    ${vault_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}   password
    ${principal_name}       Load Keepass Database Secret      ${KEEPASS_DATABASE}    ${vault_key}  ${KEEPASS_PRINCIPAL_USERNAME}    username
    ${ACCOUNT}              Load Keepass Database Secret      ${KEEPASS_DATABASE}    ${vault_key}  ${KEEPASS_ACCOUNT_ENTRY}         password
    Initialize Terraform    ${REGION}   ${principal_access}   ${principal_secret}
    Initialize ECR          None        ${principal_access}   ${principal_secret}    ${REGION}
    Initialize KMS          None        ${principal_access}   ${principal_secret}    ${REGION}
    ${TF_PARAMETERS}=       Create Dictionary   account=${ACCOUNT}    service_principal=${principal_name}
    Set Global Variable     ${TF_PARAMETERS}
    Set Global Variable     ${ACCOUNT}

Create Multiple Repositories
    [Documentation]         Create Repositories And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/multiple    ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/multiple
    ${specs}    Load Multiple Test Data         ${states['test']['outputs']['repository']['value']}    ${REGION}    ${ACCOUNT}    ${states['test']['outputs']['user']['value']}
    Repository Shall Exist And Match            ${specs['repositories']}
    Key Shall Exist And Match                   ${specs['keys']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/multiple    ${TF_PARAMETERS}

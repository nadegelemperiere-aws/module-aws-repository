# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws repository with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# ------------------------------------------------------


output "arn" {
    value = aws_ecr_repository.repository.arn
}

output "registry" {
    value = aws_ecr_repository.repository.registry_id
}

output "url" {
    value = aws_ecr_repository.repository.repository_url
}

output "key" {
    value = aws_kms_key.repository.arn
}

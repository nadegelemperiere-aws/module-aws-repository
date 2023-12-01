# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Keywords to create data for module test
# -------------------------------------------------------
# Nadège LEMPERIERE, @30 november 2023
# Latest revision: 30 november 2023
# -------------------------------------------------------

# System includes
from json import load, dumps

# Robotframework includes
from robot.libraries.BuiltIn import BuiltIn, _Misc
from robot.api import logger as logger
from robot.api.deco import keyword
ROBOT = False

# ip address manipulation
from ipaddress import IPv4Network

@keyword('Load Multiple Test Data')
def load_multiple_test_data(repositories, region, account, user) :

    result = {}
    result['repositories'] = []
    result['keys'] = []

    if len(repositories['arns']) != 3 : raise Exception(str(len(repositories['arns'])) + ' buckets created instead of 3')

    for i in range(1,4) :
        repository = {}

        repository['repositoryArn'] = repositories['arns'][i - 1]
        repository['repositoryName'] = 'test-test-' + region + '-test-' + str(i)
        repository['repositoryUri'] = account + '.dkr.ecr.'+ region + '.amazonaws.com/test-test-' + region + '-test-' + str(i)
        repository['imageTagMutability'] = 'IMMUTABLE'
        repository['imageScanningConfiguration'] = {"scanOnPush": True}
        repository['encryptionConfiguration'] = {"encryptionType": "KMS", "kmsKey": repositories['keys'][i - 1]}

        repository['Policy'] = {"Version": "2012-10-17", "Statement": [{"Sid": "AllowRootAndServicePrincipal", "Effect": "Allow", "Principal": {"AWS": ["arn:aws:iam::833168553325:user/principal", "arn:aws:iam::833168553325:root"]}, "Action": "ecr:*"}]}
        if i == 3 : repository['Policy'] = {"Version": "2012-10-17", "Statement": [{"Sid": "AllowRootAndServicePrincipal", "Effect": "Allow", "Principal": {"AWS": ["arn:aws:iam::833168553325:user/principal", "arn:aws:iam::833168553325:root"]}, "Action": "ecr:*"},{ "Sid": "AllowUserAccess", "Action" : "ecr:PutImage", "Principal" : { "AWS" : user} }]}

        repository['Lifecycle'] = {"rules": [{"rulePriority": 1, "description": "Expire old images", "selection": {"tagStatus": "untagged", "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 30}, "action": {"type": "expire"}}]}
        if i == 2 :  repository['Lifecycle'] = {"rules": [{"rulePriority": 1, "description": "Expire old images", "selection": {"tagStatus": "untagged", "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 60}, "action": {"type": "expire"}}]}
        if i == 3 :  repository['Lifecycle'] = {"rules": [{"rulePriority": 1, "description": "Expire old images", "selection": {"tagStatus": "untagged", "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 14}, "action": {"type": "expire"}}]}

        repository['Tags'] = []
        repository['Tags'].append({'Key'        : 'Version'             , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Project'             , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Environment'         , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Module'              , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Owner'               , 'Value' : 'moi.moi@moi.fr'})
        repository['Tags'].append({'Key'        : 'Name'                , 'Value' : 'test.test.test.' + region + '.test-' + str(i) + '.repository'})


        result['repositories'].append({'name' : 'test-' + str(i), 'data' : repository})

        key = {}
        key['KeyId']                   = repositories['keys'][i - 1].split('/')[1]
        key['Arn']                     = repositories['keys'][i - 1]
        key['Enabled']                 = True
        key['KeyUsage']                = 'ENCRYPT_DECRYPT'
        key['KeyState']                = 'Enabled'
        key['Origin']                  = 'AWS_KMS'
        key['CustomerMasterKeySpec']   = 'SYMMETRIC_DEFAULT'
        key['AWSAccountId']            = account
        key['Policy']                  = {"Version": "2012-10-17", "Statement": [{"Sid": "AllowRootAndServicePrincipal", "Effect": "Allow", "Principal": {"AWS": ["arn:aws:iam::" + account + ":user/principal", "arn:aws:iam::" + account + ":root"]}, "Action": "kms:*", "Resource": "*"}]}
        key['Tags']                    = []
        key['Tags'].append({'TagKey'        : 'Version'             , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Project'             , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Module'              , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Environment'         , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Owner'               , 'TagValue' : 'moi.moi@moi.fr'})
        key['Tags'].append({'TagKey'        : 'Name'                , 'TagValue' : 'test.test.test.' + region + '.test-' + str(i) + '.repository.key'})

        result['keys'].append({'name' : 'test-' + str(i), 'data' : key})

    logger.debug(dumps(result))

    return result

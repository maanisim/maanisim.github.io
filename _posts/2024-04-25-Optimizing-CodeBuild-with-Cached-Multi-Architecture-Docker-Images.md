---
layout: single
title:  "Optimizing CodeBuild with Cached Multi-Architecture Docker Images"
---

At the time of writing AWS lacks a straightforward guide on creating multi-architecture CodeBuild containers [the one public blogpost](https://aws.amazon.com/blogs/devops/creating-multi-architecture-docker-images-to-support-graviton2-using-aws-codebuild-and-aws-codepipeline/) which exists suggests creating 3 CodeBuild projects -- a far cry from an optimal solution.

My goals for this project are simple:
- Streamline the AWS architecture
- Enchance CodeBuild's speed -- by extension save us time and money

# Pre-requisites
- This blogpost assumes that you use Amazon ECR & AWS CodeBuild
- You need CodeBuild IAM role with `AmazonEC2ContainerRegistryFullAccess`

```yaml
version: 0.2

env:
  variables:
    AWS_ECR_REPOSITORY_NAME: "multi-archi"

phases:
  pre_build:
    commands:
      - echo Checking current tools version
      - docker buildx version
      - echo Setting the env variables..
      - export GIT_TAG=$(git rev-parse --short HEAD)
      - export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
      - export AWS_REGISTRY_NAME=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - echo Logging in to amazon ECR...
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_REGISTRY_NAME
  build:
    commands:
      - echo Build Started on `date`
      - echo Building the docker image...
      - docker buildx create --use --name $AWS_ECR_REPOSITORY_NAME
      - docker buildx build --push --provenance=false --platform linux/amd64,linux/arm64 --tag $AWS_REGISTRY_NAME/$AWS_ECR_REPOSITORY_NAME:$GIT_TAG --tag  $AWS_REGISTRY_NAME/$AWS_ECR_REPOSITORY_NAME:latest --cache-to mode=max,image-manifest=true,oci-mediatypes=true,type=registry,ref=$AWS_REGISTRY_NAME/$AWS_ECR_REPOSITORY_NAME:cache --cache-from type=registry,ref=$AWS_REGISTRY_NAME/$AWS_ECR_REPOSITORY_NAME:cache .
      - echo Build completed on `date`
```

# Notes on local cache

- Best effort only, cache will get wiped if not used for ~15 minutes OR for the total lenght of the previous build - whichever is shorter.
- For custom cache, it requires the parent directory of the cached directory to exist
- Requires build to take longer than 5 minutes.

References:

[1] Build caching in AWS CodeBuild -  Local caching  - https://docs.aws.amazon.com/codebuild/latest/userguide/build-caching.html#caching-local

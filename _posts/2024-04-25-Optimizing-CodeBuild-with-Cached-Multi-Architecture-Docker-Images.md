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

buildspec.yml
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

The only modification in the buildspec that requires your attention is the name of your ECR repository to be used:
```
env:
  variables:
    AWS_ECR_REPOSITORY_NAME: "your-ecr-repository-name"
```

Dockerfile
```
# https://github.com/concourse/oci-build-task/issues/117
ARG BASE_IMAGE=XXXXXXXXXXXX.dkr.ecr.YYYYYYYYY.amazonaws.com/multi-archi
ARG BASE_IMAGE_TAG=latest

# Use the Amazon Linux 2 base image from ECR
FROM public.ecr.aws/amazonlinux/amazonlinux:2

# Install nginx from Amazon Linux Extras repository
RUN amazon-linux-extras install nginx1 -y

# Expose port 80
EXPOSE 80
# Start nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
```

In the `Dockerfile` please modify `XXXXXXXXXXXX` with your AWS account ID and `YYYYYYYYY` with your AWS region for example `eu-west-1`


# Local vs Cache storage backends

When using [the local cache in CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-caching.html#caching-local) it's important to be aware of it's limitations, as they are not publically documented. 

- Best effort only, cache will get wiped if not used for ~15 minutes OR for the total length of the previous build - whichever is shorter.
- For custom cache, it requires the parent directory of the cached directory to exist
- Requires build to take longer than 5 minutes.

As you can already guess, this means AWS will only use this cache if you constantly run build back-to-back. Most people don't.

Fortunately there is a solution to this "storage backends" use the ECR repositories as a cache store [simply add --cache-to and --cache-from](https://docs.docker.com/build/cache/backends/#command-syntax) and your build speeds will dractically increase, in my case it went from ~1min 31sec to ~33-39sec that's ~60% speed difference for adding 2 lines.


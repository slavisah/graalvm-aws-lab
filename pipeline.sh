#!/usr/bin/env bash
scriptdir=$(cd "$(dirname "$0")" || exit; pwd)
echo "================================================================================"
echo "Stage 0: Verify S3 bucket, AWS profile and region                                          "
echo "================================================================================"

./check_env.sh || exit

echo "-------------------------------------------------------"
echo " Stage 1: Build                                        "
echo "-------------------------------------------------------"

echo "!!! To be added. Nothing happens here at the moment !!!"

echo "-------------------------------------------------------"
echo " Stage 2: Copy artifacts to S3                         "
echo "-------------------------------------------------------"

aws s3 cp "$scriptdir/target" s3://"$GRL_AWS_LAB_BUILDS_S3_BUCKET" --recursive --include "*" || exit

echo "-------------------------------------------------------"
echo " Stage 3: Terraform                                    "
echo "-------------------------------------------------------"

(cd "$scriptdir/grl-aws-tf-infrastructure" &&
terraform init &&
terraform plan -out tfplan -var "s3_bucket=$GRL_AWS_LAB_BUILDS_S3_BUCKET" &&
terraform apply "tfplan"
) || exit

echo "================================================================================"
echo "Stage 4: Deploy                                                                 "
echo "================================================================================"

./deploy.sh
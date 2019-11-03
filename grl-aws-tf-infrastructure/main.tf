provider "aws" {
  version = "~> 2.33"
}

# IAM role which dictates what other AWS services the Lambda function
# may access. Based on AWSLambdaBasicExecutionRole (role policy taken from it)
resource "aws_iam_role" "iam_for_lambda" {
  name = "grl_aws_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

variable s3_bucket {}

module java-basic-256 {
    source = "_modules/grl-aws-lambda"

    function_name = "grl-aws-java-basic-256"
    s3_bucket = "${var.s3_bucket}"
    artifact = "grl-aws-java-basic.jar"
    handler = "com.comsysto.lab.grlaws.Handler::handleRequest"
    runtime = "java8"
    memory = "256"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    environment = {
      "owner" = "grl-aws-lab"
    }
}

module graalvm-ce-256 {
    source = "_modules/grl-aws-lambda"

    function_name = "grl-aws-graalvm-ce-256"
    s3_bucket = "${var.s3_bucket}"
    artifact = "grl-aws-graalvm-ce.zip"
    handler = "com.comsysto.lab.grlaws.Handler::handleRequest"
    runtime = "provided"
    memory = "256"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    environment = {
      "owner" = "grl-aws-lab"
    }
}

module quarkus-basic-256 {
    source = "_modules/grl-aws-lambda"

    function_name = "grl-aws-quarkus-basic-256"
    s3_bucket = "${var.s3_bucket}"
    artifact = "grl-aws-quarkus-basic.jar"
    handler = "io.quarkus.amazon.lambda.runtime.QuarkusStreamHandler::handleRequest"
    runtime = "java8"
    memory = "256"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    environment = {
      "owner" = "grl-aws-lab"
    }
}

module quarkus-native-256 {
    source = "_modules/grl-aws-lambda"

    function_name = "grl-aws-quarkus-native-256"
    s3_bucket = "${var.s3_bucket}"
    artifact = "grl-aws-quarkus-native.zip"
    handler = "any.name.not.used"
    runtime = "provided"
    memory = "256"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    environment = {
      "owner" = "grl-aws-lab"
      "DISABLE_SIGNAL_HANDLERS" = "true"
    }
}
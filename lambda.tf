terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = ">= 3.0"
  }
  
}


provider "aws" {
  region = "ap-southeast-2"
}

data "archive_file" "examplezip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda/"
    output_path = "${path.module}/example.zip"
}

resource "aws_s3_bucket" "s3bucket" {
  bucket = "terraform-lambda-tfe-example-yulei"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "fileobject" {
  bucket = "terraform-lambda-tfe-example-yulei"
  key    = "example.zip"
  source = "${path.module}/example.zip"
  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/lambda/main.js")
   depends_on = [aws_s3_bucket.s3bucket]
}


resource "aws_lambda_function" "example" {
  function_name = "ServerlessExampleyulei"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "terraform-lambda-tfe-example-yulei"
  s3_key    = "example.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "nodejs12.x"

  role = aws_iam_role.lambda_exec.arn
  depends_on = [aws_s3_bucket_object.fileobject]
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda_yulei"

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

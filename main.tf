provider "aws" {
  region  = "us-east-1"
  access_key = my_access_key
  secret_key = my_secret_key
}



variable "my_access_key" {
  description = "This is my access key"
  type = string
}

variable "my_secret_key" {
  description = "This is my secret key"
  type = string
}


# Create S3 Bucket 
resource "aws_s3_bucket" "jeph-raw-data-bucket" {
  bucket = "jeph-raw-data-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
  }
}


# create Glue catalog database
resource "aws_glue_catalog_database" "demoDatabase" {
  name = "demoDatabase"
  description= "catalog Database where i store schema and datatype information"
}

# create Glue crawler
resource "aws_glue_crawler" "demoCrawler" {
  database_name = "demoDatabase"
  name          = "demoCrawler"
  role          = "aws_iam_role.s3_role"

  s3_target {
    #path = "s3://${aws_s3_bucket.example.bucket}"
    path = "s3://jeph-raw-data-bucket"
    #path = "aws_s3_bucket.raw-data-bucket"
  }
}



# Create iam role policy

resource "aws_iam_policy" "demo_policy" {
  name        = "demo_policy"
  path        = "/"
  description = "My demo policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


# Create an IAM role

resource "aws_iam_role" "s3_role" {
  name = "s3_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}







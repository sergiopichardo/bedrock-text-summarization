data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.root}/lambda_functions/${local.project_name}/index.py"
  output_path = "${path.root}/lambda_functions/${local.project_name}/${local.project_name}_lambda_function.zip"
}

output "lambda_function_zip" {
  value = data.archive_file.lambda_function.output_path
}

resource "aws_iam_role" "lambda_assume_role" {
  name = "lambda_assume_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "basic_lambda_permissions" {
  name        = "basic_lambda_permissions"
  description = "Basic lambda permissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "basic_lambda_permissions_attachment" {
  role       = aws_iam_role.lambda_assume_role.name
  policy_arn = aws_iam_policy.basic_lambda_permissions.arn
}

resource "aws_iam_role_policy_attachment" "bedrock_policy_attachment" {
  role       = aws_iam_role.lambda_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

resource "aws_lambda_function" "text_summarization" {
  filename         = data.archive_file.lambda_function.output_path
  function_name    = "${local.project_name}-lambda-function"
  handler          = "index.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_assume_role.arn
  timeout          = 180 # Increase timeout to 3 minutes since image generation might take longer
  source_code_hash = filebase64sha256(data.archive_file.lambda_function.output_path)
  memory_size      = 1024 # Add more memory if needed

  environment {
    variables = {
      BEDROCK_MODEL_ID = ""
    }
  }

  tags = {
    Name = "${local.project_name}-lambda-function"
  }
}

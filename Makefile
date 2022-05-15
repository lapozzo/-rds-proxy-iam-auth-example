deploy:
	sh build-lambda.sh
	terraform init
	terraform plan
	terraform apply
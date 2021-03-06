DOCKER_IMAGE=docker-confd-dynamodb-haproxy

rm:
	-docker rm -f ${DOCKER_IMAGE}

build:
	docker build -t ${DOCKER_IMAGE} .

run:
	docker run -d \
		-e AWS_REGION=eu-west-1 \
		-e AWS_ACCESS_KEY_ID=$$(aws configure get aws_access_key_id) \
		-e AWS_SECRET_ACCESS_KEY=$$(aws configure get aws_secret_access_key) \
		-p 8000:8000 \
		-p 8001:8001 \
		--name ${DOCKER_IMAGE} \
		${DOCKER_IMAGE} --log-level debug

setup-dynamodb:
	aws dynamodb create-table \
	    --region eu-west-1 --table-name services \
	    --attribute-definitions AttributeName=key,AttributeType=S \
	    --key-schema AttributeName=key,KeyType=HASH \
	    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

run-registrator:
	# Registrator DynamoDB - https://github.com/mijime/registrator-dynamodb
	docker run -d \
		-v /var/run/docker.sock:/tmp/docker.sock \
		-v ~/.aws:/root/.aws \
		-e AWS_REGION=eu-west-1 \
		--name=registrator-dynamodb \
		registrator-dynamodb -internal dynamodb://services/test

run-app:
	# An example of simple app https://github.com/agassner/docker-node
	docker run -d -l SERVICE_NAME=simple-app1 -l SERVICE_ID=instance1:app1 --name app1a -p 8081:8080 simple-app
	docker run -d -l SERVICE_NAME=simple-app1 -l SERVICE_ID=instance2:app1 --name app1b -p 8082:8080 simple-app
	docker run -d -l SERVICE_NAME=simple-app2 -l SERVICE_ID=instance1:app2 --name app2a -p 8083:8080 simple-app
	docker run -d -l SERVICE_NAME=simple-app2 -l SERVICE_ID=instance2:app2 --name app2b -p 8084:8080 simple-app

run-dependencies: run-registrator run-app

clean-up: rm clean-up-app
	-docker rm -f registrator-dynamodb

clean-up-app:
	-docker rm -f app1a app1b app2a app2b


path    ?= $(shell pwd)
grant   ?= ${path}/grant.zip
tfstate ?= terraform.tfstate
tfplan  ?= terraform.tfplan

app     ?= grant

os_type ?= linux
region  ?= westus2
image   ?= grant-oauth

subscription_id ?= ...
tenant_id       ?= ...
client_id       ?= ...
client_secret   ?= ...

user ?= ...
pass ?= ...

firebase_path ?= ...
firebase_auth ?= ...

example ?= transport-state

# -----------------------------------------------------------------------------

# Develop

build-dev:
	cd ${path}/examples/${example} && \
	rm -rf node_modules && \
	npm install --production && \
	docker build -t ${image} .

run-dev:
	cd ${path}/examples/${example} && \
	docker run -p 3000:80 ${image}

# -----------------------------------------------------------------------------

# Build

build-grant:
	rm -f ${grant}
	cd ${path}/examples/${example} && \
	rm -rf node_modules && \
	npm install --production && \
	zip -r ${grant} grant host.json proxies.json package.json store.js

build-callback:
	rm -f ${grant}
	cd ${path}/examples/${example} && \
	rm -rf node_modules && \
	npm install --production && \
	zip -r ${grant} grant hello hi host.json proxies.json package.json store.js

# -----------------------------------------------------------------------------

# Deploy

token = $(shell echo -n "\$$${user}:${pass}" | base64 -w 0)
auth = Authorization: Basic ${token}
deploy_url = https://${app}.scm.azurewebsites.net/api/zipdeploy

deploy:
	curl -X POST ${deploy_url} --header "${auth}" --data-binary @"${grant}"

# -----------------------------------------------------------------------------

# Terraform

init:
	cd ${path}/terraform/ && \
	terraform init

plan:
	cd ${path}/terraform/ && \
	TF_VAR_app=${app} \
	TF_VAR_region=${region} \
	TF_VAR_os_type=${os_type} \
	TF_VAR_subscription_id=${subscription_id} \
	TF_VAR_tenant_id=${tenant_id} \
	TF_VAR_client_id=${client_id} \
	TF_VAR_client_secret=${client_secret} \
	TF_VAR_firebase_path=${firebase_path} \
	TF_VAR_firebase_auth=${firebase_auth} \
	terraform plan \
	-state=${tfstate} \
	-out=${tfplan}

apply:
	cd ${path}/terraform/ && \
	TF_VAR_app=${app} \
	TF_VAR_region=${region} \
	TF_VAR_os_type=${os_type} \
	TF_VAR_subscription_id=${subscription_id} \
	TF_VAR_tenant_id=${tenant_id} \
	TF_VAR_client_id=${client_id} \
	TF_VAR_client_secret=${client_secret} \
	TF_VAR_firebase_path=${firebase_path} \
	TF_VAR_firebase_auth=${firebase_auth} \
	terraform apply \
	-state=${tfstate} \
	${tfplan}

destroy:
	cd ${path}/terraform/ && \
	TF_VAR_app=${app} \
	TF_VAR_region=${region} \
	TF_VAR_os_type=${os_type} \
	TF_VAR_subscription_id=${subscription_id} \
	TF_VAR_tenant_id=${tenant_id} \
	TF_VAR_client_id=${client_id} \
	TF_VAR_client_secret=${client_secret} \
	TF_VAR_firebase_path=${firebase_path} \
	TF_VAR_firebase_auth=${firebase_auth} \
	terraform destroy \
	-state=${tfstate}

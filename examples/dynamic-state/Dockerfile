FROM mcr.microsoft.com/azure-functions/node:3.0-node12

ENV AzureWebJobsScriptRoot=/home/site/wwwroot

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

ENV FIREBASE_PATH=...
ENV FIREBASE_AUTH=...

COPY . /home/site/wwwroot

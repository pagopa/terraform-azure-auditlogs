FROM mcr.microsoft.com/azure-functions/node:4.0
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true
COPY ./archive-audit-logs /home/site/wwwroot
RUN cd /home/site/wwwroot

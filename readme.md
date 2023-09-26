# API Management to Cosmos Db using a Graph QL Binding

A preview feature that configures a {GraphQL resolver](<https://techcommunity.microsoft.com/t5/azure-integration-services-blog/expose-your-data-from-azure-cosmos-db-or-azure-sql-through-a/ba-p/3846252>) over a data source. It removes the need for a web application (api) that connects to the data source and presents the data out using a GraphQL schema. For this example, CosmosDb is used as the data source.

## Supporting infrastructure

The repository has some infrastructure as code artifacts that spin up a vanilla API Management and CosmosDb. The following two Azure CLI commands create the resource group and then provision API Management and Cosmos Db.

``` bash
az group create -n rg-apimcosgql-dev-001 -l uksouth --tags "productOwner=abc" "application=def" "environment=dev" "projectCode=ghi" --debug

az deployment group create -f ./main.bicep -g rg-apimcosgql-dev-001 --parameters environment=dev location=northeurope --debug
```



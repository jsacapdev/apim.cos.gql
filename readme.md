# API Management to Cosmos Db using a Graph QL Binding

``` bash
az group create -n rg-apimcosgql-dev-001 -l uksouth --tags "productOwner=abc" "application=def" "environment=dev" "projectCode=ghi" --debug

az deployment group create -f ./main.bicep -g rg-apimcosgql-dev-001 --parameters environment=dev location=northeurope --debug
```

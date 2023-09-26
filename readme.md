# API Management to Cosmos Db using a Graph QL Binding

A [preview](https://azure.microsoft.com/en-gb/updates/public-preview-graphql-resolvers-for-azure-cosmos-db-azure-sql-in-azure-api-management/) feature that configures a [GraphQL resolver](https://techcommunity.microsoft.com/t5/azure-integration-services-blog/expose-your-data-from-azure-cosmos-db-or-azure-sql-through-a/ba-p/3846252) over a data source. It removes the need for a web application (api) that connects to the data source and presents the data out using a GraphQL schema. For this example, CosmosDb is used as the data source.

## Supporting infrastructure

The repository has some infrastructure as code artifacts that spin up a vanilla API Management and CosmosDb. The following two Azure CLI commands create the resource group and then provision API Management and Cosmos Db.

``` bash
az group create -n rg-apimcosgql-dev-001 -l uksouth --tags "productOwner=abc" "application=def" "environment=dev" "projectCode=ghi" --debug

az deployment group create -f ./main.bicep -g rg-apimcosgql-dev-001 --parameters environment=dev location=northeurope --debug
```

## Cosmos Db Set-Up

All of the following has been created manually in the Portal.

Create a database called `tododemo` and a container called `todo`.

Seed it with the following data:

``` json
[
    {
        "id": "68805715-4b72-49cb-bb78-eeda1d29e7eb",
        "title": "f08d98c1-d1ed-4774-bfab-c5b4fec9a7d2",
        "completed": false
    },
    {
        "id": "2126d3b9-e15d-46b0-8e2e-8480747c4f07",
        "title": "b3dff43a-1e33-4550-ac3d-5817b450af34",
        "completed": true
    },
    {
        "id": "98a86b8c-3ba3-438b-8315-3cd1cd521ee5",
        "title": "76bc3435-aadb-48d4-a7fa-6d1e6593b9db",
        "completed": false
    },
    {
        "id": "1",
        "title": "2",
        "completed": true
    }    
]
```

## Creating the API in APIM


Create the API, of type GraphQL. Select the setting for a `Synthetic GraphQL` type and upload the following schema:

``` graphql
type TodoItem { 
  id: ID! 
  title: String! 
  completed: Boolean! 
} 

input CreateTodoItemInput { 
    id: ID! 
    title: String! 
    completed: Boolean! 
} 

input ReplaceTodoItemInput { 
  id: ID! 
  title: String! 
  completed: Boolean! 
} 

type Query { 
  todoItems: [TodoItem] 
  todoItem(id: ID!): TodoItem 
} 

type Mutation { 
  createTodoItem(input: CreateTodoItemInput!): TodoItem! 
  replaceTodoItem(input: ReplaceTodoItemInput!): TodoItem! 
  deleteTodoItem(id: ID!): Boolean 
} 
```

Give it a `API URL suffix` of `todogql`.

Go to the resolver tab in APIM and create the following two resolvers.

### Resolver to return a single item

Add a resolver with a name `Query-todoItem` with a field of `todoitem` and data source of `Cosmos Db`. Provide the following resolver policy:

``` xml
<cosmosdb-data-source>
 <connection-info>
  <connection-string>AccountEndpoint=https://cosmos-apimcosgql-dev-001.documents.azure.com:443/;AccountKey=;</connection-string>
  <database-name>tododemo</database-name>
  <container-name>todo</container-name>
 </connection-info>
 <read-request>
  <id>@(context.GraphQL.Arguments["id"].ToString())</id>
  <partition-key>@(context.GraphQL.Arguments["id"].ToString())</partition-key>
 </read-request>
</cosmosdb-data-source>
```

### Resolver to return a collection

Add a resolver with a name `Query-todoItems` with a field of `todoitem` and data source of `Cosmos Db`. Provide the following resolver policy:

``` xml
<cosmosdb-data-source>
 <connection-info>
  <connection-string>AccountEndpoint=https://cosmos-apimcosgql-dev-001.documents.azure.com:443/;AccountKey=;</connection-string>
  <database-name>tododemo</database-name>
  <container-name>todo</container-name>
 </connection-info>
 <query-request>
  <sql-statement>SELECT * FROM c</sql-statement>
 </query-request>
 <response>
  <set-body> 
        @{ var response = context.Response.Body.As<JObject>();
        return response["items"].ToString();
        }
        </set-body>
 </response>
</cosmosdb-data-source>
```

Ideally, change the use of a key to managed identity to query Cosmos.

## Testing

Go to the test tab and choose the query the `todoItem` or `todoItems`.

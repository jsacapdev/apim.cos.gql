@minLength(3)
@maxLength(8)
@description('The environment name.')
param environment string = 'dev'

@minLength(1)
@maxLength(20)
@description('The location.')
param location string

//////////////////////
// global variables 
//////////////////////

// product name
var product = 'apimcosgql'

var cosmosAccountName = 'cosmos-${product}-${environment}-001'
var cosmosPrimaryRegion = 'northeurope'
var cosmosSecondaryRegion = 'westeurope'

var apiManagementServiceName = 'apim-${product}-${environment}-001'
var publisherEmail = 'me@dat.com'
var publisherName = 'me dat'

param tags object = {
  productOwner: 'abc'
  application: 'def'
  environment: 'dev'
  projectCode: 'ghi'
}

module cosmos './modules/cosmos.bicep' = {
  name: 'cosmos'
  params: {
    location: location
    tags: tags
    accountName: cosmosAccountName
    primaryRegion: cosmosPrimaryRegion
    secondaryRegion: cosmosSecondaryRegion
  }
}

module apim './modules/apim.bicep' = {
  name: 'apim'
  params: {
    tags: tags
    location: location
    apiManagementServiceName: apiManagementServiceName
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

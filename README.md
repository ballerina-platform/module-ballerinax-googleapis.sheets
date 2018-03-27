# Ballerina Google Spreadsheet Connector

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet connector allows you to access the Google Spreadsheet API Version v4 through Ballerina.

The following sections provide you with information on how to use the Ballerina Google Spreadsheet connector.
- [Compatibility](#compatibility)
- [Getting started](#getting-started)
- [Running Samples](#running-samples)
- [Quick Testing](#quick-testing)
- [Working with Google Spreadsheet connector actions](#working-with-ethereum-connector-actions)

### Compatibility

| Language Version | Connector Version | API Version |
|-------|:------------:|:------------:|
| 0.970.0-alpha0 | V1 | V4 |


## Getting started
1. Clone package-googlespreadsheet from [https://github.com/wso2-ballerina/package-googlespreadsheet](https://github.com/wso2-ballerina/package-googlespreadsheet).
2. Navigate to package-googlespreadsheet and use 'ballerina build src/wso2/googlespreadsheet/' command to build the connector.

##### Prerequisites
1. Create a project and create an app for this project by visiting [Google Spreadsheet](https://console.developers.google.com/_

2. Obtain the following parameters

    * Client Id
    * Client Secret
    * Redirect URI
    * Access Token
    * Refresh Token

**IMPORTANT** This access token and refresh token can be used to make API requests on your own
account's behalf. Do not share your access token, client  secret with anyone.


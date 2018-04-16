# Ballerina Google Spreadsheet Connector

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet connector allows you to access the Google Spreadsheet API Version v4 through Ballerina.

The following sections provide you with information on how to use the Ballerina Google Spreadsheet connector.
- [Compatibility](#compatibility)
- [Getting started](#getting-started)


### Compatibility

| Language Version | Connector Version | API Version |
|-------|:------------:|:------------:|
| ballerina-platform-0.970.0-beta0   | 0.8.4  | V4 |


## Getting started
1. Clone package-googlespreadsheet from [https://github.com/wso2-ballerina/package-googlespreadsheet](https://github.com/wso2-ballerina/package-googlespreadsheet).
2. Import the package to your ballerina project.

##### Prerequisites
Download the ballerina [distribution](https://ballerinalang.org/downloads/).

##### Prerequisites
1. Create a project and create an app for this project by visiting [Google Spreadsheet](https://console.developers.google.com/)

2. Obtain the following parameters

    * Client Id
    * Client Secret
    * Redirect URI
    * Access Token
    * Refresh Token

**IMPORTANT** This access token and refresh token can be used to make API requests on your own
account's behalf. Do not share your access token, client  secret with anyone.

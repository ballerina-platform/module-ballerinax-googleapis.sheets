[![Build Status](https://travis-ci.org/wso2-ballerina/module-googlespreadsheet.svg?branch=master)](https://travis-ci.org/wso2-ballerina/module-googlespreadsheet)

# Ballerina Google Spreadsheet Endpoint

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet endpoint allows you to access the Google Spreadsheet API Version v4 through Ballerina.

The following sections provide you with information on how to use the Ballerina Google Spreadsheet endpoint.
- [Compatibility](#compatibility)
- [Getting started](#getting-started)


### Compatibility

| Ballerina Language Version  | Google Spreadsheet API Version |
|:---------------------------:|:------------------------------:|
|  0.990.0                     |   V4                           |

##### Prerequisites
Download the ballerina [distribution](https://ballerinalang.org/downloads/).

##### Contribute To Develop
Clone the repository by running the following command
`git clone https://github.com/wso2-ballerina/module-googlespreadsheet.git`

## Working with GSheets Endpoint actions
All the actions return valid response or error. If the action is a success, then the requested resource will
be returned. Else error will be returned.

In order for you to use the GSheets Endpoint, first you need to create a GSheets Client endpoint.

```ballerina
import wso2/gsheets4;

SpreadsheetConfiguration spreadsheetConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken:"<your_accessToken>",
            refreshToken:"<your_refreshToken>",
            clientId:"<your_clientId>",
            clientSecret:"<your_clientSecret>"
        }
    }
};

Client spreadsheetClient = new(spreadsheetConfig);
```

Then the endpoint actions can be invoked as `var response = spreadsheetClient->actionName(arguments)`.

#### Sample
```ballerina
import ballerina/config;
import ballerina/io;
import wso2/gsheets4;

function main(string... args) {
    SpreadsheetConfiguration spreadsheetConfig = {
        clientConfig: {
            auth: {
                scheme: http:OAUTH2,
                accessToken: config:getAsString("ACCESS_TOKEN"),
                clientId: config:getAsString("CLIENT_ID"),
                clientSecret: config:getAsString("CLIENT_SECRET"),
                refreshToken: config:getAsString("REFRESH_TOKEN")
            }
        }
    };
    Client spreadsheetClient = new(spreadsheetConfig);

    gsheets4:Spreadsheet spreadsheet = new;
    var response = spreadsheetClient->openSpreadsheetById("abc1234567");
    if (response is gsheets4:Spreadsheet) {
        spreadsheet = response;
    } else {
        io:println(response);
    }
    io:println(spreadsheet);
}
```

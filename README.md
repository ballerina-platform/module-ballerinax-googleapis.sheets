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
|  0.990.3                     |   V4                           |

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

gsheets4:SpreadsheetConfiguration spreadsheetConfig = {
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

gsheets4:Client spreadsheetClient = new(spreadsheetConfig);
```

Then the endpoint actions can be invoked as `var response = spreadsheetClient->actionName(arguments)`.

#### Sample
```ballerina
import ballerina/io;
import ballerina/http;
import wso2/gsheets4;

gsheets4:SpreadsheetConfiguration spreadsheetConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken:"<accessToken>",
            clientId:"<clientId>",
            clientSecret:"<clientSecret>",
            refreshToken:"<refreshToken>"
        }
    }
};
gsheets4:Client spreadsheetClient = new(spreadsheetConfig);

public function main(string... args) {
    string spreadsheetId = "1Ti2W5mGK4mq0_xh9Gl_zG_dK9qqwdduirsFgl6zZu7M";
    var response = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (response is gsheets4:Spreadsheet) {
        io:println("Spreadsheet Details : ", response);
    } else {
        io:println("Error: ", response);
    }
}
```

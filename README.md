# Ballerina Google Spreadsheet Endpoint

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet endpoint allows you to access the Google Spreadsheet API Version v4 through Ballerina.

The following sections provide you with information on how to use the Ballerina Google Spreadsheet endpoint.
- [Compatibility](#compatibility)
- [Getting started](#getting-started)


### Compatibility

| Ballerina Language Version  | Google Spreadsheet API Version |
| ----------------------------| -------------------------------|
|  0.974.1                    |   V4                           |

##### Prerequisites
Download the ballerina [distribution](https://ballerinalang.org/downloads/).

##### Contribute To Develop
Clone the repository by running the following command
    `git clone https://github.com/wso2-ballerina/package-googlespreadsheet.git`

## Working with GSheets Endpoint actions
All the actions return valid response or SpreadsheetError. If the action is a success, then the requested resource will be returned. Else SpreadsheetError object will be returned.

In order for you to use the GSheets Endpoint, first you need to create a GSheets Client
endpoint.
```ballerina
    import wso2/gsheets4;

        endpoint gsheets4:Client spreadsheetClientEP {
            clientConfig:{
                auth:{
                    accessToken:"<your_accessToken>",
                    refreshToken:"<your_refreshToken>",
                    clientId:"<your_clientId>",
                    clientSecret:"<your_clientSecret>"
                }
            }
        };
```

Then the endpoint actions can be invoked as `var response = spreadsheetClientEP -> actionName(arguments)`.

#### Sample
```ballerina
    import wso2/gsheets4;

    public function main (string[] args) {
        endpoint gsheets4:Client spreadsheetClientEP {
            clientConfig:{
                auth:{
                    accessToken:config:getAsString("ACCESS_TOKEN"),
                    refreshToken:config:getAsString("REFRESH_TOKEN"),
                    clientId:config:getAsString("CLIENT_ID"),
                    clientSecret:config:getAsString("CLIENT_SECRET")
                }
            }
        };

        gsheets4:Spreadsheet spreadsheet = new;
        var response = spreadsheetClient -> openSpreadsheetById("abc1234567");
        match response {
            gsheets4:Spreadsheet spreadsheetRes => {
                spreadsheet = spreadsheetRes;
            }
            SpreadsheetError err => {
                io:println(err);
            }
        }

        io:println(spreadsheet);
    }
```
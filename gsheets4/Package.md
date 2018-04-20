#  Google Spreadsheet Connector

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet connector allows you to access the Google Spreadsheet API Version v4 through Ballerina.


## Compatibility
| Ballerina Language Version  | Google Spreadsheet API Version |
| ----------------------------| -------------------------------|
|  0.970.0-beta3              |   V4                           |

The following sections provide you with information on how to use the Ballerina Google Spreadsheet connector.

- [Prerequisites](#prerequisites)
- [Getting started](#getting-started)
- [Working with GSheets Endpoint actions](#working-with-gsheets-endpoint-actions)

#### Getting started

1. Refer [Getting Started](https://ballerina.io/learn/getting-started/) to download Ballerina and install tools.

2. In order to use the Gsheets connector, you need to provide a valid access token or valid client id, client secret and refresh token. Refer this [link](https://developers.google.com/identity/protocols/OAuth2) to obtain these credentials.

3. Create a new Ballerina project
    ```bash
        <PROJECT_ROOT_DIRECTORY>$ ballerina init
    ```

4. Import the package to your ballerina project.
    ```ballerina
        import wso2/gsheets4;
    ```
This will download the gsheets4 artifacts from the central repository to your local repository.

#### Working with GSheets Connector actions
All the actions return valid response or SpreadsheetError. If the action is a success, then the requested resource will be returned. Else SpreadsheetError object will be returned.

In order for you to use the GSheets Connector, first you need to create a GSheets Client
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

#  Google Spreadsheet Connector

Connects to Google Spreadsheet from Ballerina

The Google Spreadsheet connector provides an optimized way to use the Google Spreadsheet REST API from your Ballerina programs. It handles OAuth 2.0 and provides auto completion and type conversions.

### Compatibility
| Ballerina Language Version  | Google Spreadsheet API Version |
| ----------------------------| -------------------------------|
|  0.970.0-beta12             |   V4                           |

### Getting started

1. Refer [Getting Started](https://ballerina.io/learn/getting-started/) to download Ballerina and install tools.

2. Obtain your OAuth 2.0 credentials. To access a Google Spreadsheet, you will need to provide the Client ID, Client Secret, and Refresh Token, or just the Access Token. For more information, see the [Google OAuth 2.0](https://developers.google.com/identity/protocols/OAuth2) documentation.

3. Create a new Ballerina project by executing the following command.
    ```shell
        <PROJECT_ROOT_DIRECTORY>$ ballerina init
    ```

4. Import the gsheets4 package to your ballerina project as follows.

    ```ballerina
        import ballerina/io;
        import wso2/gsheets4;

        function main (string... args)
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

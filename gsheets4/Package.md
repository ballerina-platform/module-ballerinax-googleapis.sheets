#  Google Spreadsheet Connector

Allows to access the Google Spreadsheet API

The Google Spreadsheet connector provides a Ballerina API to access the Google Spreadsheet API. This connector will allow you to access, create and modify google docs spreadsheets using OAuth 2.0 authentication. The following sections provide you with information on how to use the Ballerina Google Spreadsheet connector.

### Compatibility
| Ballerina Language Version  | Google Spreadsheet API Version |
| ----------------------------| -------------------------------|
|  0.970.0-beta12             |   V4                           |

### Getting started

1. Refer [Getting Started](https://ballerina.io/learn/getting-started/) to download Ballerina and install tools.

2. In order to use the Gsheets connector, you need to provide a valid access token or valid client id, client secret and refresh token. Refer this [link](https://developers.google.com/identity/protocols/OAuth2) to obtain these credentials.

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

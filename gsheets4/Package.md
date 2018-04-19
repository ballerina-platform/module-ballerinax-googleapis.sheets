# Ballerina Google Spreadsheet Endpoint

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet endpoint allows you to access the Google Spreadsheet API Version v4 through Ballerina.


## Compatibility
| Language Version        | Endpoint Version          | API Versions  |
| ------------- |:-------------:| -----:|
| ballerina-platform-0.970.0-beta1    | 0.8.6 | V4  |

The following sections provide you with information on how to use the Ballerina Google Spreadsheet endpoint.

- [Prerequisites](#prerequisites)
- [Getting started](#getting-started)
- [Working with GSheets Endpoint actions](#working-with-gsheets-endpoint-actions)
- [Quick Testing](#quick-testing)

**Note :** The source code of the Google Spreadsheet endpoint can be found at [package-googlespreadsheet](https://github.com/wso2-ballerina/package-googlespreadsheet).

#### Prerequisites
Download the ballerina [distribution](https://ballerinalang.org/downloads/).

#### Getting started
1. Create a project and create an app for this project by visiting [Google Spreadsheet](https://console.developers.google.com/)

2. Obtain the following parameters

    * Client Id
    * Client Secret
    * Redirect URI
    * Access Token
    * Refresh Token

**IMPORTANT** This access token and refresh token can be used to make API requests on your own
account's behalf. Do not share your access token, client  secret with anyone.

3. Import the package to your ballerina project.
    ```ballerina
       import wso2/gsheets4;
    ```
This will download the gsheets4 artifacts from the central repository to your local repository.

#### Working with GSheets Endpoint actions
All the actions return valid response or SpreadsheetError. If the action is a success, then the requested resource will be returned. Else SpreadsheetError object will be returned.

In order for you to use the GSheets Endpoint, first you need to create a GSheets Client
endpoint.
```ballerina
    import wso2/gsheets4;

        endpoint gsheets4:Client spreadsheetClientEP {
            clientConfig:{
                auth:{
                    accessToken:accessToken,
                    refreshToken:refreshToken,
                    clientId:clientId,
                    clientSecret:clientSecret
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

## Quick Testing
This section provides information on how to create a Spreadsheet endpoint to invoke the actions and sample requests for each action.

1. Create a Google Spreadsheet endpoint.

```ballerina
    import wso2/gsheets4;

    endpoint gsheets4:Client spreadsheetClientEP {
        clientConfig:{
            auth:{
                accessToken:accessToken,
                refreshToken:refreshToken,
                clientId:clientId,
                clientSecret:clientSecret
            }
        }
    };
```

2. Create a new spreadsheet with the given name.

```ballerina
    gsheets4:Spreadsheet spreadsheet =  check spreadsheetClient -> createSpreadsheet("Finances");
```

3. Open the spreadsheet with the given ID

```ballerina
    gsheets4:Spreadsheet spreadsheet = check spreadsheetClient -> openSpreadsheetById("abc1234567");
```

4. Get the name of the spreadsheet.

```ballerina
    gsheets4:Spreadsheet spreadsheet = check spreadsheetClient -> openSpreadsheetById("abc1234567");
    string spreadsheetName = check spreadsheet.getSpreadsheetName();
```

5. Get the id of the spreadsheet.

```ballerina
    gsheets4:Spreadsheet spreadsheet = check spreadsheetClient -> createSpreadsheet("Finances");
    string spreadsheetId = check spreadsheet.getSpreadsheetId();
```

6. Get all the sheets in a spreadsheet.

```ballerina
    gsheets4:Spreadsheet spreadsheet = check spreadsheetClient -> openSpreadsheetById("abc1234567");
    gsheets4:Sheet[] sheets = check spreadsheet.getSheets();
```

7. Retrieve a sheet with the given name.

```ballerina
    gsheets4:Spreadsheet spreadsheet = check spreadsheetClient -> openSpreadsheetById("abc1234567");
    gsheets4:Sheet sheet = check spreadsheet.getSheetByName(sheetName);
```

8. Sets the value of the range.

```ballerina
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
                             ["Nisha", "98"], ["Kana", "86"]];
    boolean isUpadated = check spreadsheetClient -> setSheetValues("abc1234567", "Sheet1", "A1", "C5", values);
```

9. Retrieve sheet values for a given range.

```ballerina
    string[][] values = check spreadsheetClient -> getSheetValues("abc1234567", "Sheet1", "A1", "C5");
```

10. Retrieve a column data.

```ballerina
    string[] values = check spreadsheetClient -> getColumnData("abc1234567", "Sheet1", "A");
```

11. Retrieve a row data.

```ballerina
    string[] values = check spreadsheetClient -> getColumnData("abc1234567", "Sheet1", 1);
```

12. Set data for a cell.

```ballerina
    boolean isUpadated = check spreadsheetClient -> setCellData("abc1234567", "Sheet1", "B", 5, "90");
```

13. Get data of a cell.

```ballerina
    string value = check spreadsheetClient -> getCellData("abc1234567", "Sheet1", "B", 5);
```

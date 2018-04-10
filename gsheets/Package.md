# Ballerina Google Spreadsheet Connector

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet connector allows you to access the Google Spreadsheet API Version v4 through Ballerina.


## Compatibility
| Language Version        | Connector Version          | API Versions  |
| ------------- |:-------------:| -----:|
| ballerina-0.970-alpha-1-SNAPSHOT    | 0.8 | V4  |

The following sections provide you with information on how to use the Ballerina Google Spreadsheet connector.

- [Getting started](#getting-started)
- [Quick Testing](#quick-testing)

## Getting started

1. Install the ballerina distribution from [Ballerina Download Page](https://ballerinalang.org/downloads/).
2. Clone the repository by running the following command
    ```
       git clone https://github.com/wso2-ballerina/package-googlespreadsheet
    ```
3. Import the package to your ballerina project.
4. Create a project and create an app for this project by visiting [Google Spreadsheet](https://console.developers.google.com/)
5. Obtain the following parameters
    * Client Id
    * Client Secret
    * Redirect URI
    * Access Token
    * Refresh Token

    **IMPORTANT** This access token and refresh token can be used to make API requests on your own
    account's behalf. Do not share your access token, client  secret with anyone.


## Quick Testing
This section provides information on how to create a Spreadsheet endpoint to invoke the actions and sample requests for eaach action.

1. Create a Google Spreadsheet endpoint.

```ballerina
   endpoint googlespreadsheet4:SpreadsheetEndpoint sp {
       oauthClientConfig: {
          accessToken:"your_access_token",
          clientConfig:{},
          refreshToken:"your_refresh_token",
          clientId:"your_clientId",
          clientSecret:"your_clientSecret",
          useUriParams:true
       }
   };
```

2. Create a new spreadsheet with the given name.

```ballerina
    googlespreadsheet4:Spreadsheet spreadsheet = {};
    var response = sp -> createSpreadsheet("Finances");
    match response {
        googlespreadsheet4:Spreadsheet spreadsheetResponse => spreadsheet = spreadsheetResponse;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

3. Open the spreadsheet with the given ID

```ballerina
    googlespreadsheet4:Spreadsheet spreadsheet = {};
    var response = sp -> openSpreadsheetById("abc1234567");
    match response {
        googlespreadsheet4:Spreadsheet spreadsheetResponse => spreadsheet = spreadsheetResponse;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

4. Get the name of the spreadsheet.

```ballerina
    googlespreadsheet4:Spreadsheet spreadsheet = {};
    var response = sp -> openSpreadsheetById("abc1234567");
    match response {
        googlespreadsheet4:Spreadsheet spreadsheetResponse => spreadsheet = spreadsheetResponse;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
    string spreadsheetName = spreadsheet.getSpreadsheetName();
```

5. Get the id of the spreadsheet.

```ballerina
    googlespreadsheet4:Spreadsheet spreadsheet = {};
    var response = sp -> createSpreadsheet("Finances");
    match response {
        googlespreadsheet4:Spreadsheet spreadsheetResponse => spreadsheet = spreadsheetResponse;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
    string spreadsheetId = spreadsheet.getSpreadsheetId();
```

6. Get all the sheets in a spreadsheet.

```ballerina
    googlespreadsheet4:Spreadsheet spreadsheet = {};
    var response = sp -> openSpreadsheetById("abc1234567");
    match response {
        googlespreadsheet4:Spreadsheet spreadsheetResponse => spreadsheet = spreadsheetResponse;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
    googlespreadsheet4:Sheet[] sheets = spreadsheet.getSheets();
```

7. Retrieve a sheet with the given name.

```ballerina
    googlespreadsheet4:Spreadsheet spreadsheet = {};
    googlespreadsheet4:Sheet sheet = {};
    var response = sp -> openSpreadsheetById("abc1234567");
    match response {
        googlespreadsheet4:Spreadsheet spreadsheetResponse => spreadsheet = spreadsheetResponse;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
    var sheetRes = spreadsheet.getSheetByName(sheetName);
    match sheetRes {
        googlespreadsheet4:Sheet s => sheet = s;
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
```

8. Sets the value of the range.

```ballerina
    googlespreadsheet4:Range updatedRange = {};
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
                             ["Nisha", "98"], ["Kana", "86"]];
    var response = sp -> setSheetValues("abc1234567", "Sheet1", "A1", "C5", values);
    match response {
        googlespreadsheet4:Range range => updatedRange = range;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

9. Retrieve sheet values for a given range.

```ballerina
    string[][] values = [];
    var response = sp -> getSheetValues("abc1234567", "Sheet1", "A1", "C5");
    match response {
        string[][] vals => values = vals;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

10. Retrieve a column data.

```ballerina
    string[] values = [];
    var response = sp -> getColumnData("abc1234567", "Sheet1", "A");
    match response {
        string[] vals => values = vals;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

11. Retrieve a row data.

```ballerina
    string[] values = [];
    var response = sp -> getColumnData("abc1234567", "Sheet1", 1);
    match response {
        string[] vals => values = vals;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

12. Set data for a cell.

```ballerina
    googlespreadsheet4:Range updatedRange = {};
    var response = sp -> setCellData("abc1234567", "Sheet1", "B", 5, "90");
    match response {
        googlespreadsheet4:Range range => updatedRange = range;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

13. Get data of a cell.

```ballerina
    string value = "";
    var response = sp -> getCellData("abc1234567", "Sheet1", "B", 5);
    match response {
        string val => value = val;
        googlespreadsheet4:SpreadsheetError err => io:println(err);
    }
```

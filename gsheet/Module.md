## Overview

Google Spreadsheet Ballerina Connector is used to connect with the Google Spreadsheet via Ballerina language easily to implement some of the most common use cases of Google Spreadsheets. The connector provides the capability to programmatically manage spreadsheets, manage worksheets, do CRUD operations on worksheets, and do column wise, row wise and cell wise operations through the connector endpoints.

This module supports spreadsheet management operations like creating a spreadsheet, opening a spreadsheet, listing all the spreadsheets available in a user account, renaming a spreadsheet. It also supports worksheet management operations like getting all the worksheets available in a spreadsheet, opening a worksheet, adding a new worksheet, removing a worksheet and renaming a worksheet. The connector also provides capabilities to handle data level operations like setting, getting and clearing a range of data, inserting columns/rows before and after a given position, creating or updating, getting and deleting columns/rows, setting, getting and clearing cell data, appending a row to a sheet, appending a row to a range of data, appending a cell to a range of data, copying a worksheet to a destination spreadsheet, and clearing worksheets.

This module supports [Google Spreadsheet API v4](https://developers.google.com/sheets/api).

## Prerequisites

- Create [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
- Obtain Tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart

To use the Google Sheets connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import the Google Sheets Ballerina Library
First, import the ballerinax/googleapis.sheets module into the Ballerina project.
```ballerina
    import ballerinax/googleapis.sheets as sheets;
```
All the actions return valid response or error. If the action is a success, then the requested resource will be returned. Else error will be returned.

### Step 2: Initialize the Google Sheets Client
In order for you to use the GSheets Endpoint, first you need to create a GSheets Client endpoint.
```ballerina
configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: refreshToken
    }
};

sheets:Client spreadsheetClient = check new (spreadsheetConfig);
```
> **Note:** Must specify the **Refresh token** (obtained by exchanging the authorization code), **Refresh URL**, the **Client ID** and the **Client secret** obtained in the app creation, when configuring the Google Sheets connector client.

### Step 3: Invoke the endpoint

Then the endpoint actions can be invoked as `var response = spreadsheetClient->actionName(arguments)`.

## Quick reference
Code snippets of some frequently used functions: 

> **Note:** Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <SPREADSHEET_ID> + "/edit#gid=" + <WORKSHEET_ID>.

* Create Spreadsheet with given name
```ballerina
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("NewSpreadsheet");
```

* Add a New Worksheet with given name
```ballerina
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
```

* Open Spreadsheet by Spreadsheet ID
```ballerina
    sheets:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetById(spreadsheetId);
```

* Open Spreadsheet by Spreadsheet URL
```ballerina
    sheets:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetByUrl(url);
```

* Rename Spreadsheet
```ballerina
    error? rename = spreadsheetClient->renameSpreadsheet(spreadsheetId, "RenamedSpreadsheet");
```

* Get All Spreadsheets
```ballerina
    stream<sheets:File>|error response = spreadsheetClient->getAllSpreadsheets();
```

* Add Worksheet
```ballerina
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
```

* Rename Worksheet 
```ballerina
    error? spreadsheetRes = spreadsheetClient->renameSheet(spreadsheetId, sheetName, "RenamedWorksheet");
```

* Remove Worksheet by Worksheet ID
```ballerina
    error? spreadsheetRes = spreadsheetClient->removeSheet(spreadsheetId, sheetId);
```

* Remove Worksheet by Worksheet Name
```ballerina
    error? spreadsheetRes = spreadsheetClient->removeSheetByName(spreadsheetId, sheetName);
```

* Get All Worksheets
```ballerina
    sheets:Sheet[]|error sheetsRes = spreadsheetClient->getSheets(spreadsheetId);
```

* Get, Set and Clear Range
```ballerina
    error? spreadsheetRes = spreadsheetClient->setRange(spreadsheetId, sheetName, range);
    sheets:Range|error getValuesResult = spreadsheetClient->getRange(spreadsheetId, sheetName, a1Notation);
    error? clear = spreadsheetClient->clearRange(spreadsheetId, sheetName, a1Notation);
```

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/gsheet/samples)**

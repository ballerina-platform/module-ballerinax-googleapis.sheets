## Overview

Ballerina connector for Google Sheets provides access to the Google Sheets via Ballerina language to implement some of the most common use cases of Google Sheets. The connector provides the capability to programmatically manage spreadsheets, manage worksheets, do CRUD operations on worksheets, and do column wise, row wise and cell wise operations through the connector endpoints. It provides the capability to perform spreadsheet management operations, worksheet management operations and the capability to handle data level operations.

This module supports [Google Sheets API](https://developers.google.com/sheets/api) v4 version.

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

- Create [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
- Obtain Tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart

To use the Google Sheets connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
First, import the `ballerinax/googleapis.sheets` module into the Ballerina project.
```ballerina
    import ballerinax/googleapis.sheets as sheets;
```

### Step 2: Create a new connector instance
Create a `sheets:SpreadsheetConfiguration` with the OAuth2 tokens obtained, and initialize the connector with it. 
```ballerina
    sheets:SpreadsheetConfiguration spreadsheetConfig = {
        oauthClientConfig: {
            clientId: <CLIENT_ID>,
            clientSecret: <CLIENT_SECRET>,
            refreshUrl: sheets:REFRESH_URL,
            refreshToken: <REFRESH_TOKEN>
        }
    };

    sheets:Client spreadsheetClient = check new (spreadsheetConfig);
```
**Note:** Must specify the **Refresh token** (obtained by exchanging the authorization code), **Refresh URL**, the **Client ID** and the **Client secret** obtained in the app creation, when configuring the Google Sheets connector client.

### Step 3: Invoke connector operation
1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.

    Following is an example on how to create a spreadsheet using the connector.

    Create Spreadsheet with given name

    ```ballerina
        public function main() returns error? {
            sheets:Spreadsheet response = check spreadsheetClient->createSpreadsheet("NewSpreadsheet");
            log:printInfo("Successfully created spreadsheet!");
        }
    ```

2. Use `bal run` command to compile and run the Ballerina program. 

## Quick reference
Code snippets of some frequently used functions: 

**Note:** Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <SPREADSHEET_ID> + "/edit#gid=" + <WORKSHEET_ID>.

* Create Spreadsheet with given name
```ballerina
    sheets:Spreadsheet spreadsheet = check spreadsheetClient->createSpreadsheet("NewSpreadsheet");
```

* Add a New Worksheet with given name
```ballerina
    sheets:Sheet sheet = check spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
```

* Open Spreadsheet by Spreadsheet ID
```ballerina
    sheets:Spreadsheet spreadsheet = check spreadsheetClient->openSpreadsheetById(spreadsheetId);
```

* Open Spreadsheet by Spreadsheet URL
```ballerina
    sheets:Spreadsheet spreadsheet = check spreadsheetClient->openSpreadsheetByUrl(url);
```

* Rename Spreadsheet
```ballerina
    check spreadsheetClient->renameSpreadsheet(spreadsheetId, "RenamedSpreadsheet");
```

* Get All Spreadsheets
```ballerina
    stream<sheets:File> spreadsheets = check spreadsheetClient->getAllSpreadsheets();
```

* Add Worksheet
```ballerina
    sheets:Sheet sheet = check spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
```

* Rename Worksheet 
```ballerina
    check spreadsheetClient->renameSheet(spreadsheetId, sheetName, "RenamedWorksheet");
```

* Remove Worksheet by Worksheet ID
```ballerina
    check spreadsheetClient->removeSheet(spreadsheetId, sheetId);
```

* Remove Worksheet by Worksheet Name
```ballerina
    check spreadsheetClient->removeSheetByName(spreadsheetId, sheetName);
```

* Get All Worksheets
```ballerina
    sheets:Sheet[] sheets = check spreadsheetClient->getSheets(spreadsheetId);
```

* Get, Set and Clear Range
```ballerina
    check spreadsheetClient->setRange(spreadsheetId, sheetName, range);
    sheets:Range range = check spreadsheetClient->getRange(spreadsheetId, sheetName, a1Notation);
    check spreadsheetClient->clearRange(spreadsheetId, sheetName, a1Notation);
```

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/gsheet/samples)**

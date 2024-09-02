## Overview

The [Ballerina](https://ballerina.io/) connector for Google Sheets makes it convenient to implement some of the most common use cases of Google Sheets. With this connector, you can programmatically manage spreadsheets, manage worksheets, perform CRUD operations on worksheets, and perform column-level, row-level, and cell-level operations.

This module supports [Google Sheets API v4](https://developers.google.com/sheets/api).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

- Create a [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
- Obtain tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart

To use the Google Sheets connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector

Import the `ballerinax/googleapis.sheets` module into the Ballerina project.

```ballerina
    import ballerinax/googleapis.sheets as sheets;
```

### Step 2: Create a new connector instance

Create a `sheets:ConnectionConfig` with the OAuth2 tokens obtained, and initialize the connector with it.
```ballerina
    sheets:ConnectionConfig spreadsheetConfig = {
        auth: {
            clientId: <CLIENT_ID>,
            clientSecret: <CLIENT_SECRET>,
            refreshUrl: sheets:REFRESH_URL,
            refreshToken: <REFRESH_TOKEN>
        }
    };

    sheets:Client spreadsheetClient = check new (spreadsheetConfig);
```

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

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/2201.8.x/examples)**

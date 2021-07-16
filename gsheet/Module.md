## Overview

Google Spreadsheet Ballerina Connector is used to connect with the Google Spreadsheet via Ballerina language easily to implement some of the most common use cases of Google Spreadsheets. The connector provides the capability to programmatically manage spreadsheets, manage worksheets, do CRUD operations on worksheets, and do column wise, row wise and cell wise operations through the connector endpoints.

This module supports spreadsheet management operations like creating a spreadsheet, opening a spreadsheet, listing all the spreadsheets available in a user account, renaming a spreadsheet. It also supports worksheet management operations like getting all the worksheets available in a spreadsheet, opening a worksheet, adding a new worksheet, removing a worksheet and renaming a worksheet. The connector also provides capabilities to handle data level operations like setting, getting and clearing a range of data, inserting columns/rows before and after a given position, creating or updating, getting and deleting columns/rows, setting, getting and clearing cell data, appending a row to a sheet, appending a row to a range of data, appending a cell to a range of data, copying a worksheet to a destination spreadsheet, and clearing worksheets.

This module supports [Google Spreadsheet API Version v4](https://developers.google.com/sheets/api).

## Configuring Connector

### Prerequisites

- Google account

### Obtaining Tokens

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. [Enable Google Sheets API in your app's Cloud Platform project.](https://developers.google.com/workspace/guides/create-project#enable-api)
7. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground). 
8. Click the gear icon in the upper right corner and check the box labeled **Use your own OAuth credentials** (if it isn't already checked) and enter the OAuth2 client ID and OAuth2 client secret you obtained above.
9. Select the required Google Spreadsheet scopes, and then click **Authorize APIs**.
10. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the access token and refresh token.

* Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for Bearer Token Authentication and OAuth 2.0. Google Spreadsheet uses OAuth 2.0 to authenticate and authorize requests. It uses the Direct Token Grant Type. The Google Spreadsheet connector can be minimally instantiated in the HTTP client config using the OAuth 2.0 access token.
    * Access Token 
    ``` 
    sheets:SpreadsheetConfiguration spreadsheetConfig = {
        oauthClientConfig: {
            token: <ACCESS_TOKEN>
        }
    }
    ```

    The Google Spreadsheet connector can also be instantiated in the HTTP client config without the access token using the client ID, client secret, and refresh token.
    * Client ID
    * Client Secret
    * Refresh Token
    * Refresh URL
    ```
    sheets:SpreadsheetConfiguration spreadsheetConfig = {
        oauthClientConfig: {
            clientId: <CLIENT_ID>,
            clientSecret: <CLIENT_SECRET>,
            refreshToken: <REFRESH_TOKEN>,
            refreshUrl: <sheets:REFRESH_URL>
        }
    }
    ```

## Quickstart(s)

### Working with GSheets Endpoint Actions

#### Step 1: Import the Google Sheets Ballerina Library
First, import the ballerinax/googleapis.sheets module into the Ballerina project.
```ballerina
    import ballerinax/googleapis.sheets as sheets;
```
All the actions return valid response or error. If the action is a success, then the requested resource will be returned. Else error will be returned.

#### Step 2: Initialize the Google Sheets Client
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

Then the endpoint actions can be invoked as `var response = spreadsheetClient->actionName(arguments)`.

#### Step 3: Initialize the Google Sheets Client with default truststore
```ballerina
import ballerina/io;
import ballerinax/googleapis.sheets as sheets;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: "<CLIENT_ID>",
        clientSecret: "<CLIENT_SECRET>",
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: "<REFRESH_TOKEN>"
    }
};

sheets:Client spreadsheetClient = check new (spreadsheetConfig);

public function main(string... args) {
    var response = spreadsheetClient->openSpreadsheetById(<spreadsheet-id>);
    if (response is sheets:Spreadsheet) {
        io:println("Spreadsheet Details: ", response);
    } else {
        io:println("Error: ", response);
    }
}
```

#### Step 4: Initialize the Google Sheets Client with custom truststore
```ballerina
import ballerina/io;
import ballerinax/googleapis.sheets as sheets;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: "<CLIENT_ID>",
        clientSecret: "<CLIENT_SECRET>",
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: "<REFRESH_TOKEN>"
    },
    secureSocketConfig: {
        trustStore: {
            path: "<fullQualifiedPathToTrustStore>",
            password: "<truststorePassword>"
        }
    }
};

sheets:Client spreadsheetClient = check new (spreadsheetConfig);

public function main(string... args) {
    var response = spreadsheetClient->openSpreadsheetById(<spreadsheet-id>);
    if (response is sheets:Spreadsheet) {
        io:println("Spreadsheet Details: ", response);
    } else {
        io:println("Error: ", response);
    }
}
```

## Snippets
Snippets of some operations.

> **Note:** Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <SPREADSHEET_ID> + "/edit#gid=" + <WORKSHEET_ID>.

### Create Spreadsheet with given name
```ballerina
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("NewSpreadsheet");
```

### Add a New Worksheet with given name
```ballerina
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
```

### Open Spreadsheet by Spreadsheet ID
```ballerina
    sheets:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetById(spreadsheetId);
```

### Open Spreadsheet by Spreadsheet URL
```ballerina
    sheets:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetByUrl(url);
```

### Rename Spreadsheet
```ballerina
    error? rename = spreadsheetClient->renameSpreadsheet(spreadsheetId, "RenamedSpreadsheet");
```

### Get All Spreadsheets
```ballerina
    stream<sheets:File>|error response = spreadsheetClient->getAllSpreadsheets();
```

### Add Worksheet
```ballerina
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
```

### Rename Worksheet 
```ballerina
    error? spreadsheetRes = spreadsheetClient->renameSheet(spreadsheetId, sheetName, "RenamedWorksheet");
```

### Remove Worksheet by Worksheet ID
```ballerina
    error? spreadsheetRes = spreadsheetClient->removeSheet(spreadsheetId, sheetId);
```

### Remove Worksheet by Worksheet Name
```ballerina
    error? spreadsheetRes = spreadsheetClient->removeSheetByName(spreadsheetId, sheetName);
```

### Get All Worksheets
```ballerina
    sheets:Sheet[]|error sheetsRes = spreadsheetClient->getSheets(spreadsheetId);
```

### Get, Set and Clear Range
```ballerina
    error? spreadsheetRes = spreadsheetClient->setRange(spreadsheetId, sheetName, range);
    sheets:Range|error getValuesResult = spreadsheetClient->getRange(spreadsheetId, sheetName, a1Notation);
    error? clear = spreadsheetClient->clearRange(spreadsheetId, sheetName, a1Notation);
```

### [You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/gsheet/samples)

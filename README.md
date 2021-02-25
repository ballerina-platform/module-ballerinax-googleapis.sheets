# Ballerina Google Sheets Module

Connects to Google Sheets using Ballerina.

# Module Overview

The Google Spreadsheet Ballerina Connector allows you to access the [Google Spreadsheet API Version v4](https://developers.google.com/sheets/api) through Ballerina. The connector can be used to implement some of the most common use cases of Google Spreadsheets. The connector provides the capability to programmatically manage spreadsheets, manage worksheets, do CRUD operations on worksheets, and do column wise, row wise and cell wise operations through the connector endpoints.

The Google Spreadsheet Ballerina Connector supports spreadsheet management operations like creating a spreadsheet, opening a spreadsheet, listing all the spreadsheets available in a user account, renaming a spreadsheet. It also supports worksheet management operations like getting all the worksheets available in a spreadsheet, opening a worksheet, adding a new worksheet, removing a worksheet and renaming a worksheet. The connector also provides capabilities to handle data level operations like setting, getting and clearing a range of data, inserting columns/rows before and after a given position, creating or updating, getting and deleting columns/rows, setting, getting and clearing cell data, appending a row to a sheet, appending a row to a range of data, appending a cell to a range of data, copying a worksheet to a destination spreadsheet, and clearing worksheets.

# Supported Operations

## Spreadsheet Management Operations
The `ballerinax/googleapis_sheets` module contains operations related to accessing the Google sheets API to perform 
spreadsheet management operations. It includes operations like creating a spreadsheet, opening a spreadsheet, listing all the spreadsheets available in a user account, renaming a spreadsheet.

## Worksheet Management Operations
The `ballerinax/googleapis_sheets` module contains operations related to accessing the Google sheets API to perform 
worksheet management operations. It includes operations like getting all the worksheets available in a spreadsheet, opening a worksheet, adding a new worksheet, removing a worksheet and renaming a worksheet.


## Worksheet Service Operations
The `ballerinax/googleapis_sheets` module contains operations related to accessing the Google sheets API to perform 
worksheet data level operations. It includes operations like setting, getting and clearing a range of data, inserting columns/rows before and after a given position, creating or updating, getting and deleting columns/rows, setting, getting and clearing cell data, appending a row to a sheet, appending a row to a range of data, appending a cell to a range of data, copying a worksheet to a destination spreadsheet, and clearing worksheets.

# Prerequisites:

* Java 11 Installed
Java Development Kit (JDK) with version 11 is required.

* Download the Ballerina [distribution](https://ballerinalang.org/downloads/)
Ballerina Swan Lake Alpha 2 is required.

* Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for BasicAuth and OAuth 2.0. Google Spreadsheet uses OAuth 2.0 to authenticate and authorize requests. The Google Spreadsheet connector can be minimally instantiated in the HTTP client config using the client ID, client secret, and refresh token.
    * Client ID
    * Client Secret
    * Refresh Token
    * Refresh URL

## Obtaining Tokens

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google Spreadsheet scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token.

## Add project configurations file
Add the project configuration file by creating a `Config.toml` file under the root path of the project structure.
This file should have following configurations. Add the token obtained in the previous step to the `Config.toml` file.

```
[ballerinax.googleapis_sheets]
refreshToken = "enter your refresh token here"
clientId = "enter your client id here"
clientSecret = "enter your client secret here"
trustStorePath = "enter a truststore path if required"
trustStorePassword = "enter a truststore password if required"

```

# Quickstart(s):

## Working with GSheets Endpoint Actions

### Step 1: Import the Google Sheets Ballerina Library
First, import the ballerinax/googleapis_sheets module into the Ballerina project.
```ballerina
    import ballerinax/googleapis_sheets as sheets;
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

sheets:Client spreadsheetClient = checkpanic new (spreadsheetConfig);
```
Then the endpoint actions can be invoked as `var response = spreadsheetClient->actionName(arguments)`.

### Step 3: Initialize the Google Sheets Client with default truststore
```ballerina
import ballerina/io;
import ballerinax/googleapis_sheets as sheets;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: "<CLIENT_ID>",
        clientSecret: "<CLIENT_SECRET>",
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: "<REFRESH_TOKEN>"
    }
};

sheets:Client spreadsheetClient = checkpanic new (spreadsheetConfig);

public function main(string... args) {
    var response = spreadsheetClient->openSpreadsheetById(<spreadsheet-id>);
    if (response is sheets:Spreadsheet) {
        io:println("Spreadsheet Details: ", response);
    } else {
        io:println("Error: ", response);
    }
}
```

### Step 4: Initialize the Google Sheets Client with custom truststore
```ballerina
import ballerina/io;
import ballerinax/googleapis_sheets as sheets;

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

sheets:Client spreadsheetClient = checkpanic new (spreadsheetConfig);

public function main(string... args) {
    var response = spreadsheetClient->openSpreadsheetById(<spreadsheet-id>);
    if (response is sheets:Spreadsheet) {
        io:println("Spreadsheet Details: ", response);
    } else {
        io:println("Error: ", response);
    }
}
```

# Samples

### Create Spreadsheet with given name
We must specify the spreadsheet name as a string parameter to the createSpreadsheet remote operation. This is the basic scenario of creating a new spreadsheet with the name “NewSpreadsheet”. It returns a Spreadsheet record type with all the information related to the spreadsheet created on success and a ballerina error if the operation is unsuccessful.
```ballerina
    string spreadsheetId = "";
    string sheetName = "";
    
    // Create Spreadsheet with given name
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("NewSpreadsheet");
    if (response is sheets:Spreadsheet) {
        log:print("Spreadsheet Details: " + response.toString());
        spreadsheetId = response.spreadsheetId;
    } else {
        log:printError("Error: " + response.toString());
    }
```

### Add a New Worksheet with given name
We must specify the spreadsheet ID and the name for the new worksheet as string parameters to the addSheet remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of adding a new worksheet  with the name “NewWorksheet” by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns a Sheet record type with all the information related to the worksheet added on success and a ballerina error if the operation is unsuccessful.
```ballerina
    // Add a New Worksheet with given name to the Spreadsheet with the given Spreadsheet ID
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
    if (sheet is sheets:Sheet) {
        log:print("Sheet Details: " + sheet.toString());
        sheetName = sheet.properties.title;
    } else {
        log:printError("Error: " + sheet.toString());
    }
```

Connects to Google Spreadsheets from Ballerina.

# Module Overview

The Google Spreadsheet connector allows you to create and access Google Spreadsheet docs through the Google Spreadsheet REST API. It also allows you to create, access, modify, and delete worksheets. It handles OAuth 2.0 authentication.

**Spreadsheet Operations**

The `ballerinax/googleapis.sheets4` module allows you to perform following operations.

- Create a new spreadsheet
- Create a new worksheet
- View a spreadsheet
- Add values into a given range in the worksheet
- Retrieving range of values from a worksheet
- Retrieving values of a column 
- Retrieving values of a row
- Adding value into a cell
- Retrieving value of a cell

## Compatibility

|                             |       Versions              |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |     Swan Lake Preview7      |
| Google Spreadsheet API      |             V4              |

## Sample

Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for BasicAuth and OAuth 2.0. Google Spreadsheet uses OAuth 2.0 to authenticate and authorize requests. The Google Spreadsheet connector can be minimally instantiated in the HTTP client config using the access token or the client ID, client secret, and refresh token.

**Obtaining Tokens to Run the Sample**

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the 
access token and refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google Spreadsheet scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token and access token. 

**Add project configurations file**

Add the project configuration file by creating a `ballerina.conf` file under the root path of the project structure.
This file should have following configurations. Add the tokens obtained in the previous step to the `ballerina.conf` file.

```
ACCESS_TOKEN = "<access_token>"
CLIENT_ID = "<client_id">
CLIENT_SECRET = "<client_secret>"
REFRESH_TOKEN = "<refresh_token>"
REFRESH_URL = "<refresh_URL>"
```

**Example Code**

Creating a sheets4:Client by giving the HTTP client config details. 
```ballerina
    import ballerina/config;   
    import ballerinax/googleapis.sheets4;
   
    sheets4:SpreadsheetConfiguration spreadsheetConfig = {
        oauth2Config: {
            accessToken: config:getAsString("ACCESS_TOKEN"),
            refreshConfig: {
                clientId: config:getAsString("CLIENT_ID"),
                clientSecret: config:getAsString("CLIENT_SECRET"),
                refreshUrl: config:getAsString("REFRESH_URL"),
                refreshToken: config:getAsString("REFRESH_TOKEN")
            }
        }
    };
   
    sheets4:Client spreadsheetClient = new (spreadsheetConfig);
```

Creating a new spreadsheet
```ballerina
    sheets4:Spreadsheet|error spreadsheet = spreadsheetClient->createSpreadsheet(<spreadsheet-name>);
```

Opening an existing spreadsheet 
```ballerina
    sheets4:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetById(<spreadsheetId>);
```

Adding values to a given range and retrieving values from a range
```ballerina
    string a1Notation = "A1:D5";
    string[][] entries = [
        ["Name", "Score", "Performance", "Average"],
        ["Keetz", "12"],
        ["Niro", "78"],
        ["Nisha", "98"],
        ["Kana", "86"]
    ];
    sheets4:Sheet|error sheet = spreadsheet.getSheetByName(<worksheet-name>);
    if (sheet is sheets4:Sheet) {
        Range range = {a1Notation: a1Notation, values: entries};
        error? setValuesResult = sheet->setRange(<@untainted>range);
        sheets4:Range|error getValuesResult = sheet->getRange(a1Notation);
    } 
```

Adding values to a cell and retrieving values from a cell
```ballerina
    sheets4:Sheet|error sheet = spreadsheet.getSheetByName(<worksheet-name>);
    if (sheet is sheets4:Sheet) {
        error? setValueResult = sheet->setCell("A10", "Foo");
        int|string|float|error getValueResult = sheet->getCell("A10");
    }
```

Retrieving values from a column
```ballerina
    sheets4:Sheet|error sheet = spreadsheet.getSheetByName(<worksheet-name>);
    if (sheet is sheets4:Sheet) {
        (string|int|float)[]|error getValueResult = sheet->getColumn("C");
    }
```

Retrieving values from a row
```ballerina
    sheets4:Sheet|error sheet = spreadsheet.getSheetByName(<worksheet-name>);
    if (sheet is sheets4:Sheet) {
        (string|int|float)[]|error getValueResult = sheet->getRow(3);
    }
```

Appending values to a sheet
```ballerina
    string[] values = ["Appending", "Some", "Values"];
    sheets4:Sheet|error sheet = spreadsheet.getSheetByName(<worksheet-name>);
    if (sheet is sheets4:Sheet) {
        error? appendResult = sheet->appendRow(values);
    }
```


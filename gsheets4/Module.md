Connects to Google Spreadsheets from Ballerina.

# Module Overview

The Google Spreadsheet connector allows you to create and access Google Spreadsheet docs through the Google Spreadsheet REST API. It also allows you to create, access, modify, and delete worksheets. It handles OAuth 2.0 authentication.

**Spreadsheet Operations**

The `wso2/gsheets4` module contains operations that create or retrieve a spreadsheet and retrieve spreadsheet properties such as spreadsheet name, spreadsheet ID, and sheets of a spreadsheet. It also allows you to retrieve a sheet with the given name.

**Sheet Operations**

The `wso2/gsheets4` module contains operations to set and get the sheet values of a range or a cell. It can also get row or column data.

## Compatibility

|                             |       Version               |
|:---------------------------:|:---------------------------:|
| Ballerina Language          | 0.983.0                     |
| Google Spreadsheet API      | V4                          |

## Sample

First, import the `wso2/gsheets4` module into the Ballerina project.

```ballerina
import wso2/gsheets4;
```

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

You can now enter the credentials in the HTTP client config:
```ballerina
endpoint gsheets4:Client spreadsheetEP {
    clientConfig:{
        auth:{
            accessToken:accessToken,
            clientId:clientId,
            clientSecret:clientSecret,
            refreshToken:refreshToken
        }
    }
};
```

The `openSpreadsheetById` function retrieves the spreadsheet whose ID is specified in `spreadsheetId`.
```ballerina
//Open a spreadsheet.
var response = spreadsheetEP->openSpreadsheetById(spreadsheetId);
```

The response from `openSpreadsheetById` is a `Spreadsheet` object if the request was successful or a `SpreadsheetError` on failure. The `match` operation can be used to handle the response if an error occurs.
```ballerina
match response {
   //If successful, returns the Spreadsheet object.
   gsheets4:Spreadsheet spreadsheetRes => io:println(spreadsheetRes);
   //Unsuccessful attempts return a SpreadsheetError.
   gsheets4:SpreadsheetError err => io:println(err);
}
```

The `getSheetByName` function retrieves a sheet with the given name from a `Spreadsheet` object. The `sheetName` represents the name of the sheet to be retrieved. It returns the `Sheet` object on success and `SpreadsheetError` on failure.
```ballerina
var response = spreadsheet.getSheetByName(sheetName);
match response {
    gsheets4:Sheet sheet => io:println(sheet);
    gsheets4:SpreadsheetError err => io:println(err);
}
```

The `setSheetValues` function sets the values for a range of cells. It returns `true` on success or `SpreadsheetError` on failure.
```ballerina
var response = spreadsheetEP->setSheetValues(spreadsheetId, sheetName, topLeftCell, bottomRightCell, values);
match response {
    boolean isUpdated => io:println(isUpdated);
    gsheets4:SpreadsheetError err => io:println(err);
}
```

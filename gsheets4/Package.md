#  Google Spreadsheet Connector

Connects to Google Spreadsheets from Ballerina.

This package provides a Ballerina API for the Google Spreadsheet REST API. It provides the ability to create, modify, or access Google Spreadsheet docs. It handles OAuth 2.0 and provides auto completion and type conversions.

**Spreadsheet Operations**

The wso2/gsheets4 package contains operations that create or retrieve a spreadsheet and retrieve spreadsheet properties such as spreadsheet name, spreadsheet ID, and sheets of a spreadsheet. It also allows you to retrieve a sheet with the given name.

**Sheet Operations**

The wso2/gsheets4 package contains operations to set and get the sheet values of a range or a cell. It can also get row or column data.

## Compatibility

|                                 |       Version                  |
| :-----------------------------: | :-----------------------------:|
|  Ballerina Language Version     |   0.970.0-beta12               |
|  Google Spreadsheet API Version |   V4                           |

## Sample

The Google Spreadsheet connector can be used to create or read a spreadsheet and set the sheet values. First, import the `wso2/gsheets4` package into the Ballerina project.

```ballerina
    import wso2/gsheets4;
```

Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for BasicAuth and OAuth 2.0. Google Spreadsheet uses OAuth 2.0 to authenticate and authorize requests. The Google Spreadsheet connector can be minimally instantiated in the HTTP client config using the access token or the client ID, client secret, and refresh token.

**Obtaining Tokens to Run the Sample**

1. Visit [Google API Console](https://console.developers.google.com). Continue through the wizard, configure the OAuth consent screen under **Credentials**, and give a product name to be shown to users.
2. Create OAuth client ID credentials by selecting an application type and giving a name and a redirect URI. Give the redirect URI as https://developers.google.com/oauthplayground if you are using [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the access token and refresh token.
3. Visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground) and select the required Google Spreadsheet API scopes.
4. Provide the client ID and client secret to obtain the refresh token and access token.

You can now enter the credentials in the HTTP client config:
```ballerina
    endpoint gmail:Client spreadsheetEP {
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

The `openSpreadsheetById` function retrieves the spreadsheet whose ID is specified in spreadsheetId.
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

The `getSheetByName` function retrieves a sheet with the given name from a `Spreadsheet` object. The sheetName represents the name of the sheet to be retrieved. It returns the `Sheet` object on success and `SpreadsheetError` on failure.
```ballerina
    var sheetRes = spreadsheet.getSheetByName(sheetName);
    match sheetRes {
        gsheets4:Sheet s => io:println(s);
        SpreadsheetError e => io:println(e);
    }
```

The `setSheetValues` function sets the values for a range of cells. It returns `true` on success or `SpreadsheetError` on failure.
```ballerina
    var spreadsheetRes = spreadsheetEP->setSheetValues(spreadsheetId, sheetName, topLeftCell, bottomRightCell, values);
    match spreadsheetRes {
        boolean isUpdated => io:println(isUpdated);
        gsheets4:SpreadsheetError e => io:println(e);
    }
```

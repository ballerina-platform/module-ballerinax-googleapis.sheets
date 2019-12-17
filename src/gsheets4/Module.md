Connects to Google Spreadsheets from Ballerina.

# Module Overview

The Google Spreadsheet connector allows you to create and access Google Spreadsheet docs through the Google Spreadsheet REST API. It also allows you to create, access, modify, and delete worksheets. It handles OAuth 2.0 authentication.

**Spreadsheet Operations**

The `wso2/gsheets4` module allows you to perform following operations.

- Create a new spreadsheet
- Create a new worksheet
- View a spreadsheet
- Add values into a worksheet
- Get values from worksheet
- Retrieving values of a column
- Retrieving values of a row
- Adding value into a cell
- Retrieving value of a cell
- Retrieving value of a cell

## Compatibility

|                             |       Version               |
|:---------------------------:|:---------------------------:|
| Ballerina Language          | 1.0.1                     |
| Google Spreadsheet API      | V4                          |

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
ACCESS_TOKEN = "<Acces_token>"
CLIENT_ID = "<Client_id">
CLIENT_SECRET = "<Client_secret>"
REFRESH_TOKEN = "<Refresh_token>"
REFRESH_URL = "<Refresh_URL>"
LISTENER_PORT = 9090
BASE_PATH = "/spreadsheets"
```

**Implementation**

``` ballerina
import ballerina/config;
import ballerina/io;
import ballerina/http;
import ballerina/log;

import wso2/gsheets4;

// Constants for error codes and messages.
const string RESPOND_ERROR_MSG = "Error occurred while responding to client.";
const string INVALID_PAYLOAD_MSG = "Invalid request payload.";
const string SPREADSHEET_CREATION_ERROR_MSG = "Error while creating creating the spreadsheet.";
const string WORKSHEET_CREATION_ERROR_MSG = "Error while creating the worksheet.";
const string SPREADSHEET_RETRIEVAL_ERROR_MSG = "Error while retrieving the spreadsheet information.";
const string PAYLOAD_EXTRACTION_ERROR_MSG = "Error while extracting the payload from request.";
const string ENTRY_ADDITION_ERROR_MSG = "Error while adding the entries to the worksheet.";
const string WORKSHEET_RETRIEVAL_ERROR_MSG = "Error while retrieving the entries in the worksheet.";
const string COLUMN_DATA_RETRIEVAL_ERROR_MSG = "Error while retrieving the values in the column.";
const string ROW_DATA_RETRIEVAL_ERROR_MSG = "Error while retrieving the values in the row.";
const string CELL_DATA_ADDITION_ERROR_MSG = "Error while adding the value to the cell.";
const string CELL_DATA_RETRIEVAL_ERROR_MSG = "Error while retrieving the value of the cell.";
const string WORKSHEET_DELETION_ERROR_MSG = "Error while deleting the worksheet.";

gsheets4:SpreadsheetConfiguration spreadsheetConfig = {
    oAuthClientConfig: {
        accessToken: config:getAsString("ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshUrl: config:getAsString("REFRESH_URL"),
            refreshToken: config:getAsString("REFRESH_TOKEN")
        }
    }
};

gsheets4:Client spreadsheetClient = new(spreadsheetConfig);

@http:ServiceConfig {
    basePath: config:getAsString("BASE_PATH")
}
service spreadsheetService on new http:Listener(config:getAsInt("LISTENER_PORT")) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/{spreadsheetName}"
    }
    // Function to create a new spreadsheet.
    resource function createSpreadsheet(http:Caller caller, http:Request request, string spreadsheetName) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke createSpreadsheet remote function from spreadsheetClient.
        var response = spreadsheetClient->createSpreadsheet(<@untainted> spreadsheetName);
        if (response is gsheets4:Spreadsheet) {
            // If there is no error, send the success response.
            backendResponse.statusCode = http:STATUS_CREATED;
            backendResponse.setJsonPayload(<@untainted> convertSpreadsheetToJSON(response),
                                           contentType = "application/json");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        } else {
            // Send the error response.
            createAndSendErrorResponse(caller, <@untainted> <string>response.detail()?.message,
                            SPREADSHEET_CREATION_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/{spreadsheetId}/{worksheetName}"
    }
    // Function to add new worksheet.
    resource function addNewSheet(http:Caller caller, http:Request request, string spreadsheetId,
                                 string worksheetName) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke addNewSheet remote function from spreadsheetClient.
        var response = spreadsheetClient->addNewSheet(<@untainted> spreadsheetId, <@untainted> worksheetName);
        if (response is gsheets4:Sheet) {
            // If there is no error, send the success response.
            backendResponse.statusCode = http:STATUS_CREATED;
            backendResponse.setJsonPayload(<@untainted> convertSheetPropertiesToJSON(response.properties),
                                           contentType = "application/json");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        } else {
            // Send the error response.
            createAndSendErrorResponse(caller, <@untainted> <string>response.detail()?.message,
                            WORKSHEET_CREATION_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{spreadsheetId}"
    }
    // Function to open spreadsheet.
    resource function openSpreadsheetById(http:Caller caller, http:Request request, string spreadsheetId) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke openSpreadsheetById remote function from spreadsheetClient.
        var response = spreadsheetClient->openSpreadsheetById(<@untainted> spreadsheetId);
        if (response is gsheets4:Spreadsheet) {
            // If there is no error, send the success response.
            backendResponse.statusCode = http:STATUS_OK;
            backendResponse.setJsonPayload(<@untainted> convertSpreadsheetToJSON(response),
                                           contentType = "application/json");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        } else {
            // Send the error response.
            createAndSendErrorResponse(caller, <@untainted> <string>response.detail()?.message,
                            SPREADSHEET_RETRIEVAL_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/{spreadsheetId}/{worksheetName}/{topLeftCell}/{bottomRightCell}"
    }
    // Function to add entries into an existing worksheet.
    resource function setSheetValues(http:Caller caller, http:Request request, string spreadsheetId,
                                     string worksheetName, string topLeftCell, string bottomRightCell) {
        // Define new response.
        http:Response backendResponse = new();
        // Extract the object content from request payload.
        string|string[][]|error entries = extractRequestContent(request);
        if (entries is string[][]) {
            // Invoke setSheetValues remote function from spreadsheetClient.
            var response = spreadsheetClient->setSheetValues(<@untainted> spreadsheetId, <@untainted> worksheetName,
                                                             <@untainted> entries, <@untainted> topLeftCell,
                                                             <@untainted> bottomRightCell);
            if (response == true) {
                // If the response is the boolean value 'true', send the success response.
                string payload = "The entries have been added into the worksheet " + worksheetName;
                backendResponse.statusCode = http:STATUS_CREATED;
                backendResponse.setTextPayload(payload, contentType = "text/plain");
                respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
            } else {
                // Else, send the failure response.
                string payload = "Unable to add the entries into the worksheet " + worksheetName;
                backendResponse.statusCode = http:STATUS_BAD_REQUEST;
                backendResponse.setTextPayload(payload, contentType = "text/plain");
                respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
            }
        } else {
            // Send the error response.
            createAndSendErrorResponse(caller, "Invalid content. String payload is expected by this method.",
                            INVALID_PAYLOAD_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/worksheet/{spreadsheetId}/{worksheetName}/{topLeftCell}/{bottomRightCell}"
    }
    // Function to retrieve worksheet entries.
    resource function getSheetValues(http:Caller caller, http:Request request, string spreadsheetId,
                                     string worksheetName, string topLeftCell, string bottomRightCell) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke getSheetValues remote function from spreadsheetClient.
        var response = spreadsheetClient->getSheetValues(<@untainted> spreadsheetId, <@untainted> worksheetName,
                                                         <@untainted> topLeftCell, <@untainted> bottomRightCell);
        if (response is error) {
            // Send the error response.
            createAndSendErrorResponse(caller, <@untainted> <string>response.detail()?.message,
                            WORKSHEET_RETRIEVAL_ERROR_MSG);
        } else {
            // If there is no error, send the success response.
            backendResponse.statusCode = http:STATUS_OK;
            backendResponse.setJsonPayload(<@untainted> response, contentType = "application/json");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "column/{spreadsheetId}/{worksheetName}/{column}"
    }
    // Function to retrieve values in a column.
    resource function getColumnData(http:Caller caller, http:Request request, string spreadsheetId,
                                    string worksheetName, string column) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke getColumnData remote function from spreadsheetClient.
        var response = spreadsheetClient->getColumnData(<@untainted> spreadsheetId, <@untainted> worksheetName,
                                                        <@untainted> column);
        if (response is error) {
            // Send the error response.
            createAndSendErrorResponse(caller, <@untainted> <string>response.detail()?.message,
                            COLUMN_DATA_RETRIEVAL_ERROR_MSG);
        } else {
            // If there is no error, send the success response.
            backendResponse.statusCode = http:STATUS_OK;
            backendResponse.setJsonPayload(<@untainted> response, contentType = "application/json");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/row/{spreadsheetId}/{worksheetName}/{row}"
    }
    // Function to retrieve values in a row.
    resource function getRowData(http:Caller caller, http:Request request, string spreadsheetId, string worksheetName,
                                 int row) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke getRowData remote function from spreadsheetClient.
        var response = spreadsheetClient->getRowData(<@untainted> spreadsheetId, <@untainted> worksheetName,
                                                     <@untainted> row);
        if (response is error) {
            // Send the error response.
            createAndSendErrorResponse(caller, <@untainted> <string>response.detail()?.message,
                            ROW_DATA_RETRIEVAL_ERROR_MSG);
        } else {
            // If there is no error, send the success response.
            backendResponse.statusCode = http:STATUS_OK;
            backendResponse.setJsonPayload(<@untainted> response, contentType = "application/json");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/cell/{spreadsheetId}/{worksheetName}/{column}/{row}"
    }
    // Function to enter value into a cell.
    resource function setCellData(http:Caller caller, http:Request request, string spreadsheetId, string worksheetName,
                                  string column, int row) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke setCellData remote function from spreadsheetClient.
        string|string[][]|error cellValue = extractRequestContent(request);
        if (cellValue is string) {
        var response = spreadsheetClient->setCellData(<@untainted> spreadsheetId, <@untainted> worksheetName,
                                                      <@untainted> column, <@untainted> row, <@untainted> cellValue);
        if (response == true) {
            // If the response is the boolean value 'true', send the success response.
            string payload = "The cell data has been added into the worksheet " + worksheetName;
            backendResponse.statusCode = http:STATUS_CREATED;
            backendResponse.setTextPayload(payload, contentType = "text/plain");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        } else {
            // Else, send the failure response.
            string payload = "Unable to enter the value into the cell in the worksheet" + worksheetName;
            backendResponse.statusCode = http:STATUS_BAD_REQUEST;
            backendResponse.setTextPayload(payload, contentType = "text/plain");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        }
        } else {
            // Send the error response.
            createAndSendErrorResponse(caller, "Invalid content. String payload is expected by this method.",
                            INVALID_PAYLOAD_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/cell/{spreadsheetId}/{worksheetName}/{column}/{row}"
    }
    // Function to retrieve value of a cell.
    resource function getCellData(http:Caller caller, http:Request request, string spreadsheetId, string worksheetName,
                                  string column, int row) {
        // Define new response.
        http:Response backendResponse = new();
        // Invoke getCellData remote function from spreadsheetClient.
        var response = spreadsheetClient->getCellData(<@untainted> spreadsheetId, <@untainted> worksheetName,
                                                      <@untainted> column, <@untainted> row);
        if (response is string) {
            // If there is no error, send the success response.
            backendResponse.statusCode = http:STATUS_OK;
            backendResponse.setTextPayload(<@untainted> response, contentType = "text/plain");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        } else {
            // Send the error response.
            createAndSendErrorResponse(caller, <@untainted> <string>response.detail()?.message,
                            CELL_DATA_RETRIEVAL_ERROR_MSG);
        }
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/{spreadsheetId}/{worksheetId}"
    }
    // Function to delete worksheet.
    resource function deleteSheet(http:Caller caller, http:Request request, string spreadsheetId, int worksheetId) {
        // Define new response.
        http:Response backendResponse = new();
        var response = spreadsheetClient->deleteSheet(spreadsheetId, worksheetId);
        if (response == true) {
            // If the response is the boolean value 'true', send the success response.
            string payload = "The worksheet " + io:sprintf("%s", worksheetId) + " has been deleted.";
            backendResponse.statusCode = http:STATUS_NO_CONTENT;
            backendResponse.setTextPayload(payload, contentType = "text/plain");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        } else {
            // Else, send the failure response.
            string payload = "Unable to delete the worksheet " + io:sprintf("%s", worksheetId);
            backendResponse.statusCode = http:STATUS_BAD_REQUEST;
            backendResponse.setTextPayload(payload, contentType = "text/plain");
            respondAndHandleError(caller, backendResponse, RESPOND_ERROR_MSG);
        }
    }
}

// Function to extract the object content from request payload
function extractRequestContent(http:Request request) returns @tainted string|string[][]|error {
    string contentTypeStr = request.getContentType();
    if (equalsIgnoreCase(contentTypeStr, "application/json")) {
        var jsonObjectContent = request.getJsonPayload();
        if (jsonObjectContent is json[]) {
            string[][] stringMDArray = convertToStringMDArray(jsonObjectContent);
            return stringMDArray;
        } else {
            error err = error("Invalid payload content.", message = INVALID_PAYLOAD_MSG);
            return err;
        }
    } else if (equalsIgnoreCase(contentTypeStr, "text/plain")) {
        var textObjectContent = request.getTextPayload();
        if (textObjectContent is string) {
            return textObjectContent;
        } else {
            error err = error("Invalid payload content.",
                              message = <@untainted> <string>textObjectContent.detail()?.message);
            return err;
        }
    } else {
        error err = error("Invalid content. The payload should be 'application/json or text/plain'.'",
                          message = INVALID_PAYLOAD_MSG);
        return err;
    }
}

// Function to create the error response.
function createAndSendErrorResponse(http:Caller caller, string errorMessage, string respondErrorMsg) {
    http:Response response = new;
    //Set 500 status code.
    response.statusCode = 500;
    //Set the error message to the error response payload.
    response.setPayload(<string> errorMessage);
    //log:printInfo("call respondAndHandleError func");
    respondAndHandleError(caller, response, respondErrorMsg);
}

// Function to send the response back to the client and handle the error.
function respondAndHandleError(http:Caller caller, http:Response response, string respondErrorMsg) {
    // Send response to the caller.
    var respond = caller->respond(response);
    if (respond is error) {
        log:printError(respondErrorMsg, err = respond);
    }
}

function equalsIgnoreCase(string str1, string str2) returns boolean {
    if (str1.toUpperAscii() == str2.toUpperAscii()) {
        return true;
    } else {
        return false;
    }
}

function convertSpreadsheetToJSON(gsheets4:Spreadsheet spreadsheet) returns json {
    json jsonSpreadsheet = {
                                spreadsheetId: spreadsheet.spreadsheetId,
                                properties: io:sprintf("%s", spreadsheet.properties),
                                sheets: io:sprintf("%s", spreadsheet.sheets),
                                spreadsheetUrl: spreadsheet.spreadsheetUrl
                           };
    return jsonSpreadsheet;
}

function convertSheetPropertiesToJSON(gsheets4:SheetProperties sheetProperties) returns json {
    json jsonSheetProperties = {
                                   title: sheetProperties.title,
                                   sheetId: sheetProperties.sheetId,
                                   index: sheetProperties.index,
                                   sheetType: sheetProperties.sheetType,
                                   hidden: sheetProperties.hidden,
                                   rightToLeft: sheetProperties.rightToLeft,
                                   gridProperties: io:sprintf("%s", sheetProperties.gridProperties)
                               };
    return jsonSheetProperties;
}

function convertToStringMDArray(json[] jsonObjectContent) returns string[][] {
    string[][] stringArray = [];
    int i = 0;
    foreach var mainObj in jsonObjectContent {
        int j = 0;
        stringArray[i] = [];
        if (mainObj is json[]) {
            foreach var subObj in mainObj {
                stringArray[i][j] = <string>subObj;
                j += 1;
            }
            i += 1;
        }
    }
    return stringArray;
}
```

## Testing


First build the module. Navigate to the project root directory and execute the following command.

```bash
$ ballerina build googlespreadsheet_service
```

This creates the executables. Now run the `googlespreadsheet_servicet.jar` file created in the above step.

```bash
$ java -jar target/bin/googlespreadsheet_service.jar
```

You will see the following service log after successfully invoking the service.

```log
[ballerina/http] started HTTP/WS listener 0.0.0.0:9090
```

### 1. Creating a new spreadsheet
 ```bash
 curl -v -X POST http://localhost:9090/spreadsheets/<SPREADSHEET_NAME>
```
e.g.
```bash
curl -v -X POST http://localhost:9090/spreadsheets/firstSpreadsheet
```
### 2. Adding a new worksheet
```bash
curl -v -X POST http://localhost:9090/spreadsheets/<SPREADSHEET_ID>/<WORKSHEET_NAME>
```
e.g.
```bash
curl -v -X POST http://localhost:9090/spreadsheets/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY/firstWorksheet
   ```

### 3. Viewing a spreadsheet
```bash
curl -X GET http://localhost:9090/spreadsheets/<SPREADSHEET_ID>
```
e.g.
```bash
curl -X GET http://localhost:9090/spreadsheets/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY
```

### 4. Adding values into a worksheet
```bash
curl -H "Content-Type: application/json" \ -X PUT \ -d '[["Name", "Score"], ["Keetz", "12"], ["Niro", "78"], ["Nisha", "98"], ["Kana", "86"]]'\http://localhost:9090/spreadsheets/<SPREADSHEET_ID>/<WORKSHEET_NAME>/<TOP_LEFT_CELL>/<BOTTOM_RIGHT_CELL>
```
e.g.
```bash
curl -H "Content-Type: application/json" \-X PUT \ -d '[["Name", "Score"], ["Keetz", "12"], ["Niro", "78"], ["Nisha", "98"], ["Kana", "86"]]' \ http://localhost:9090/spreadsheets/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY/firstWorksheet/A1/B5
```

### 5. Getting values from worksheet
```bash\
curl -X GET http://localhost:9090/spreadsheets/worksheet/<SPREADSHEET_ID>/<WORKSHEET_NAME>/<TOP_LEFT_CELL>/<BOTTOM_RIGHT_CELL>
```
e.g.
```bash
curl -X GET http://localhost:9090/spreadsheets/column/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY/firstWorksheet/B
```

### 6. Retrieving values of a column
```bash
curl -X GET http://localhost:9090/spreadsheets/column/<SPREADSHEET_ID>/<WORKSHEET_NAME>/<COLUMN_NAME>
```

### 7. Retrieving values of a row
```bash
curl -X GET http://localhost:9090/spreadsheets/row/<SPREADSHEET_ID>/<WORKSHEET_NAME>/<COLUMN_NAME>/<ROW_NAME>
```
e.g.
```bash
curl -X GET http://localhost:9090/spreadsheets/row/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY/firstWorksheet/2
```

### 8. Adding value into a cell
```bash
curl -H "Content-Type: text/plain" \ -X PUT \ -d 'Test Value' \http://localhost:9090/spreadsheets/cell/<SPREADSHEET_ID>/<WORKSHEET_NAME>/<TOP_LEFT_CELL>/<BOTTOM_RIGHT_CELL>
```
e.g.
```bash
curl -H "Content-Type: text/plain" \ -X PUT \ -d 'Test Value' \
http://localhost:9090/spreadsheets/cell/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY/firstWorksheet/C/2
```

### 9. Retrieving value of a cell
```bash
curl -X GET http://localhost:9090/spreadsheets/cell/<SPREADSHEET_ID>/<WORKSHEET_NAME>/<TOP_LEFT_CELL>/<BOTTOM_RIGHT_CELL>
```
e.g.
```bash
curl -X GET http://localhost:9090/spreadsheets/cell/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY/firstWorksheet/C/2
```

### 10. Deleting a worksheet
```bash
curl -X DELETE http://localhost:9090/spreadsheets/<SPREADSHEET_ID>/<WORKSHEET_ID>
```
e.g.
```bash
 curl -X DELETE http://localhost:9090/spreadsheets/1AoOHLyn3Ds6do6UMq8t_pv20RrRwNV4aoqQVI_Z5xKY/1636241809
 ```

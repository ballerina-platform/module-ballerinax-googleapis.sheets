// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/lang.regexp;
import ballerinax/'client.config;

# Ballerina Google Sheets connector provides the capability to access Google Sheets API.
# The connector let you perform spreadsheet management operations, worksheet management operations and
# the capability to handle Google Sheets data level operations.
@display {label: "Google Sheets", iconPath: "icon.png"}
public isolated client class Client {
    final http:Client httpClient;
    final http:Client driveClient;

    # Gets invoked to initialize the `connector`.
    #
    # + spreadsheetConfig - Configuration for the connector
    # + return - `http:Error` in case of failure to initialize or `null` if successfully initialized
    public isolated function init(ConnectionConfig config) returns error? {
        http:ClientConfiguration httpClientConfig = check config:constructHTTPClientConfig(config);
        self.httpClient = check new (BASE_URL, httpClientConfig);
        self.driveClient = check new (DRIVE_URL, httpClientConfig);
    }

    // Spreadsheet Management Operations

    # Creates a new spreadsheet.
    #
    # + name - Name of the spreadsheet
    # + return - `sheets:Spreadsheet` record on success, or else an error
    @display {label: "Create Google Sheet"}
    remote isolated function createSpreadsheet(@display {label: "Google Sheet Name"} string name)
                                               returns Spreadsheet|error {
        json jsonPayload = {"properties": {"title": name}};
        json response = check sendRequestWithPayload(self.httpClient, SPREADSHEET_PATH, jsonPayload);
        return convertJSONToSpreadsheet(response);
    }

    # Opens a spreadsheet by the given ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + return - `sheets:Spreadsheet` record on success, or else an error
    @display {label: "Open Google Sheet By ID"}
    remote isolated function openSpreadsheetById(@display {label: "Google Sheet ID"} string spreadsheetId)
                                                 returns Spreadsheet|error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json response = check sendRequest(self.httpClient, spreadsheetPath);
        return convertJSONToSpreadsheet(response);
    }

    # Opens a spreadsheet by the given Url.
    #
    # + url - Url of the spreadsheet
    # + return - `sheets:Spreadsheet` record on success, or else an error
    @display {label: "Open Google Sheet By Url"}
    remote isolated function openSpreadsheetByUrl(@display {label: "Google Sheet Url"} string url)
                                                  returns Spreadsheet|error {
        string spreadsheetId = check getIdFromUrl(url);
        return self->openSpreadsheetById(spreadsheetId);
    }

    # Get all spreadsheet files.
    #
    # + return - Stream of `sheets:File` records on success, or else an error
    @display {label: "Get All Spreadsheets"}
    remote isolated function getAllSpreadsheets() returns @display {label: "Stream of Files"} stream<File, error?>|error {
        SpreadsheetStream spreadsheetStream = check new SpreadsheetStream(self.driveClient);
        return new stream<File, error?>(spreadsheetStream);
    }

    # Renames the spreadsheet with the given name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + name - New name for the spreadsheet
    # + return - Nil on success, or else an error
    @display {label: "Rename Google Sheet"}
    remote isolated function renameSpreadsheet(@display {label: "Google Sheet ID"} string spreadsheetId,
                                               @display {label: "New Google Sheet Name"} string name) returns error? {
        json payload = {
            "requests": [
                {
                    "updateSpreadsheetProperties": {
                        "properties": {"title": name},
                        "fields": "title"
                    }
                }
            ]
        };
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        return;
    }

    // Worksheet Management Operations

    # Get worksheets of the spreadsheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + return - Array of `sheets:Sheet` records on success, or else an error
    @display {label: "Get Worksheets"}
    remote isolated function getSheets(@display {label: "Google Sheet ID"} string spreadsheetId)
                                        returns @display {label: "Array of Worksheets"} Sheet[]|error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json response = check sendRequest(self.httpClient, spreadsheetPath);
        Spreadsheet spreadsheet = check convertJSONToSpreadsheet(response);
        return spreadsheet.sheets;
    }

    # Get a worksheet of the spreadsheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - Name of the worksheet to retrieve
    # + return - `sheets:Sheet` record on success, or else an error
    @display {label: "Get Worksheet By Name"}
    remote isolated function getSheetByName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                            @display {label: "Worksheet Name"} string sheetName) returns Sheet|error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json response = check sendRequest(self.httpClient, spreadsheetPath);
        Spreadsheet spreadsheet = check convertJSONToSpreadsheet(response);
        Sheet[] sheets = spreadsheet.sheets;
        foreach Sheet sheet in sheets {
            if equalsIgnoreCase(sheet.properties.title, sheetName) {
                return sheet;
            }
        }
        return error("Sheet not found");
    }

    # Add a new worksheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + return - `sheets:Sheet` record on success, or else an error
    @display {label: "Add New Worksheet"}
    remote isolated function addSheet(@display {label: "Google Sheet ID"} string spreadsheetId,
                                      @display {label: "Worksheet Name"} string sheetName)
                                      returns Sheet|error {
        map<json> payload = {"requests": [{"addSheet": {"properties": {}}}]};
        map<json> jsonSheetProperties = {};
        if sheetName != EMPTY_STRING {
            jsonSheetProperties["title"] = sheetName;
        }
        json[] requestsElement = <json[]>payload["requests"];
        map<json> firstRequestsElement = <map<json>>requestsElement[0];
        json|error value = firstRequestsElement.addSheet;
        map<json> sheetElement = {};
        if value is map<json> {
            sheetElement = value;
        }
        sheetElement["properties"] = jsonSheetProperties;
        string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json response = check sendRequestWithPayload(self.httpClient, addSheetPath, payload);
        json|error jsonResponseValues = response.replies;
        json[] replies = [];
        if jsonResponseValues is json[] {
            replies = jsonResponseValues;
        }
        json|error addSheet = replies[0].addSheet;

        Sheet sheet = {};
        if addSheet !is error {
            SheetProperties sheetProperties = {};
            json|error sheetId = addSheet.properties.sheetId;
            if sheetId is json {
                sheetProperties.sheetId = convertToInt(sheetId.toString());
            }
            json|error title = addSheet.properties.title;
            if title is json {
                sheetProperties.title = title.toString();
            }
            json|error index = addSheet.properties.index;
            if index is json {
                sheetProperties.index = convertToInt(index.toString());
            }
            json|error sheetType = addSheet.properties.sheetType;
            if sheetType is json {
                sheetProperties.sheetType = sheetType.toString();
            }
            json|error hidden = addSheet.properties.hidden;
            if hidden is json {
                sheetProperties.hidden = convertToBoolean(hidden.toString());
            }
            json|error rightToLeft = addSheet.properties.rightToLeft;
            if rightToLeft is json {
                sheetProperties.rightToLeft = convertToBoolean(rightToLeft.toString());
            }
            sheetProperties.gridProperties = convertToGridProperties(check addSheet.properties.gridProperties);
            sheet.properties = sheetProperties;
        }
        return sheet;
    }

    # Delete specified worksheet by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - The ID of the worksheet to delete
    # + return - Nil on success, or else an error
    @display {label: "Remove Worksheet By ID"}
    remote isolated function removeSheet(@display {label: "Google Sheet ID"} string spreadsheetId,
                                         @display {label: "Worksheet ID"} int sheetId) returns error? {
        json payload = {"requests": [{"deleteSheet": {"sheetId": sheetId}}]};
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        return;
    }

    # Delete specified worksheet by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet to delete
    # + return - Nil on success, or else an error
    @display {label: "Remove Worksheet"}
    remote isolated function removeSheetByName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                               @display {label: "Worksheet Name"} string sheetName) returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        json payload = {"requests": [{"deleteSheet": {"sheetId": sheet.properties.sheetId}}]};
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        return;
    }

    # Renames the worksheet of a given spreadsheet with the given name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The existing name of the worksheet
    # + name - New name for the worksheet
    # + return - Nil on success, or else an error
    @display {label: "Rename Worksheet"}
    remote isolated function renameSheet(@display {label: "Google Sheet ID"} string spreadsheetId,
                                         @display {label: "Existing Worksheet Name"} string sheetName,
                                         @display {label: "New Worksheet Name"} string name) returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        json payload = {
            "requests": [
                {
                    "updateSheetProperties": {
                        "properties": {"sheetId": sheet.properties.sheetId, "title": name},
                        "fields": "title"
                    }
                }
            ]
        };
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        return;
    }

    // Sheet Service Operations

    # Sets the values of the given range of cells of the worksheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + range - The Range record to be set
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - Nil on success, or else an error
    @display {label: "Set Range"}
    remote isolated function setRange(@display {label: "Google Sheet ID"} string spreadsheetId,
                                      @display {label: "Worksheet Name"} string sheetName, Range range,
                                      @display {label: "Value Input Option"} string? valueInputOption = ())
                                      returns error? {
        (string|int|decimal)[][] values = range.values;
        string a1Notation = range.a1Notation;
        if a1Notation == EMPTY_STRING {
            return error("Invalid range notation");
        }
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        setValuePath = setValuePath + ((valueInputOption is ()) ? string `${VALUE_INPUT_OPTION}${RAW}` :
            string `${VALUE_INPUT_OPTION}${valueInputOption}`);
        http:Request request = new;
        json[][] jsonValues = [];
        int i = 0;
        foreach (string|int|decimal)[] value in values {
            int j = 0;
            json[] val = [];
            foreach string|int|decimal v in value {
                val[j] = v;
                j = j + 1;
            }
            jsonValues[i] = val;
            i = i + 1;
        }
        json jsonPayload = {"values": jsonValues};
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = check self.httpClient->put(setValuePath, request);
        int statusCode = httpResponse.statusCode;
        json|error jsonResponse = httpResponse.getJsonPayload();
        if jsonResponse is json {
            return setResponse(jsonResponse, statusCode);
        }
        return error("Error occurred while accessing the JSON payload of the response");
    }

    # Gets the given range of the worksheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required range in A1 notation
    # + valueRenderOption - Determines how values should be rendered in the output.
    # It's either `FORMATTED_VALUE`, `UNFORMATTED_VALUE` or `FORMULA`.
    # Default is `FORMATTED_VALUE` (Optional).
    # For more information, see [ValueRenderOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueRenderOption)
    # + return - `sheets:Range` record on success, or else an error
    @display {label: "Get Range"}
    remote isolated function getRange(@display {label: "Google Sheet ID"} string spreadsheetId,
                                      @display {label: "Worksheet Name"} string sheetName,
                                      @display {label: "Range A1 Notation"} string a1Notation,
                                      @display {label: "Value Render Option"} string? valueRenderOption = ())
                                      returns Range|error {
        (string|int|decimal)[][] values = [];
        if a1Notation == EMPTY_STRING {
            return error("Invalid range notation");
        }
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        getSheetValuesPath = getSheetValuesPath + ((valueRenderOption is ()) ? EMPTY_STRING :
            string `${QUESTION_MARK}${VALUE_RENDER_OPTION}${valueRenderOption}`);
        json response = check sendRequest(self.httpClient, getSheetValuesPath);
        if response.values !is error {
            values = convertToArray(response);
        }
        Range range = {a1Notation: a1Notation, values: values};
        return range;
    }

    # Clears the range of contents, formats, and data validation rules.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required range in A1 notation
    # + return - Nil on success, or else an error
    @display {label: "Clear Range"}
    remote isolated function clearRange(@display {label: "Google Sheet ID"} string spreadsheetId,
                                        @display {label: "Worksheet Name"} string sheetName,
                                        @display {label: "Range A1 Notation"} string a1Notation) returns error? {
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH +
            notation + CLEAR_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteSheetPath);
        return;
    }

    # Inserts the given number of columns before the given column position by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + index - The position of the column before which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Columns Before By Sheet ID"}
    remote isolated function addColumnsBefore(@display {label: "Google Sheet ID"} string spreadsheetId,
                                              @display {label: "Worksheet ID"} int sheetId,
                                              @display {label: "Column Position"} int index,
                                              @display {label: "Number of Columns"} int numberOfColumns) returns error? {
        int startIndex = index - 1;
        int endIndex = startIndex + numberOfColumns;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheetId,
                            "dimension": "COLUMNS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addColumnsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        return;
    }

    # Inserts the given number of columns before the given column position by worksheet name.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + index - The position of the column before which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Columns Before"}
    remote isolated function addColumnsBeforeBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                         @display {label: "Worksheet Name"} string sheetName,
                                                         @display {label: "Column Position"} int index,
                                                         @display {label: "Number of Columns"} int numberOfColumns)
                                                         returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        int startIndex = index - 1;
        int endIndex = startIndex + numberOfColumns;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheet.properties.sheetId,
                            "dimension": "COLUMNS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addColumnsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        return;
    }

    # Inserts the given number of columns after the given column position by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Columns After By Sheet ID"}
    remote isolated function addColumnsAfter(@display {label: "Google Sheet ID"} string spreadsheetId,
                                             @display {label: "Worksheet ID"} int sheetId,
                                             @display {label: "Column Position"} int index,
                                             @display {label: "Number of Columns"} int numberOfColumns)
                                             returns error? {
        int startIndex = index;
        int endIndex = startIndex + numberOfColumns;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheetId,
                            "dimension": "COLUMNS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addColumnsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        return;
    }

    # Inserts the given number of columns after the given column position by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Columns After"}
    remote isolated function addColumnsAfterBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                        @display {label: "Worksheet Name"} string sheetName,
                                                        @display {label: "Column Position"} int index,
                                                        @display {label: "Number of Columns"} int numberOfColumns)
                                                        returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        int startIndex = index;
        int endIndex = startIndex + numberOfColumns;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheet.properties.sheetId,
                            "dimension": "COLUMNS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addColumnsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        return;
    }

    # Create or Update a Column.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + column - Position of column (string notation) to set the data
    # + values - Array of values of the column to be added
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - Nil on success, or else an error
    @display {label: "Set Column"}
    remote isolated function createOrUpdateColumn(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                  @display {label: "Worksheet Name"} string sheetName,
                                                  @display {label: "Column Position"} string column,
                                                  @display {label: "Column Values"} (int|string|decimal)[] values,
                                                  @display {label: "Value Input Option"} string? valueInputOption = ())
                                                  returns error? {
        string notation = sheetName + EXCLAMATION_MARK + column + COLON + column;
        string requestPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        requestPath = requestPath + ((valueInputOption is ()) ? string `${VALUE_INPUT_OPTION}${RAW}` :
            string `${VALUE_INPUT_OPTION}${valueInputOption}`);
        json[] jsonValues = [];
        int i = 0;
        foreach (string|int|decimal) value in values {
            jsonValues[i] = value;
            i = i + 1;
        }
        json jsonPayload = {
            "range": notation,
            "majorDimension": "COLUMNS",
            "values": [
                jsonValues
            ]
        };
        http:Request request = new ();
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = check self.httpClient->put(requestPath, request);
        if httpResponse.statusCode == http:STATUS_OK {
            return;
        }
        return getErrorMessage(httpResponse);
    }

    # Gets the values in the given column of the worksheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + column - Position of Column (string notation) to retrieve the data
    # + valueRenderOption - Determines how values should be rendered in the output.
    # It's either `FORMATTED_VALUE`, `UNFORMATTED_VALUE` or `FORMULA`.
    # Default is `FORMATTED_VALUE` (Optional).
    # For more information, see [ValueRenderOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueRenderOption)
    # + return - `sheets:Column` record on success, or else an error
    @display {label: "Get Column"}
    remote isolated function getColumn(@display {label: "Google Sheet ID"} string spreadsheetId,
                                       @display {label: "Worksheet Name"} string sheetName,
                                       @display {label: "Column Position"} string column,
                                       @display {label: "Value Render Option"} string? valueRenderOption = ())
                                       returns Column|error {
        (int|string|decimal)[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + column + COLON + column;
        string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        getColumnDataPath = getColumnDataPath + ((valueRenderOption is ()) ? EMPTY_STRING :
            string `${QUESTION_MARK}${VALUE_RENDER_OPTION}${valueRenderOption}`);
        json response = check sendRequest(self.httpClient, getColumnDataPath);
        if response.values !is error {
            int i = 0;
            json|error jsonResponseValues = response.values;
            json[] jsonValues = [];
            if jsonResponseValues is json[] {
                jsonValues = jsonResponseValues;
            }
            foreach json value in jsonValues {
                json[] jsonValArray = <json[]>value;
                if jsonValArray.length() > 0 {
                    values[i] = getConvertedValue(jsonValArray[0]);
                } else {
                    values[i] = EMPTY_STRING;
                }
                i = i + 1;
            }
        }
        Column columnRecord = {columnPosition: column, values: values};
        return columnRecord;
    }

    # Deletes the given number of columns starting at the given column position by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, or else an error
    @display {label: "Delete Columns By Sheet ID"}
    remote isolated function deleteColumns(@display {label: "Google Sheet ID"} string spreadsheetId,
                                           @display {label: "Worksheet ID"} int sheetId,
                                           @display {label: "Starting Column Position"} int column,
                                           @display {label: "Number of Columns"} int numberOfColumns) returns error? {
        int startIndex = column - 1;
        int endIndex = startIndex + numberOfColumns;
        json payload = {
            "requests": [
                {
                    "deleteDimension": {
                        "range": {
                            "sheetId": sheetId,
                            "dimension": "COLUMNS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string deleteColumnsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteColumnsPath, payload);
        return;
    }

    # Deletes the given number of columns starting at the given column position by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, or else an error
    @display {label: "Delete Columns"}
    remote isolated function deleteColumnsBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                      @display {label: "Worksheet Name"} string sheetName,
                                                      @display {label: "Starting Column Position"} int column,
                                                      @display {label: "Number of Columns"} int numberOfColumns)
                                                      returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        int startIndex = column - 1;
        int endIndex = startIndex + numberOfColumns;
        json payload = {
            "requests": [
                {
                    "deleteDimension": {
                        "range": {
                            "sheetId": sheet.properties.sheetId,
                            "dimension": "COLUMNS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string deleteColumnsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteColumnsPath, payload);
        return;
    }

    # Inserts the given number of rows before the given row position by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Rows Before By Sheet ID"}
    remote isolated function addRowsBefore(@display {label: "Google Sheet ID"} string spreadsheetId,
                                           @display {label: "Worksheet ID"} int sheetId,
                                           @display {label: "Row Position"} int index,
                                           @display {label: "Number of Rows"} int numberOfRows) returns error? {
        int startIndex = index - 1;
        int endIndex = startIndex + numberOfRows;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheetId,
                            "dimension": "ROWS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addRowsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        return;
    }

    # Inserts the given number of rows before the given row position by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Rows Before"}
    remote isolated function addRowsBeforeBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                      @display {label: "Worksheet Name"} string sheetName,
                                                      @display {label: "Row Position"} int index,
                                                      @display {label: "Number of Rows"} int numberOfRows)
                                                      returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        int startIndex = index - 1;
        int endIndex = startIndex + numberOfRows;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheet.properties.sheetId,
                            "dimension": "ROWS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addRowsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        return;
    }

    # Inserts a number of rows after the given row position by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + index - The row after which the new rows should be added.
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Rows After By Sheet ID"}
    remote isolated function addRowsAfter(@display {label: "Google Sheet ID"} string spreadsheetId,
                                          @display {label: "Worksheet ID"} int sheetId,
                                          @display {label: "Row Position"} int index,
                                          @display {label: "Number of Rows"} int numberOfRows) returns error? {
        int startIndex = index;
        int endIndex = startIndex + numberOfRows;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheetId,
                            "dimension": "ROWS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addRowsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        return;
    }

    # Inserts a number of rows after the given row position by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + index - The row after which the new rows should be added.
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, or else an error
    @display {label: "Add Rows After"}
    remote isolated function addRowsAfterBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                     @display {label: "Worksheet Name"} string sheetName,
                                                     @display {label: "Row Position"} int index,
                                                     @display {label: "Number of Rows"} int numberOfRows)
                                                     returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        int startIndex = index;
        int endIndex = startIndex + numberOfRows;
        json payload = {
            "requests": [
                {
                    "insertDimension": {
                        "range": {
                            "sheetId": sheet.properties.sheetId,
                            "dimension": "ROWS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string addRowsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        return;
    }

    # Create or update a row.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + row - Position of row (integer notation) to set the data
    # + values - Array of values of the row to be added
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - Nil on success, or else an error
    @display {label: "Set Row"}
    remote isolated function createOrUpdateRow(@display {label: "Google Sheet ID"} string spreadsheetId,
                                               @display {label: "Worksheet Name"} string sheetName,
                                               @display {label: "Row Position"} int row,
                                               @display {label: "Row Values"} (int|string|decimal)[] values,
                                               @display {label: "Value Input Option"} string? valueInputOption = ())
                                               returns error? {
        string notation = sheetName + EXCLAMATION_MARK + row.toString() + COLON + row.toString();
        string requestPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        requestPath = requestPath + ((valueInputOption is ()) ? string `${VALUE_INPUT_OPTION}${RAW}` :
            string `${VALUE_INPUT_OPTION}${valueInputOption}`);
        json[] jsonValues = [];
        int i = 0;
        foreach (string|int|decimal) value in values {
            jsonValues[i] = value;
            i = i + 1;
        }
        json jsonPayload = {
            "range": notation,
            "majorDimension": "ROWS",
            "values": [
                jsonValues
            ]
        };
        http:Request request = new ();
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = check self.httpClient->put(requestPath, request);
        if httpResponse.statusCode == http:STATUS_OK {
            return;
        }
        return getErrorMessage(httpResponse);
    }

    # Gets the values in the given row of the worksheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + row - Row number to retrieve the data
    # + valueRenderOption - Determines how values should be rendered in the output.
    # It's either `FORMATTED_VALUE`, `UNFORMATTED_VALUE` or `FORMULA`.
    # Default is `FORMATTED_VALUE` (Optional).
    # For more information, see [ValueRenderOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueRenderOption)
    # + return - `sheets:Row` record on success, or else an error
    @display {label: "Get Row"}
    remote isolated function getRow(@display {label: "Google Sheet ID"} string spreadsheetId,
                                    @display {label: "Worksheet Name"} string sheetName,
                                    @display {label: "Row Position"} int row,
                                    @display {label: "Value Render Option"} string? valueRenderOption = ())
                                    returns Row|error {
        (int|string|decimal)[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + row.toString() + COLON + row.toString();
        string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        getRowDataPath = getRowDataPath + ((valueRenderOption is ()) ? EMPTY_STRING :
            string `${QUESTION_MARK}${VALUE_RENDER_OPTION}${valueRenderOption}`);
        json response = check sendRequest(self.httpClient, getRowDataPath);
        if response.values !is error {
            int i = 0;
            json|error jsonResponseValues = response.values;
            json[] jsonValues = [];
            if jsonResponseValues is json {
                jsonValues = <json[]>jsonResponseValues;
            }
            json[] jsonArray = <json[]>jsonValues[0];
            foreach json value in jsonArray {
                values[i] = getConvertedValue(value);
                i = i + 1;
            }
        }
        Row rowRecord = {rowPosition: row, values: values};
        return rowRecord;
    }

    # Deletes the given number of rows starting at the given row position by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of rows from the starting position
    # + return - Nil on success, or else an error
    @display {label: "Delete Rows By Sheet ID"}
    remote isolated function deleteRows(@display {label: "Google Sheet ID"} string spreadsheetId,
                                        @display {label: "Worksheet ID"} int sheetId,
                                        @display {label: "Starting Row Position"} int row,
                                        @display {label: "Number of Rows"} int numberOfRows) returns error? {
        int startIndex = row - 1;
        int endIndex = startIndex + numberOfRows;
        json payload = {
            "requests": [
                {
                    "deleteDimension": {
                        "range": {
                            "sheetId": sheetId,
                            "dimension": "ROWS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string deleteRowsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteRowsPath, payload);
        return;
    }

    # Deletes the given number of rows starting at the given row position by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of rows from the starting position
    # + return - Nil on success, or else an error
    @display {label: "Delete Rows"}
    remote isolated function deleteRowsBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                   @display {label: "Worksheet Name"} string sheetName,
                                                   @display {label: "Starting Row Position"} int row,
                                                   @display {label: "Number of Rows"} int numberOfRows)
                                                   returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        int startIndex = row - 1;
        int endIndex = startIndex + numberOfRows;
        json payload = {
            "requests": [
                {
                    "deleteDimension": {
                        "range": {
                            "sheetId": sheet.properties.sheetId,
                            "dimension": "ROWS",
                            "startIndex": startIndex,
                            "endIndex": endIndex
                        }
                    }
                }
            ]
        };
        string deleteRowsPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteRowsPath, payload);
        return;
    }

    # Sets the value of the given cell of the worksheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required cell in A1 notation
    # + value - Value of the cell to be set
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - Nil on success, or else an error
    @display {label: "Set Cell"}
    remote isolated function setCell(@display {label: "Google Sheet ID"} string spreadsheetId,
                                     @display {label: "Worksheet Name"} string sheetName,
                                     @display {label: "Cell A1 Notation"} string a1Notation,
                                     @display {label: "Cell Value"} int|string|decimal value,
                                     @display {label: "Value Input Option"} string? valueInputOption = ())
                                     returns error? {
        string notatiob = sheetName + EXCLAMATION_MARK + a1Notation;
        string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notatiob;
        setCellDataPath = setCellDataPath + ((valueInputOption is ()) ? string `${VALUE_INPUT_OPTION}${RAW}` :
            string `${VALUE_INPUT_OPTION}${valueInputOption}`);
        http:Request request = new;
        json jsonPayload = {"values": [[value]]};
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = check self.httpClient->put(setCellDataPath, request);
        int statusCode = httpResponse.statusCode;
        json|error jsonResponse = httpResponse.getJsonPayload();
        if jsonResponse is json {
            return setResponse(jsonResponse, statusCode);
        }
        return error("Error occurred while accessing the JSON payload of the response");
    }

    # Gets the value of the given cell of the sheet.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required cell in A1 notation
    # + valueRenderOption - Determines how values should be rendered in the output.
    # It's either `FORMATTED_VALUE`, `UNFORMATTED_VALUE` or `FORMULA`.
    # Default is `FORMATTED_VALUE` (Optional).
    # For more information, see [ValueRenderOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueRenderOption)
    # + return - `sheets:Cell` record on success, or else an error
    @display {label: "Get Cell"}
    remote isolated function getCell(@display {label: "Google Sheet ID"} string spreadsheetId,
                                     @display {label: "Worksheet Name"} string sheetName,
                                     @display {label: "Cell A1 Notation"} string a1Notation,
                                     @display {label: "Value Render Option"} string? valueRenderOption = ())
                                     returns Cell|error {
        int|string|decimal value = EMPTY_STRING;
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        getCellDataPath = getCellDataPath + ((valueRenderOption is ()) ? EMPTY_STRING :
            string `${QUESTION_MARK}${VALUE_RENDER_OPTION}${valueRenderOption}`);
        json response = check sendRequest(self.httpClient, getCellDataPath);
        if response.values !is error {
            json|error jsonResponseValues = response.values;
            json[] responseValues = [];
            if jsonResponseValues is json {
                responseValues = <json[]>jsonResponseValues;
            }
            json[] firstResponseValue = <json[]>responseValues[0];
            value = getConvertedValue(firstResponseValue[0]);
        }
        Cell cellRecord = {a1Notation: a1Notation, value: value};
        return cellRecord;
    }

    # Clears the given cell of contents, formats, and data validation rules.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required cell in A1 notation
    # + return - Nil on success, or else an error
    @display {label: "Clear Cell"}
    remote isolated function clearCell(@display {label: "Google Sheet ID"} string spreadsheetId,
                                       @display {label: "Worksheet name"} string sheetName,
                                       @display {label: "Required Cell A1 Notation"} string a1Notation)
                                       returns error? {
        return self->clearRange(spreadsheetId, sheetName, a1Notation);
    }

    # Adds a new row with the given values to the bottom of the worksheet. The input range is used to search
    # for existing data and find a "table" within that range. Values will be appended to the next row of
    # the table, starting with the first column of the table.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + values - Array of values of the row to be added
    # + a1Notation - The required range in A1 notation (Optional)
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - Nil on success, or else an error
    #
    # # Deprecated
    # This function is deprecated due to the introduction of new more resourceful API `appendValue`.
    # This API will be removed with 4.0.0 release.
    #
    @display {label: "Append Row To Sheet"}
    @deprecated
    remote isolated function appendRowToSheet(@display {label: "Google Sheet ID"} string spreadsheetId,
            @display {label: "Worksheet Name"} string sheetName,
            @display {label: "Row Values"} (int|string|decimal)[] values,
            @display {label: "Range A1 Notation"} string? a1Notation = (),
            @display {label: "Value Input Option"} string? valueInputOption = ())
                                            returns error? {
        string notation = (a1Notation is ()) ? string `${sheetName}` :
            string `${sheetName}${EXCLAMATION_MARK}${a1Notation}`;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation + APPEND;
        setValuePath = setValuePath + ((valueInputOption is ()) ? string `${VALUE_INPUT_OPTION}${RAW}` :
            string `${VALUE_INPUT_OPTION}${valueInputOption}`);
        json[] jsonValues = [];
        int i = 0;
        foreach (string|int|decimal) value in values {
            jsonValues[i] = value;
            i = i + 1;
        }
        json jsonPayload = {
            "range": notation,
            "majorDimension": "ROWS",
            "values": [
                jsonValues
            ]
        };
        _ = check sendRequestWithPayload(self.httpClient, setValuePath, jsonPayload);
    }

    # Adds the given values to a row at the bottom of the worksheet. The input range is used to search
    # for existing data and find a "table" within that range. Values will be appended to the next row of
    # the table, starting with the first column of the table.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + values - Array of values of the row to be added
    # + a1Range - The required range in A1 notation
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - ValueRange on success, or else an error
    @display {label: "Append Value"}
    remote isolated function appendValue(@display {label: "Google Sheet ID"} string spreadsheetId,
                                         @display {label: "Row Values"} (int|string|decimal|boolean|float)[] values,
                                         @display {label: "Range A1 Notation"} A1Range a1Range,
                                         @display {label: "Value Input Option"} string? valueInputOption = ())
                                         returns error|ValueRange {

        string notation = check getA1RangeString(a1Range);
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation + APPEND;
        setValuePath += (valueInputOption is () ? string `${VALUE_INPUT_OPTION}${RAW}` :
            string `${VALUE_INPUT_OPTION}${valueInputOption}`);
        json[] jsonValues = check values.ensureType();
        json jsonPayload = {
            "range": notation,
            "majorDimension": "ROWS",
            "values": [
                jsonValues
            ]
        };
        json response = check sendRequestWithPayload(self.httpClient, setValuePath, jsonPayload);
        if response.updates is error {
            return <error>response.updates;
        }
        json jsonResponseValues = check response.updates.ensureType();
        string range = check jsonResponseValues.updatedRange.ensureType();
        regexp:Span? rowIndex = re `\d+`.find(re `:`.split(re `!`.split(range)[1])[0], 0);
        if rowIndex is () {
            return error(string `Error: ${range}, does not match the expected range format: A1 range. `);
        }
        string responseSheetName = re `!`.split(range)[0];
        string[] responseA1Range = re `:`.split(re `!`.split(range)[1]);
        int rowID = check int:fromString(rowIndex.substring());
        ValueRange rowRecord;
        if responseA1Range.length() == 2 {
            rowRecord = {rowPosition: rowID, values: values, a1Range: {sheetName: responseSheetName, startIndex: responseA1Range[0], endIndex: responseA1Range[1]}};
        } else {
            rowRecord = {rowPosition: rowID, values: values, a1Range: {sheetName: responseSheetName, startIndex: responseA1Range[0]}};
        }
        return rowRecord;
    }

    # Adds the given values to number of rows at the bottom of the worksheet. The input range is used to search
    # for existing data and find a "table" within that range. Values will be appended to the next rows of
    # the table, starting with the first column of the table.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + values - Array of values of the rows to be added
    # + a1Range - The required range in A1 notation
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - ValueRange on success, or else an error
    @display {label: "Append Value"}
    remote isolated function appendValues(@display {label: "Google Sheet ID"} string spreadsheetId,
                                          @display {label: "Row Values"} (int|string|decimal|boolean|float)[][] values,
                                          @display {label: "Range A1 Notation"} A1Range a1Range,
                                          @display {label: "Value Input Option"} string? valueInputOption = ())
                                          returns error|ValuesRange {

        string notation = check getA1RangeString(a1Range);
        string valuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation + APPEND + VALUE_INPUT_OPTION;
        valuePath += valueInputOption is () ? string `${RAW}` :
            string `${valueInputOption}`;
        json jsonValues = check values.ensureType();
        json jsonPayload = {
            "range": notation,
            "majorDimension": "ROWS",
            "values": jsonValues
        };
        json response = check sendRequestWithPayload(self.httpClient, valuePath, jsonPayload);
        if response.updates is error {
            return <error>response.updates;
        }
        json jsonResponseValues = check response.updates.ensureType();
        string range = check jsonResponseValues.updatedRange.ensureType();
        regexp:Span? rowIndex = re `\d+`.find(re `:`.split(re `!`.split(range)[1])[0], 0);
        if rowIndex is () {
            return error(string `Error: ${range}, does not match the expected range format: A1 range. `);
        }
        string sheetName = re `!`.split(range)[0];
        string[] responseA1Range = re `:`.split(re `!`.split(range)[1]);
        int rowStartPosition = check int:fromString(rowIndex.substring());
        ValuesRange rowRecord;
        if responseA1Range.length() == 2 {
            rowRecord = {rowStartPosition, values, a1Range: {sheetName, startIndex: responseA1Range[0], endIndex: responseA1Range[1]}};
        } else {
            rowRecord = {rowStartPosition, values, a1Range: {sheetName, startIndex: responseA1Range[0]}};
        }
        return rowRecord;
    }

    # Copies the sheet to a given spreadsheet by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + destinationId - ID of the spreadsheet to copy the sheet to
    # + return - Nil on success, or else an error
    @display {label: "Copy Sheet By Sheet ID"}
    remote isolated function copyTo(@display {label: "Google Sheet ID"} string spreadsheetId,
                                    @display {label: "Worksheet ID"} int sheetId,
                                    @display {label: "Destination Google Sheet ID"} string destinationId)
                                    returns error? {
        string notation = sheetId.toString();
        string copyToPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + SHEETS_PATH + notation +
            COPY_TO_REQUEST;
        json payload = {"destinationSpreadsheetId": destinationId};
        _ = check sendRequestWithPayload(self.httpClient, copyToPath, payload);
        return;
    }

    # Copies the sheet to a given spreadsheet by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + destinationId - ID of the spreadsheet to copy the sheet to
    # + return - Nil on success, or else an error
    @display {label: "Copy Worksheet"}
    remote isolated function copyToBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                               @display {label: "Worksheet Name"} string sheetName,
                                               @display {label: "Destination Google Sheet ID"} string destinationId)
                                               returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        int sheetId = sheet.properties.sheetId;
        string notation = sheetId.toString();
        string copyToPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + SHEETS_PATH + notation +
            COPY_TO_REQUEST;
        json payload = {"destinationSpreadsheetId": destinationId};
        _ = check sendRequestWithPayload(self.httpClient, copyToPath, payload);
        return;
    }

    # Clears the worksheet content and formatting rules by worksheet ID.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - ID of the worksheet
    # + return - Nil on success, or else an error
    @display {label: "Clear All By Sheet ID"}
    remote isolated function clearAll(@display {label: "Google Sheet ID"} string spreadsheetId,
                                      @display {label: "Worksheet ID"} int sheetId) returns error? {
        json payload = {
            "requests": [
                {
                    "updateCells": {
                        "range": {
                            "sheetId": sheetId
                        },
                        "fields": "*"
                    }
                }
            ]
        };
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        return;
    }

    # Clears the worksheet content and formatting rules by worksheet name.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetName - The name of the worksheet
    # + return - Nil on success, or else an error
    @display {label: "Clear Worksheet"}
    remote isolated function clearAllBySheetName(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                 @display {label: "Worksheet Name"} string sheetName)
                                                 returns error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        json payload = {
            "requests": [
                {
                    "updateCells": {
                        "range": {
                            "sheetId": sheet.properties.sheetId
                        },
                        "fields": "*"
                    }
                }
            ]
        };
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        _ = check sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        return;
    }

    # Add developer metadata to the given row.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - The ID of the worksheet
    # + rowIndex - ID of the target row
    # + visibility - Visibility parameter for the developer metadata. It's either `UNSPECIFIED`, `DOCUMENT` or `PROJECT`.
    # + key - Metadata key asigned to the row
    # + value - Value assigned with the key. This should be unique.
    # + return - Nil on success, or else an error
    @display {label: "Set Row Metadata"}
    remote isolated function setRowMetaData(@display {label: "Google Sheet ID"} string spreadsheetId,
                                            @display {label: "Worksheet ID"} int sheetId,
                                            @display {label: "Index of the Row"} int rowIndex,
                                            @display {label: "Visibility of the Metadata"} Visibility visibility,
                                            @display {label: "Metadata Key"} string key,
                                            @display {label: "Metadata Value"} string value)
                                            returns error? {
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json jsonPayload = {
            "requests": [
                {
                    "createDeveloperMetadata": {
                        "developerMetadata": {
                            "location": {
                                "dimensionRange": {
                                    "sheetId": sheetId,
                                    "dimension": "ROWS",
                                    "startIndex": rowIndex - 1,
                                    "endIndex": rowIndex
                                }
                            },
                            "visibility": visibility,
                            "metadataKey": key,
                            "metadataValue": value
                        }
                    }
                }
            ]
        };
        json _ = check sendRequestWithPayload(self.httpClient, setValuePath, jsonPayload);
    }

    # Fetch rows matching to the given criteria in the filter.
    # Supports A1Range, GridRange and DeveloperMetadataLookup filters.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - The ID of the worksheet
    # + filter - A record defining the filter used for the data filtering
    # + return - ValueRange[] on success, or else an error
    @display {label: "Get Row Using Data Filters"}
    remote isolated function getRowByDataFilter(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                @display {label: "Worksheet ID"} int sheetId,
                                                @display {label: "Filter"} Filter filter)
                                                returns error|ValueRange[] {
        string getValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + BATCH_GET_BY_DATAFILTER_REQUEST;
        json jsonPayload;
        if filter is A1Range {
            string a1RangeFilter = check getA1RangeString(filter);
            jsonPayload = {
                "dataFilters": [
                    {
                        "a1Range": a1RangeFilter
                    }
                ],
                "majorDimension": "ROWS"
            };
        } else if filter is GridRangeFilter {
            jsonPayload = {
                "dataFilters": [
                    {
                        "gridRange": filter.toJson()
                    }
                ],
                "majorDimension": "ROWS"
            };
        } else {
            jsonPayload = {
                "dataFilters": [
                    {
                        "developerMetadataLookup": filter.toJson()
                    }
                ],
                "majorDimension": "ROWS"
            };
        }
        json response = check sendRequestWithPayload(self.httpClient, getValuePath, jsonPayload);
        ValueRange[] output = [];
        if response.valueRanges is error {
            return output;
        }
        json[] valueRanges = check response.valueRanges.ensureType();
        foreach json value in valueRanges {
            string[] valueArray = [];
            json|error jsonValues = value.valueRange.values;
            if jsonValues is error {
                return output;
            }
            json[] values = check jsonValues.ensureType();
            string range = check value.valueRange.range.ensureType();
            regexp:Span? rowIndex = re `\d+`.find(re `:`.split(re `!`.split(range)[1])[0], 0);
            if rowIndex is () {
                return error(string `Error: ${range}, does not match the expected range format: A1 range.`);
            }
            string responseSheetName = re `!`.split(range)[0];
            string[] a1Range = re `:`.split(re `!`.split(range)[1]);
            int rowID = check int:fromString(rowIndex.substring());
            json[] valueJsonArray = check values[0].ensureType();
            foreach json item in valueJsonArray {
                valueArray.push(item.toString());
            }
            output.push({rowPosition: rowID, values: valueArray,
                         a1Range: {sheetName: responseSheetName, startIndex: a1Range[0], endIndex: a1Range[1]}});
        }
        return output;
    }

    # Update rows matching the user provided data filter.
    # Supports a1Range, gridRange and Developer metadata lookup filters.
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - The ID of the worksheet
    # + filter - A record defining the filter used for the data filtering
    # + values - Values to assign.
    # + valueInputOption - Determines how input data should be interpreted.
    # It's either `RAW` or `USER_ENTERED`. Default is `RAW` (Optional).
    # For more information, see [ValueInputOption](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption)
    # + return - Nil on success, or else an error
    @display {label: "Update Row Using Data Filters"}
    remote isolated function updateRowByDataFilter(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                   @display {label: "Worksheet ID"} int sheetId,
                                                   @display {label: "Filter"} Filter filter,
                                                   @display {label: "Row Values"} (int|string|decimal|boolean|float)[] values,
                                                   @display {label: "Value Input Option"} string valueInputOption)
                                                   returns error? {

        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + BATCH_UPDATE_BY_DATAFILTER_REQUEST;
        json[] jsonValues = check values.ensureType();
        json jsonPayload;
        if filter is A1Range {
            string a1RangeFilter = check getA1RangeString(filter);
            jsonPayload = {
                "valueInputOption": valueInputOption,
                "data": [
                    {
                        "dataFilter": {
                            "a1Range": a1RangeFilter
                        },
                        "majorDimension": "ROWS",
                        "values": [
                            jsonValues
                        ]
                    }
                ],
                "includeValuesInResponse": false,
                "responseValueRenderOption": "FORMATTED_VALUE",
                "responseDateTimeRenderOption": "SERIAL_NUMBER"
            };
        } else if filter is GridRangeFilter {
            jsonPayload = {
                "valueInputOption": valueInputOption,
                "data": [
                    {
                        "dataFilter": {
                            "gridRange": filter.toJson()
                        },
                        "majorDimension": "ROWS",
                        "values": [
                            jsonValues
                        ]
                    }
                ],
                "includeValuesInResponse": false,
                "responseValueRenderOption": "FORMATTED_VALUE",
                "responseDateTimeRenderOption": "SERIAL_NUMBER"
            };
        } else {
            jsonPayload = {
                "valueInputOption": valueInputOption,
                "data": [
                    {
                        "dataFilter": {
                            "developerMetadataLookup": filter.toJson()
                        },
                        "majorDimension": "ROWS",
                        "values": [
                            jsonValues
                        ]
                    }
                ],
                "includeValuesInResponse": false,
                "responseValueRenderOption": "FORMATTED_VALUE",
                "responseDateTimeRenderOption": "SERIAL_NUMBER"
            };
        }
        _ = check sendRequestWithPayload(self.httpClient, setValuePath, jsonPayload);
    }

    # Delete rows matching the user provided data filter
    # Supports a1Range, gridRange and Developer metadata lookup filters
    #
    # + spreadsheetId - ID of the spreadsheet
    # + sheetId - The ID of the worksheet
    # + filter - A record defining the filter used for the data filtering
    # + return - Nil on success, or else an error
    @display {label: "delete Row Using Data Filters"}
    remote isolated function deleteRowByDataFilter(@display {label: "Google Sheet ID"} string spreadsheetId,
                                                   @display {label: "Worksheet ID"} int sheetId,
                                                   @display {label: "Filter"} Filter filter) returns error? {

        string getValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + BATCH_GET_BY_DATAFILTER_REQUEST;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json jsonPayload;
        if filter is A1Range {
            string a1RangeFilter = check getA1RangeString(filter);
            jsonPayload = {
                "dataFilters": [
                    {
                        "a1Range": a1RangeFilter
                    }
                ],
                "majorDimension": "ROWS"
            };
        } else if filter is GridRangeFilter {
            jsonPayload = {
                "dataFilters": [
                    {
                        "gridRange": filter.toJson()
                    }
                ],
                "majorDimension": "ROWS"
            };
        } else {
            jsonPayload = {
                "dataFilters": [
                    {
                        "developerMetadataLookup": filter.toJson()
                    }
                ],
                "majorDimension": "ROWS"
            };
        }
        json response = check sendRequestWithPayload(self.httpClient, getValuePath, jsonPayload);
        ValueRange[] output = [];
        if response.valueRanges is error {
            return error(string `Error: Value does not exist matching the defined filter.`);
        }
        json[] valueRanges = check response.valueRanges.ensureType();
        foreach json value in valueRanges {
            string[] valueArray = [];
            json jsonValues = check value.valueRange.values;
            json[] values = check jsonValues.ensureType();
            string range = check value.valueRange.range.ensureType();
            regexp:Span? rowIndex = re `\d+`.find(re `:`.split(re `!`.split(range)[1])[0], 0);
            if rowIndex is () {
                return error(string `Error: ${range}, does not match the expected range format: A1 range.`);
            }
            string responseSheetName = re `!`.split(range)[0];
            string[] a1Range = re `:`.split(re `!`.split(range)[1]);
            int rowID = check int:fromString(rowIndex.substring());
            json[] valueJsonArray = check values[0].ensureType();
            foreach json item in valueJsonArray {
                valueArray.push(item.toString());
            }
            output.push({rowPosition: rowID, values: valueArray,
                        a1Range: {sheetName: responseSheetName, startIndex: a1Range[0], endIndex: a1Range[1]}});
        }
        foreach ValueRange row in output {
            jsonPayload = {
                "requests": [
                    {
                        "deleteDimension": {
                            "range": {
                                "sheetId": sheetId,
                                "dimension": "ROWS",
                                "startIndex": row.rowPosition - 1,
                                "endIndex": row.rowPosition
                            }
                        }
                    }
                ]
            };
            _ = check sendRequestWithPayload(self.httpClient, setValuePath, jsonPayload);
        }
    }
}

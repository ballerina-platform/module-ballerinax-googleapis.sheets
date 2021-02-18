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
import ballerina/oauth2;

# Google spreadsheet connector client endpoint.
#
# + httpClient - Connector http endpoint
# + driveClient - Drive connector http endpoint
public client class Client {
    public http:Client httpClient;
    public http:Client driveClient;

    # Initializes the Google spreadsheet connector client endpoint.
    #
    # +  spreadsheetConfig - Configurations required to initialize the `Client` endpoint
    public function init(SpreadsheetConfiguration spreadsheetConfig) {
        oauth2:OutboundOAuth2Provider oauth2Provider = new (spreadsheetConfig.oauth2Config);
        http:BearerAuthHandler bearerHandler = new (oauth2Provider);
        http:ClientSecureSocket? socketConfig = spreadsheetConfig?.secureSocketConfig;
        self.httpClient = new (BASE_URL, {
            auth: {
                authHandler: bearerHandler
            },
            secureSocket: socketConfig
        });
        self.driveClient = new (DRIVE_URL, {
            auth: {
                authHandler: bearerHandler
            },
            secureSocket: socketConfig
        });
    }

    // Spreadsheet Management Operations

    # Creates a new spreadsheet.
    #
    # + name - Name of the spreadsheet
    # + return - A Spreadsheet record type on success, else returns an error
    remote function createSpreadsheet(string name) returns @tainted Spreadsheet|error {
        json jsonPayload = {"properties": {"title": name}};
        json|error response = sendRequestWithPayload(self.httpClient, SPREADSHEET_PATH, jsonPayload);
        if (response is json) {
            return convertJSONToSpreadsheet(response);
        } else {
            return response;
        }
    }

    # Opens a Spreadsheet by the given ID.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + return - A Spreadsheet record type on success, else returns an error
    remote function openSpreadsheetById(string spreadsheetId) returns @tainted Spreadsheet|error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json|error response = sendRequest(self.httpClient, spreadsheetPath);
        if (response is json) {
            return convertJSONToSpreadsheet(response);
        } else {
            return response;
        }
    }

    # Opens a Spreadsheet by the given URL.
    #
    # + url - URL of the Spreadsheet
    # + return - A Spreadsheet record type on success, else returns an error
    remote function openSpreadsheetByUrl(string url) returns @tainted Spreadsheet|error {
        string|error spreadsheetId = self.getIdFromUrl(url);
        if (spreadsheetId is string) {
            return self->openSpreadsheetById(spreadsheetId);
        } else {
            return getSpreadsheetError(spreadsheetId);
        }
    }

    # Get all Spreadsheet files.
    # 
    # + return - Array of files records on success, else returns an error
    remote function getAllSpreadsheets() returns  @tainted stream<File>|error {
        File[] files = [];
        return getFilesStream(self.driveClient, files);
    }

    isolated function getIdFromUrl(string url) returns string|error {
        if (!url.startsWith(URL_START)) {
            return error("Invalid url: " + url);
        } else {
            int? endIndex = url.indexOf(URL_END);
            if (endIndex is ()) {
                return error("Invalid url: " + url);
            } else {
                return url.substring(ID_START_INDEX, endIndex);
            }
        }
    }

    # Renames the Spreadsheet with the given name.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + name - New name for the Spreadsheet
    # + return - Nil on success, else returns an error
    remote function renameSpreadsheet(string spreadsheetId, string name) returns @tainted error? {
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
        json|error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        } 
        return;
    }

    // Worksheet Management Operations

    # Get sheets of the spreadsheet.
    # 
    # + spreadsheetId - ID of the Spreadsheet
    # + return - Sheet array on success and error on failure
    remote function getSheets(string spreadsheetId) returns @tainted Sheet[]|error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json|error response = sendRequest(self.httpClient, spreadsheetPath);
        Spreadsheet spreadsheet = {};
        if (response is json) {
            spreadsheet = check convertJSONToSpreadsheet(response);
            return spreadsheet.sheets;
        } else {
            return response;
        }
    }

    # Get a sheet of the spreadsheet.
    # 
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - Name of the sheet to retrieve
    # + return - Sheet record type on success and error on failure
    remote function getSheetByName(string spreadsheetId, string sheetName) returns @tainted Sheet|error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json|error response = sendRequest(self.httpClient, spreadsheetPath);
        Spreadsheet spreadsheet = {};
        if (response is json) {
            spreadsheet = check convertJSONToSpreadsheet(response);
            Sheet[] sheets = spreadsheet.sheets;
            foreach var sheet in sheets {
                if (equalsIgnoreCase(sheet.properties.title, sheetName)) {
                    return sheet;
                }
            }
            return error("Sheet not found");
        } else {
            return response;
        }
    }

    # Add a new worksheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the sheet. It is an optional parameter.
    #               If the title is empty, then sheet will be created with the default name.
    # + return - Sheet record type on success and error on failure
    remote function addSheet(string spreadsheetId, string sheetName) returns @tainted Sheet|error {
        map<json> payload = {"requests": [{"addSheet": {"properties": {}}}]};
        map<json> jsonSheetProperties = {};
        if (sheetName != EMPTY_STRING) {
            jsonSheetProperties["title"] = sheetName;
        }
        json[] requestsElement = <json[]>payload["requests"];
        map<json> firstRequestsElement = <map<json>>requestsElement[0];
        map<json> sheetElement = <map<json>>firstRequestsElement.addSheet;
        sheetElement["properties"] = jsonSheetProperties;
        string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json | error response = sendRequestWithPayload(self.httpClient, addSheetPath, payload);
        if (response is error) {
            return response;
        } else {
            json[] replies = <json[]>response.replies;
            json | error addSheet = replies[0].addSheet;

            Sheet sheet = {};
            if (!(addSheet is error)) {
                SheetProperties sheetProperties = {};
                sheetProperties.sheetId = convertToInt(addSheet.properties.sheetId.toString());
                sheetProperties.title = addSheet.properties.title.toString();
                sheetProperties.index = convertToInt(addSheet.properties.index.toString());
                sheetProperties.sheetType = addSheet.properties.sheetType.toString();
                sheetProperties.hidden = convertToBoolean(addSheet.properties.hidden.toString());
                sheetProperties.rightToLeft = convertToBoolean(addSheet.properties.rightToLeft.toString());
                sheetProperties.gridProperties = convertToGridProperties(check addSheet.properties.gridProperties);

                sheet.properties = sheetProperties;
            }
            return sheet;
        }
    }

    # Delete specified worksheet by sheet Id.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - The ID of the sheet to delete
    # + return - Nil on success and error on failure
    remote function removeSheet(string spreadsheetId, int sheetId) returns @tainted error? {
        json payload = {"requests": [{"deleteSheet": {"sheetId": sheetId}}]};
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json|error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        }
        return;
    }

    # Delete specified worksheet by sheet name.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the sheet to delete
    # + return - Nil on success and error on failure
    remote function removeSheetByName(string spreadsheetId, string sheetName) returns @tainted error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        json payload = {"requests": [{"deleteSheet": {"sheetId": sheet.properties.sheetId}}]};
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json|error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        }
        return;
    }

    # Renames the first sheet of the spreadsheet with the given name.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + name - New name for the worksheet
    # + return - Nil on success, else returns an error
    remote function renameSheet(string spreadsheetId, string name) returns @tainted error? {
        json payload = {
            "requests": [
                {
                    "updateSheetProperties": {
                        "properties": {"title": name},
                        "fields": "title"
                    }
                }
            ]
        };
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json|error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        } 
        return;
    }

    // Sheet Service Operations

    # Sets the values of the given range of cells of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + range - The range to be set
    # + return - Nil on success, else returns an error
    remote function setRange(string spreadsheetId, string sheetName, Range range) returns @tainted error? {
        (string | int | float)[][] values = range.values;
        string a1Notation = range.a1Notation;
        http:Request request = new;
        string notation = sheetName;
        if (a1Notation == EMPTY_STRING) {
            return error("Invalid range notation");
        }
        notation = notation + EXCLAMATION_MARK + a1Notation;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation
        + QUESTION_MARK + VALUE_INPUT_OPTION;
        json[][] jsonValues = [];
        int i = 0;
        foreach (string | int | float)[] value in values {
            int j = 0;
            json[] val = [];
            foreach string | int | float v in value {
                val[j] = v;
                j = j + 1;
            }
            jsonValues[i] = val;
            i = i + 1;
        }
        json jsonPayload = {"values": jsonValues};
        request.setJsonPayload(<@untainted>jsonPayload);
        var httpResponse = self.httpClient->put(<@untainted>setValuePath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return setResponse(jsonResponse, statusCode);
            } else {
                return error("Error occurred while accessing the JSON payload of the response");
            }
        } else {
            return getSpreadsheetError(<json|error>httpResponse);
        }
    }

    # Gets the given range of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required range in A1 notation
    # + return - The range on success, else returns an error
    remote function getRange(string spreadsheetId, string sheetName, string a1Notation) returns @tainted Range|error {
        (string | int | float)[][] values = [];
        string notation = sheetName;
        if (a1Notation == EMPTY_STRING) {
            return error("Invalid range");
        }
        notation = notation + EXCLAMATION_MARK + a1Notation;
        string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        json | error response = sendRequest(self.httpClient, getSheetValuesPath);
        if (response is error) {
            return response;
        } else {
            if (!(response.values is error)) {
                values = convertToArray(response);
            }
            Range range = {a1Notation: a1Notation, values: values};
            return range;
        }
    }

    # Clears the range of contents, formats, and data validation rules.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required range in A1 notation
    # + return - Nil on success, else returns an error
    remote function clearRange(string spreadsheetId, string sheetName, string a1Notation) returns @tainted error? {
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH +
        notation + CLEAR_REQUEST;
        json | error response = sendRequestWithPayload(self.httpClient, deleteSheetPath);
        if (response is error) {
            return response;
        }
    }

    # Inserts the given number of columns before the given column position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + index - The position of the column before which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    remote function addColumnsBefore(string spreadsheetId, int sheetId, int index, int numberOfColumns) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Inserts the given number of columns before the given column position by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + index - The position of the column before which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    remote function addColumnsBeforeBySheetName(string spreadsheetId, string sheetName, int index, int numberOfColumns) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Inserts the given number of columns after the given column position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    remote function addColumnsAfter(string spreadsheetId, int sheetId, int index, int numberOfColumns) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Inserts the given number of columns after the given column position by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    remote function addColumnsAfterBySheetName(string spreadsheetId, string sheetName, int index, int numberOfColumns) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, addColumnsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Create or Update a Column.
    # 
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + column - Column number to set the data
    # + values - Array of values of the column to be added
    # + return - Nil on success, else returns an error
    remote function createOrUpdateColumn(string spreadsheetId, string sheetName, string column, (int|string|float)[] values) 
            returns @tainted error? {
        string notation = sheetName + EXCLAMATION_MARK + column + COLON + column;
        string requestPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation 
            + "?valueInputOption=USER_ENTERED";
        json[] jsonValues = [];
        int i = 0;
        foreach (string|int|float) value in values {
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
        http:Request request = new();
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.httpClient->put(requestPath, request);
        if (httpResponse.statusCode == http:STATUS_OK) {
            json jsonResponse = check httpResponse.getJsonPayload();
            return; 
        }
        return getErrorMessage(httpResponse);
    }

    # Gets the values in the given column of the sheet.
    #
    # + column - Column number to retrieve the data
    # + return - Values of the given column in an array on success, else returns an error
    remote function getColumn(string spreadsheetId, string sheetName, string column) 
            returns @tainted (string|int|float)[]|error {
        (int | string | float)[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + column + COLON + column;
        string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        json | error response = sendRequest(self.httpClient, getColumnDataPath);
        if (response is error) {
            return response;
        } else {
            if (!(response.values is error)) {
                int i = 0;
                json[] jsonValues = <json[]>response.values;
                foreach json value in jsonValues {
                    json[] jsonValArray = <json[]>value;
                    if (jsonValArray.length() > 0) {
                        values[i] = getConvertedValue(jsonValArray[0]);
                    } else {
                        values[i] = EMPTY_STRING;
                    }
                    i = i + 1;
                }
            }
            return values;
        }
    }

    # Deletes the given number of columns starting at the given column position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, else returns an error
    remote function deleteColumns(string spreadsheetId, int sheetId, int column, int numberOfColumns) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, deleteColumnsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Deletes the given number of columns starting at the given column position by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, else returns an error
    remote function deleteColumnsBySheetName(string spreadsheetId, string sheetName, int column, int numberOfColumns) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, deleteColumnsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Inserts the given number of rows before the given row position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    remote function addRowsBefore(string spreadsheetId, int sheetId, int index, int numberOfRows) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Inserts the given number of rows before the given row position by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    remote function addRowsBeforeBySheetName(string spreadsheetId, string sheetName, int index, int numberOfRows) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Inserts a number of rows after the given row position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + index - The row after which the new rows should be added.
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    remote function addRowsAfter(string spreadsheetId, int sheetId, int index, int numberOfRows) 
            returns @tainted error? {
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
        json|error response = sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Inserts a number of rows after the given row position by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + index - The row after which the new rows should be added.
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    remote function addRowsAfterBySheetName(string spreadsheetId, string sheetName, int index, int numberOfRows) 
            returns @tainted error? {
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
        json|error response = sendRequestWithPayload(self.httpClient, addRowsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Create or Update a Row.
    # 
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + row - Row number to set the data
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
    remote function createOrUpdateRow(string spreadsheetId, string sheetName, int row, (int|string|float)[] values) 
            returns @tainted error? {
        string notation = sheetName + EXCLAMATION_MARK + row.toString() + COLON + row.toString();
        string requestPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation 
            + "?valueInputOption=USER_ENTERED";
        json[] jsonValues = [];
        int i = 0;
        foreach (string|int|float) value in values {
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
        http:Request request = new();
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.httpClient->put(requestPath, request);
        if (httpResponse.statusCode == http:STATUS_OK) {
            json jsonResponse = check httpResponse.getJsonPayload();
            return; 
        }
        return getErrorMessage(httpResponse);
    }

    # Gets the values in the given row of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + row - Row number to retrieve the data
    # + return - Values of the given row in an array on success, else returns an error
    remote function getRow(string spreadsheetId, string sheetName, int row) 
            returns @tainted (string|int|float)[]|error {
        (int | string | float)[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + row.toString() + COLON + row.toString();
        string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        json | error response = sendRequest(self.httpClient, getRowDataPath);
        if (response is error) {
            return response;
        } else {
            if (!(response.values is error)) {
                int i = 0;
                json[] jsonValues = <json[]>response.values;
                json[] jsonArray = <json[]>jsonValues[0];
                foreach json value in jsonArray {
                    values[i] = value.toString();
                    i = i + 1;
                }
            }
            return values;
        }
    }

    # Deletes the given number of rows starting at the given row position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of row from the starting position
    # + return - Nil on success, else returns an error
    remote function deleteRows(string spreadsheetId, int sheetId, int row, int numberOfRows) returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, deleteRowsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Deletes the given number of rows starting at the given row position by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of row from the starting position
    # + return - Nil on success, else returns an error
    remote function deleteRowsBySheetName(string spreadsheetId, string sheetName, int row, int numberOfRows) 
            returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, deleteRowsPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Sets the value of the given cell of the sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required cell in A1 notation
    # + value - Value of the cell to be set
    # + return - Nil on success, else returns an error
    remote function setCell(string spreadsheetId, string sheetName, string a1Notation, int|string|float value) 
            returns @tainted error? {
        http:Request request = new;
        json jsonPayload = {"values": [[value]]};
        string notatiob = sheetName + EXCLAMATION_MARK + a1Notation;
        string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notatiob
        + QUESTION_MARK + VALUE_INPUT_OPTION;
        request.setJsonPayload(jsonPayload);
        var httpResponse = self.httpClient->put(<@untainted>setCellDataPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return setResponse(jsonResponse, statusCode);
            } else {
                return error("Error occurred while accessing the JSON payload of the response");
            }
        } else {
            return getSpreadsheetError(<json|error>httpResponse);
        }
    }

    # Gets the value of the given cell of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required cell in A1 notation
    # + return - Value of the given cell on success, else returns an error
    remote function getCell(string spreadsheetId, string sheetName, string a1Notation) 
            returns @tainted int|string|float|error {
        int | string | float value = EMPTY_STRING;
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        json | error response = sendRequest(self.httpClient, getCellDataPath);
        if (response is error) {
            return response;
        } else {
            if (!(response.values is error)) {
                json[] responseValues = <json[]>response.values;
                json[] firstResponseValue = <json[]>responseValues[0];
                value = firstResponseValue[0].toString();
            }
            return value;
        }
    }

    # Clears the given cell of contents, formats, and data validation rules.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required cell in A1 notation
    # + return - Nil on success, else returns an error
    remote function clearCell(string spreadsheetId, string sheetName, string a1Notation) returns @tainted error? {
        return self->clearRange(spreadsheetId, sheetName, a1Notation);
    }

    # Adds a new row with the given values to the bottom of the sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
    remote function appendRowToSheet(string spreadsheetId, string sheetName, (int|string|float)[] values) 
            returns @tainted error? {
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + sheetName 
            + APPEND_REQUEST;
        json[] jsonValues = [];
        int i = 0;
        foreach (string|int|float) value in values {
            jsonValues[i] = value;
            i = i + 1;
        }
        json jsonPayload = {
            "range": sheetName,
            "majorDimension": "ROWS",
            "values": [
                jsonValues
            ]
        };
        json|error response = sendRequestWithPayload(self.httpClient, <@untainted>setValuePath,
        <@untainted>jsonPayload);
        if (response is error) {
            return response;
        }
    }

    # Adds a new row with the given values to the bottom of the given range.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required range in A1 notation
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
    remote function appendRow(string spreadsheetId, string sheetName, string a1Notation, (int|string|float)[] values) 
            returns @tainted error? {
        string notatiob = sheetName + EXCLAMATION_MARK + a1Notation;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notatiob 
            + APPEND_REQUEST;
        json[] jsonValues = [];
        int i = 0;
        foreach (string|int|float) value in values {
            jsonValues[i] = value;
            i = i + 1;
        }
        json jsonPayload = {
            "range": notatiob,
            "majorDimension": "ROWS",
            "values": [
                jsonValues
            ]
        };
        json|error response = sendRequestWithPayload(self.httpClient, <@untainted>setValuePath,
        <@untainted>jsonPayload);
        if (response is error) {
            return response;
        }
    }

    # Adds a new cell with the given value to the bottom of the given range.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required range in A1 notation
    # + value - Value of the cell to be added
    # + return - Nil on success, else returns an error
    remote function appendCell(string spreadsheetId, string sheetName, string a1Notation, (int|string|float) value) 
            returns @tainted error? {
        string notatiob = sheetName + EXCLAMATION_MARK + a1Notation;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notatiob 
            + APPEND_REQUEST;
        json[] jsonValues = [];
        jsonValues[0] = value;
        json jsonPayload = {
            "range": notatiob,
            "majorDimension": "ROWS",
            "values": [
                jsonValues
            ]
        };
        json|error response = sendRequestWithPayload(self.httpClient, <@untainted>setValuePath,
        <@untainted>jsonPayload);
        if (response is error) {
            return response;
        }
    }

    # Copies the Sheet to a given Spreadsheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + destinationId - ID of the Spreadsheet to copy the sheet to
    # + return - Nil on success, else returns an error
    remote function copyTo(string spreadsheetId, int sheetId, string destinationId) returns @tainted error? {
        json payload = {"destinationSpreadsheetId": destinationId};
        string notation = sheetId.toString();
        string copyToPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + SHEETS_PATH + notation +
        COPY_TO_REQUEST;
        json | error response = sendRequestWithPayload(self.httpClient, copyToPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Copies the Sheet to a given Spreadsheet by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + destinationId - ID of the Spreadsheet to copy the sheet to
    # + return - Nil on success, else returns an error
    remote function copyToBySheetName(string spreadsheetId, string sheetName, string destinationId) 
            returns @tainted error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        json payload = {"destinationSpreadsheetId": destinationId};
        int sheetId = sheet.properties.sheetId;
        string notation = sheetId.toString();
        string copyToPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + SHEETS_PATH + notation +
        COPY_TO_REQUEST;
        json | error response = sendRequestWithPayload(self.httpClient, copyToPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Clears the sheet content and formatting rules by sheet Id.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + return - Nil on success, else returns an error
    remote function clearAll(string spreadsheetId, int sheetId) returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Clears the sheet content and formatting rules by sheet name.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + return - Nil on success, else returns an error
    remote function clearAllBySheetName(string spreadsheetId, string sheetName) returns @tainted error? {
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
        json | error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        }
    }
}

# Holds the parameters used to create a `Client`.
#
# + oauth2Config - OAuth client configuration
# + secureSocketConfig - Secure socket configuration
public type SpreadsheetConfiguration record {
    oauth2:DirectTokenConfig oauth2Config;
    http:ClientSecureSocket secureSocketConfig?;
};

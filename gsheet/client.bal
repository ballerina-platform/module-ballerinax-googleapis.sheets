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

# Google spreadsheet connector client endpoint.
#
# + httpClient - Connector http endpoint
# + driveClient - Drive connector http endpoint
@display {label: "Google Sheets", iconPath: "GoogleSheetsLogo.png"}
public client class Client {
    public http:Client httpClient;
    public http:Client driveClient;

    # Initializes the Google spreadsheet connector client endpoint.
    #
    # +  spreadsheetConfig - Configurations required to initialize the `Client` endpoint
    public isolated function init(SpreadsheetConfiguration spreadsheetConfig) returns error? {

        http:ClientSecureSocket? socketConfig = spreadsheetConfig?.secureSocketConfig;

        self.httpClient = check new (BASE_URL, {
            auth: spreadsheetConfig.oauthClientConfig,
            secureSocket: socketConfig
        });
        self.driveClient = check new (DRIVE_URL, {
            auth: spreadsheetConfig.oauthClientConfig,
            secureSocket: socketConfig
        });
    }

    // Spreadsheet Management Operations

    # Creates a new spreadsheet.
    #
    # + name - Name of the spreadsheet
    # + return - A Spreadsheet record type on success, else returns an error
    @display {label: "Create Spreadsheet"}
    remote isolated function createSpreadsheet(@display {label: "Spreadsheet Name"} string name) 
                                               returns @tainted Spreadsheet|error {
        json jsonPayload = {"properties": {"title": name}};
        json|error response = sendRequestWithPayload(self.httpClient, SPREADSHEET_PATH, jsonPayload);
        if (response is json) {
            return convertJSONToSpreadsheet(response);
        } else {
            return response;
        }
    }

    # Opens a spreadsheet by the given Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + return - A Spreadsheet record type on success, else returns an error
    @display {label: "Open Spreadsheet By Id"}
    remote isolated function openSpreadsheetById(@display {label: "Spreadsheet Id"} string spreadsheetId) 
                                                 returns @tainted Spreadsheet|error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json|error response = sendRequest(self.httpClient, spreadsheetPath);
        if (response is json) {
            return convertJSONToSpreadsheet(response);
        } else {
            return response;
        }
    }

    # Opens a spreadsheet by the given Url.
    #
    # + url - Url of the spreadsheet
    # + return - A Spreadsheet record type on success, else returns an error
    @display {label: "Open Spreadsheet By Url"}
    remote isolated function openSpreadsheetByUrl(@display {label: "Spreadsheet Url"} string url) 
                                                  returns @tainted Spreadsheet|error {
        string|error spreadsheetId = getIdFromUrl(url);
        if (spreadsheetId is string) {
            return self->openSpreadsheetById(spreadsheetId);
        } else {
            return getSpreadsheetError(spreadsheetId);
        }
    }

    # Get all spreadsheet files.
    # 
    # + return - Stream of File records on success, else returns an error
    @display {label: "Get All Spreadsheets"}
    remote isolated function getAllSpreadsheets() returns @tainted 
                                                @display {label: "Stream of Files"} stream<File,error>|error {
        SpreadsheetStream spreadsheetStream = check new SpreadsheetStream(self.driveClient);
        return new stream<File,error>(spreadsheetStream);
    }

    # Renames the spreadsheet with the given name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + name - New name for the spreadsheet
    # + return - Nil on success, else returns an error
    @display {label: "Rename Spreadsheet"}
    remote isolated function renameSpreadsheet(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                               @display {label: "New Name for Spreadsheet"} string name) 
                                               returns @tainted error? {
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

    # Get worksheets of the spreadsheet.
    # 
    # + spreadsheetId - Id of the spreadsheet
    # + return - Array of Sheet records on success and error on failure
    @display {label: "Get Worksheets"}
    remote isolated function getSheets(@display {label: "Spreadsheet Id"} string spreadsheetId) 
                                       returns @tainted @display {label: "Array of Worksheets"} Sheet[]|error {
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

    # Get a worksheet of the spreadsheet.
    # 
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the worksheet to retrieve
    # + return - Sheet record type on success and error on failure
    @display {label: "Get Worksheet By Name"}
    remote isolated function getSheetByName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                            @display {label: "Worksheet Name"} string sheetName) 
                                            returns @tainted Sheet|error {
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
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + return - Sheet record type on success and error on failure
    @display {label: "Add New Worksheet"}
    remote isolated function addSheet(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                      @display {label: "Worksheet Name"} string sheetName) 
                                      returns @tainted Sheet|error {
        map<json> payload = {"requests": [{"addSheet": {"properties": {}}}]};
        map<json> jsonSheetProperties = {};
        if (sheetName != EMPTY_STRING) {
            jsonSheetProperties["title"] = sheetName;
        }
        json[] requestsElement = <json[]>payload["requests"];
        map<json> firstRequestsElement = <map<json>>requestsElement[0];
        json|error value = firstRequestsElement.addSheet;
        map<json> sheetElement = {};
        if (value is json) {
            sheetElement = <map<json>>value;
        }
        sheetElement["properties"] = jsonSheetProperties;
        string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json | error response = sendRequestWithPayload(self.httpClient, addSheetPath, payload);
        if (response is error) {
            return response;
        } else {
            json|error jsonResponseValues = response.replies;
            json[] replies = [];
            if (jsonResponseValues is json) {
                replies = <json[]>jsonResponseValues;
            }
            json | error addSheet = replies[0].addSheet;

            Sheet sheet = {};
            if (!(addSheet is error)) {
                SheetProperties sheetProperties = {};
                json|error sheetId = addSheet.properties.sheetId;
                if (sheetId is json) {
                    sheetProperties.sheetId = convertToInt(sheetId.toString());
                }
                json|error title = addSheet.properties.title;
                if (title is json) {
                    sheetProperties.title = title.toString();
                }
                json|error index = addSheet.properties.index;
                if (index is json) {
                    sheetProperties.index = convertToInt(index.toString());
                }
                json|error sheetType = addSheet.properties.sheetType;
                if (sheetType is json) {
                    sheetProperties.sheetType = sheetType.toString();
                }
                json|error hidden = addSheet.properties.hidden;
                if (hidden is json) {
                    sheetProperties.hidden = convertToBoolean(hidden.toString());
                }
                json|error rightToLeft = addSheet.properties.rightToLeft;
                if (rightToLeft is json) {
                    sheetProperties.rightToLeft = convertToBoolean(rightToLeft.toString());
                }
                sheetProperties.gridProperties = convertToGridProperties(check addSheet.properties.gridProperties);

                sheet.properties = sheetProperties;
            }
            return sheet;
        }
    }

    # Delete specified worksheet by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - The Id of the worksheet to delete
    # + return - Nil on success and error on failure
    @display {label: "Remove Worksheet By Id"}
    remote isolated function removeSheet(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                         @display {label: "Worksheet Id"} int sheetId) returns @tainted error? {
        json payload = {"requests": [{"deleteSheet": {"sheetId": sheetId}}]};
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json|error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        }
        return;
    }

    # Delete specified worksheet by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet to delete
    # + return - Nil on success and error on failure
    @display {label: "Remove Worksheet By Name"}
    remote isolated function removeSheetByName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                               @display {label: "Worksheet Name"} string sheetName) 
                                               returns @tainted error? {
        Sheet sheet = check self->getSheetByName(spreadsheetId, sheetName);
        json payload = {"requests": [{"deleteSheet": {"sheetId": sheet.properties.sheetId}}]};
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json|error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        }
        return;
    }

    # Renames the worksheet of a given spreadsheet with the given name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The existing name of the worksheet
    # + name - New name for the worksheet
    # + return - Nil on success, else returns an error
    @display {label: "Rename Worksheet"}
    remote isolated function renameSheet(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                         @display {label: "Existing Name for Worksheet"} string sheetName, 
                                         @display {label: "New Name for Worksheet"} string name) 
                                         returns @tainted error? {
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
        json|error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
        if (response is error) {
            return response;
        } 
        return;
    }

    // Sheet Service Operations

    # Sets the values of the given range of cells of the worksheet.
    #
    # + spreadsheetId - Id of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + range - The Range record to be set
    # + return - Nil on success, else returns an error
    @display {label: "Set Range"}
    remote isolated function setRange(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                      @display {label: "Worksheet Name"} string sheetName, 
                                      Range range) returns @tainted error? {
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
        http:Response|error httpResponse = self.httpClient->put(<@untainted>setValuePath, request);
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

    # Gets the given range of the worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required range in A1 notation
    # + return - The Range record on success, else returns an error
    @display {label: "Get Range"}
    remote isolated function getRange(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                      @display {label: "Worksheet Name"} string sheetName, 
                                      @display {label: "Required Range A1 Notation"} string a1Notation) 
                                      returns @tainted Range|error {
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
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required range in A1 notation
    # + return - Nil on success, else returns an error
    @display {label: "Clear Range"}
    remote isolated function clearRange(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                        @display {label: "Worksheet Name"} string sheetName, 
                                        @display {label: "Required Range A1 Notation"} string a1Notation) 
                                        returns @tainted error? {
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH +
        notation + CLEAR_REQUEST;
        json | error response = sendRequestWithPayload(self.httpClient, deleteSheetPath);
        if (response is error) {
            return response;
        }
    }

    # Inserts the given number of columns before the given column position by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + index - The position of the column before which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Columns Before By Sheet Id"}
    remote isolated function addColumnsBefore(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                              @display {label: "Worksheet Id"} int sheetId, 
                                              @display {label: "Position of Given Column"} int index, 
                                              @display {label: "Number of Columns to Insert"} int numberOfColumns) 
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

    # Inserts the given number of columns before the given column position by worksheet name.
    #
    # + spreadsheetId - Id of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + index - The position of the column before which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Columns Before"}
    remote isolated function addColumnsBeforeBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                         @display {label: "Worksheet Name"} string sheetName, 
                                                         @display {label: "Position of Column"} int index, 
                                                         @display {label: "Number of Columns to Insert"} 
                                                         int numberOfColumns) 
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

    # Inserts the given number of columns after the given column position by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Columns After By Sheet Id"}
    remote isolated function addColumnsAfter(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                             @display {label: "Worksheet Id"} int sheetId, 
                                             @display {label: "Position of Column"} int index, 
                                             @display {label: "Number of Columns to Insert"} int numberOfColumns) 
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

    # Inserts the given number of columns after the given column position by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Columns After"}
    remote isolated function addColumnsAfterBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                        @display {label: "Worksheet Name"} string sheetName, 
                                                        @display {label: "Position of Column"} int index, 
                                                        @display {label: "Number of Columns to Insert"} 
                                                        int numberOfColumns) 
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
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + column - Position of column (string notation) to set the data
    # + values - Array of values of the column to be added
    # + return - Nil on success, else returns an error
    @display {label: "Create or Update Column"}
    remote isolated function createOrUpdateColumn(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                  @display {label: "Worksheet Name"} string sheetName, 
                                                  @display {label: "Position of Column"} string column, 
                                                  @display {label: "Values for the Column"} (int|string|float)[] values) 
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
        request.setJsonPayload(<@untainted>jsonPayload);
        http:Response httpResponse = <http:Response> check self.httpClient->put(<@untainted>requestPath, request);
        if (httpResponse.statusCode == http:STATUS_OK) {
            json jsonResponse = check httpResponse.getJsonPayload();
            return; 
        }
        return getErrorMessage(httpResponse);
    }

    # Gets the values in the given column of the worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + column - Position of Column (string notation) to retrieve the data
    # + return - Values of the given column in an array on success, else returns an error
    @display {label: "Get Column"}
    remote isolated function getColumn(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                       @display {label: "Worksheet Name"} string sheetName, 
                                       @display {label: "Position of Column"} string column) 
                                       returns @tainted @display {label: "Values"} (string|int|float)[]|error {
        (int | string | float)[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + column + COLON + column;
        string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        json | error response = sendRequest(self.httpClient, getColumnDataPath);
        if (response is error) {
            return response;
        } else {
            if (!(response.values is error)) {
                int i = 0;
                json|error jsonResponseValues = response.values;
                json[] jsonValues = [];
                if (jsonResponseValues is json) {
                    jsonValues = <json[]>jsonResponseValues;
                }
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

    # Deletes the given number of columns starting at the given column position by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, else returns an error
    @display {label: "Delete Columns By Sheet Id"}
    remote isolated function deleteColumns(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                           @display {label: "Worksheet Id"} int sheetId, 
                                           @display {label: "Starting Column Position"} int column, 
                                           @display {label: "Number of Columns to Delete"} int numberOfColumns) 
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

    # Deletes the given number of columns starting at the given column position by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, else returns an error
    @display {label: "Delete Columns By Sheet Name"}
    remote isolated function deleteColumnsBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                      @display {label: "Worksheet Name"} string sheetName, 
                                                      @display {label: "Starting Column Position"} int column, 
                                                      @display {label: "Number of Columns to Delete"} 
                                                      int numberOfColumns) 
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

    # Inserts the given number of rows before the given row position by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Rows Before By Sheet Id"}
    remote isolated function addRowsBefore(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                           @display {label: "Worksheet Id"} int sheetId, 
                                           @display {label: "Position of a Given Row"} int index, 
                                           @display {label: "Number of Rows to Insert"} int numberOfRows) 
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

    # Inserts the given number of rows before the given row position by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Rows Before By Sheet Name"}
    remote isolated function addRowsBeforeBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                      @display {label: "Worksheet Name"} string sheetName, 
                                                      @display {label: "Position of a Given Row"} int index, 
                                                      @display {label: "Number of Rows to Insert"} int numberOfRows) 
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

    # Inserts a number of rows after the given row position by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + index - The row after which the new rows should be added.
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Rows After By Sheet Id"}
    remote isolated function addRowsAfter(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                          @display {label: "Worksheet Id"} int sheetId, 
                                          @display {label: "Position of a Given Row"} int index, 
                                          @display {label: "Number of Rows to Insert"} int numberOfRows) 
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

    # Inserts a number of rows after the given row position by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + index - The row after which the new rows should be added.
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    @display {label: "Add Rows After"}
    remote isolated function addRowsAfterBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                     @display {label: "Worksheet Name"} string sheetName, 
                                                     @display {label: "Position of a Given Row"} int index, 
                                                     @display {label: "Number of Rows to Insert"} int numberOfRows) 
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
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + row - Position of row (integer notation) to set the data
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
    @display {label: "Create or Update Row"}
    remote isolated function createOrUpdateRow(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                               @display {label: "Worksheet Name"} string sheetName, 
                                               @display {label: "Position of Row"} int row, 
                                               @display {label: "Values for the Row"} (int|string|float)[] values) 
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
        request.setJsonPayload(<@untainted>jsonPayload);
        http:Response httpResponse = <http:Response> check self.httpClient->put(<@untainted>requestPath, request);
        if (httpResponse.statusCode == http:STATUS_OK) {
            json jsonResponse = check httpResponse.getJsonPayload();
            return; 
        }
        return getErrorMessage(httpResponse);
    }

    # Gets the values in the given row of the worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + row - Row number to retrieve the data
    # + return - Values of the given row in an array on success, else returns an error
    @display {label: "Get Row"}
    remote isolated function getRow(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                    @display {label: "Worksheet Name"} string sheetName, 
                                    @display {label: "Position of Row"} int row) 
                                    returns @tainted @display {label: "Row Values"} (string|int|float)[]|error {
        (int | string | float)[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + row.toString() + COLON + row.toString();
        string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        json | error response = sendRequest(self.httpClient, getRowDataPath);
        if (response is error) {
            return response;
        } else {
            if (!(response.values is error)) {
                int i = 0;
                json|error jsonResponseValues = response.values;
                json[] jsonValues = [];
                if (jsonResponseValues is json) {
                    jsonValues = <json[]>jsonResponseValues;
                }
                json[] jsonArray = <json[]>jsonValues[0];
                foreach json value in jsonArray {
                    values[i] = value.toString();
                    i = i + 1;
                }
            }
            return values;
        }
    }

    # Deletes the given number of rows starting at the given row position by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of rows from the starting position
    # + return - Nil on success, else returns an error
    @display {label: "Delete Rows By Sheet Id"}
    remote isolated function deleteRows(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                        @display {label: "Worksheet Id"} int sheetId, 
                                        @display {label: "Starting Row Position"} int row, 
                                        @display {label: "Number of Rows to Delete"} int numberOfRows) 
                                        returns @tainted error? {
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

    # Deletes the given number of rows starting at the given row position by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of rows from the starting position
    # + return - Nil on success, else returns an error
    @display {label: "Delete Rows By Sheet Name"}
    remote isolated function deleteRowsBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                   @display {label: "Worksheet Name"} string sheetName, 
                                                   @display {label: "Starting Row Position"} int row, 
                                                   @display {label: "Number of Rows to Delete"} int numberOfRows) 
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

    # Sets the value of the given cell of the worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required cell in A1 notation
    # + value - Value of the cell to be set
    # + return - Nil on success, else returns an error
    @display {label: "Set Cell"}
    remote isolated function setCell(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                     @display {label: "Worksheet Name"} string sheetName, 
                                     @display {label: "Required Cell in A1 Notation"} string a1Notation, 
                                     @display {label: "Value of the Cell"} int|string|float value) 
                                     returns @tainted error? {
        http:Request request = new;
        json jsonPayload = {"values": [[value]]};
        string notatiob = sheetName + EXCLAMATION_MARK + a1Notation;
        string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notatiob
        + QUESTION_MARK + VALUE_INPUT_OPTION;
        request.setJsonPayload(jsonPayload);
        http:Response|error httpResponse = self.httpClient->put(<@untainted>setCellDataPath, request);
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

    # Gets the value of the given cell of the sheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required cell in A1 notation
    # + return - Value of the given cell on success, else returns an error
    @display {label: "Get Cell"}
    remote isolated function getCell(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                     @display {label: "Worksheet Name"} string sheetName, 
                                     @display {label: "Required Cell A1 Notation"} string a1Notation) 
                                     returns @tainted @display {label: "Value"} int|string|float|error {
        int | string | float value = EMPTY_STRING;
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        json | error response = sendRequest(self.httpClient, getCellDataPath);
        if (response is error) {
            return response;
        } else {
            if (!(response.values is error)) {
                json|error jsonResponseValues = response.values;
                json[] responseValues = [];
                if (jsonResponseValues is json) {
                    responseValues = <json[]>jsonResponseValues;
                }
                json[] firstResponseValue = <json[]>responseValues[0];
                value = firstResponseValue[0].toString();
            }
            return value;
        }
    }

    # Clears the given cell of contents, formats, and data validation rules.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required cell in A1 notation
    # + return - Nil on success, else returns an error
    @display {label: "Clear Cell"}
    remote isolated function clearCell(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                       @display {label: "Worksheet name"} string sheetName, 
                                       @display {label: "Required Cell A1 Notation"} string a1Notation) 
                                       returns @tainted error? {
        return self->clearRange(spreadsheetId, sheetName, a1Notation);
    }

    # Adds a new row with the given values to the bottom of the worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
        @display {label: "Append Row To Sheet"}
    remote isolated function appendRowToSheet(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                              @display {label: "Worksheet Name"} string sheetName, 
                                              @display {label: "Values for the Row"} (int|string|float)[] values) 
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
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required range in A1 notation
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
    @display {label: "Append Row To Range"}
    remote isolated function appendRow(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                       @display {label: "Worksheet Name"} string sheetName, 
                                       @display {label: "Required Range A1 Notation"} string a1Notation, 
                                       @display {label: "Values for the Row"} (int|string|float)[] values) 
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
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + a1Notation - The required range in A1 notation
    # + value - Value of the cell to be added
    # + return - Nil on success, else returns an error
    @display {label: "Append Cell To Range"}
    remote isolated function appendCell(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                        @display {label: "Worksheet Name"} string sheetName, 
                                        @display {label: "Required Range A1 Notation"} string a1Notation, 
                                        @display {label: "Value for New Cell"} (int|string|float) value) 
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

    # Copies the sheet to a given spreadsheet by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + destinationId - Id of the spreadsheet to copy the sheet to
    # + return - Nil on success, else returns an error
    @display {label: "Copy Sheet By Sheet Id"}
    remote isolated function copyTo(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                    @display {label: "Worksheet Id"} int sheetId, 
                                    @display {label: "Destination Spreadsheet Id"} string destinationId) 
                                    returns @tainted error? {
        json payload = {"destinationSpreadsheetId": destinationId};
        string notation = sheetId.toString();
        string copyToPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + SHEETS_PATH + notation +
        COPY_TO_REQUEST;
        json | error response = sendRequestWithPayload(self.httpClient, copyToPath, payload);
        if (response is error) {
            return response;
        }
    }

    # Copies the sheet to a given spreadsheet by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + destinationId - Id of the spreadsheet to copy the sheet to
    # + return - Nil on success, else returns an error
    @display {label: "Copy Sheet By Sheet Name"}
    remote isolated function copyToBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                               @display {label: "Worksheet Name"} string sheetName, 
                                               @display {label: "Destination Spreadsheet Id"} string destinationId) 
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

    # Clears the worksheet content and formatting rules by worksheet Id.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - Id of the worksheet
    # + return - Nil on success, else returns an error
    @display {label: "Clear All By Sheet Id"}
    remote isolated function clearAll(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                      @display {label: "Worksheet Id"} int sheetId) returns @tainted error? {
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

    # Clears the worksheet content and formatting rules by worksheet name.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the worksheet
    # + return - Nil on success, else returns an error
    @display {label: "Clear All By Sheet Name"}
    remote isolated function clearAllBySheetName(@display {label: "Spreadsheet Id"} string spreadsheetId, 
                                                 @display {label: "Worksheet Name"} string sheetName) 
                                                 returns @tainted error? {
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
# + oauthClientConfig - OAuth client configuration
# + secureSocketConfig - Secure socket configuration
@display {label: "Connection Config"}
public type SpreadsheetConfiguration record {
    @display {label: "Auth Config"}
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig oauthClientConfig;
    @display {label: "SSL Config"}
    http:ClientSecureSocket secureSocketConfig?;
};

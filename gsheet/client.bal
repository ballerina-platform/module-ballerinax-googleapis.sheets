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
@display {label: "Google Sheets Client", iconPath: "GoogleSheetsLogo.png"}
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
    remote isolated function createSpreadsheet(@display {label: "Spreadsheet name"} string name) 
                                               returns @tainted @display {label: "Spreadsheet"} Spreadsheet|error {
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
    @display {label: "Open spreadsheet by ID"}
    remote isolated function openSpreadsheetById(@display {label: "Spreadsheet ID"} string spreadsheetId) 
                                                 returns @tainted @display {label: "Spreadsheet"} Spreadsheet|error {
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
    @display {label: "Open spreadsheet by URL"}
    remote isolated function openSpreadsheetByUrl(@display {label: "Spreadsheet URL"} string url) 
                                                  returns @tainted @display {label: "Spreadsheet"} Spreadsheet|error {
        string|error spreadsheetId = getIdFromUrl(url);
        if (spreadsheetId is string) {
            return self->openSpreadsheetById(spreadsheetId);
        } else {
            return getSpreadsheetError(spreadsheetId);
        }
    }

    # Get all Spreadsheet files.
    # 
    # + return - Array of files records on success, else returns an error
    @display {label: "Get all spreadsheets"}
    remote isolated function getAllSpreadsheets() returns @tainted @display {label: "Spreadsheets"} stream<File,error>|error {
        return new stream<File,error>(new SpreadsheetStream(self.driveClient));
    }

    # Renames the Spreadsheet with the given name.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + name - New name for the Spreadsheet
    # + return - Nil on success, else returns an error
    @display {label: "Rename spreadsheet"}
    remote isolated function renameSpreadsheet(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                               @display {label: "New name for Spreadsheet"} string name) 
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
    # + spreadsheetId - ID of the Spreadsheet
    # + return - Worksheet array on success and error on failure
    @display {label: "Get worksheets"}
    remote isolated function getSheets(@display {label: "Spreadsheet ID"} string spreadsheetId) 
                                       returns @tainted @display {label: "Spreadsheets"} Sheet[]|error {
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
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - Name of the worksheet to retrieve
    # + return - Sheet record type on success and error on failure
    @display {label: "Get worksheet by name"}
    remote isolated function getSheetByName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                            @display {label: "Worksheet name"} string sheetName) 
                                            returns @tainted @display {label: "Worksheet"} Sheet|error {
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
    # + sheetName - The name of the worksheet. It is an optional parameter.
    #               If the title is empty, then sheet will be created with the default name.
    # + return - Sheet record type on success and error on failure
    @display {label: "Add new worksheet"}
    remote isolated function addSheet(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                      @display {label: "Worksheet name"} string sheetName) 
                                      returns @tainted @display {label: "Worksheet"} Sheet|error {
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
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - The ID of the worksheet to delete
    # + return - Nil on success and error on failure
    @display {label: "Delete a worksheet by ID"}
    remote isolated function removeSheet(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                         @display {label: "Worksheet ID"} int sheetId) returns @tainted error? {
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
    # + sheetName - The name of the worksheet to delete
    # + return - Nil on success and error on failure
    @display {label: "Delete a worksheet by name"}
    remote isolated function removeSheetByName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                               @display {label: "Worksheet name"} string sheetName) 
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

    # Renames the worksheet of the spreadsheet with the given name.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + name - New name for the worksheet
    # + return - Nil on success, else returns an error
    @display {label: "Rename worksheet"}
    remote isolated function renameSheet(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                         @display {label: "Existing name for worksheet"} string sheetName, 
                                         @display {label: "New name for worksheet"} string name) 
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

    # Sets the values of the given range of cells of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + range - The range to be set
    # + return - Nil on success, else returns an error
    @display {label: "Set the values of a given range of cells"}
    remote isolated function setRange(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                      @display {label: "Worksheet name"} string sheetName, 
                                      @display {label: "Range to set"} Range range) returns @tainted error? {
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

    # Gets the given range of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required range in A1 notation
    # + return - The range on success, else returns an error
    @display {label: "Get a given range of a worksheet"}
    remote isolated function getRange(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                      @display {label: "Worksheet name"} string sheetName, 
                                      @display {label: "Required range in A1 notation"} string a1Notation) 
                                      returns @tainted @display {label: "Range"} Range|error {
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
    @display {label: "Clear contents, formats and rules in a range"}
    remote isolated function clearRange(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                        @display {label: "Worksheet name"} string sheetName, 
                                        @display {label: "Required range in A1 notation"} string a1Notation) 
                                        returns @tainted error? {
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
    @display {label: "Insert columns before given column position by worksheet ID"}
    remote isolated function addColumnsBefore(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                              @display {label: "Worksheet ID"} int sheetId, 
                                              @display {label: "Position of given column"} int index, 
                                              @display {label: "Number of columns to insert"} int numberOfColumns) 
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
    @display {label: "Insert columns before a given column position by worksheet name"}
    remote isolated function addColumnsBeforeBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                         @display {label: "Worksheet name"} string sheetName, 
                                                         @display {label: "Position of column"} int index, 
                                                         @display {label: "Number of columns to insert"} 
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

    # Inserts the given number of columns after the given column position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    @display {label: "Insert columns after given column position by worksheet ID"}
    remote isolated function addColumnsAfter(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                             @display {label: "Worksheet ID"} int sheetId, 
                                             @display {label: "Position of column"} int index, 
                                             @display {label: "Number of columns to insert"} int numberOfColumns) 
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
    @display {label: "Insert columns after given column position by worksheet name"}
    remote isolated function addColumnsAfterBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                        @display {label: "Worksheet name"} string sheetName, 
                                                        @display {label: "Position of column"} int index, 
                                                        @display {label: "Number of columns to insert"} 
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
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + column - Column number to set the data
    # + values - Array of values of the column to be added
    # + return - Nil on success, else returns an error
    @display {label: "Create or update new column with given values"}
    remote isolated function createOrUpdateColumn(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                  @display {label: "Worksheet name"} string sheetName, 
                                                  @display {label: "Column number"} string column, 
                                                  @display {label: "Values for new column"} (int|string|float)[] values) 
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

    # Gets the values in the given column of the sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + column - Column number to retrieve the data
    # + return - Values of the given column in an array on success, else returns an error
    @display {label: "Get values from a column"}
    remote isolated function getColumn(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                       @display {label: "Worksheet name"} string sheetName, 
                                       @display {label: "Column number"} string column) 
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

    # Deletes the given number of columns starting at the given column position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, else returns an error
    @display {label: "Delete columns by worksheet ID"}
    remote isolated function deleteColumns(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                           @display {label: "Worksheet ID"} int sheetId, 
                                           @display {label: "Starting column"} int column, 
                                           @display {label: "Number of columns to delete"} int numberOfColumns) 
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
    @display {label: "Delete columns by worksheet name"}
    remote isolated function deleteColumnsBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                      @display {label: "Worksheet name"} string sheetName, 
                                                      @display {label: "Starting column"} int column, 
                                                      @display {label: "Number of columns to Delete"} 
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

    # Inserts the given number of rows before the given row position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    @display {label: "Insert rows before a given row position by worksheet ID"}
    remote isolated function addRowsBefore(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                           @display {label: "Worksheet ID"} int sheetId, 
                                           @display {label: "Position of a given row"} int index, 
                                           @display {label: "Number of rows to insert"} int numberOfRows) 
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
    @display {label: "Insert rows before given row position by worksheet name"}
    remote isolated function addRowsBeforeBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                      @display {label: "Worksheet name"} string sheetName, 
                                                      @display {label: "Position of a given row"} int index, 
                                                      @display {label: "Number of rows to insert"} int numberOfRows) 
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
    @display {label: "Insert rows after given row position by worksheet ID"}
    remote isolated function addRowsAfter(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                          @display {label: "Worksheet ID"} int sheetId, 
                                          @display {label: "Position of a given row"} int index, 
                                          @display {label: "Number of rows to insert"} int numberOfRows) 
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
    @display {label: "Insert rows after given row position by worksheet name"}
    remote isolated function addRowsAfterBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                     @display {label: "Worksheet name"} string sheetName, 
                                                     @display {label: "Position of a given row"} int index, 
                                                     @display {label: "Number of rows to insert"} int numberOfRows) 
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
    @display {label: "Create or update a row with given values"}
    remote isolated function createOrUpdateRow(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                               @display {label: "Worksheet name"} string sheetName, 
                                               @display {label: "Row number"} int row, 
                                               @display {label: "Values for new row"} (int|string|float)[] values) 
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

    # Gets the values in the given row of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + row - Row number to retrieve the data
    # + return - Values of the given row in an array on success, else returns an error
    @display {label: "Get values in a row"}
    remote isolated function getRow(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                    @display {label: "Worksheet name"} string sheetName, 
                                    @display {label: "Row number"} int row) 
                                    returns @tainted @display {label: "Values in row"} (string|int|float)[]|error {
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

    # Deletes the given number of rows starting at the given row position.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetId - ID of the Worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of row from the starting position
    # + return - Nil on success, else returns an error
    @display {label: "Delete rows by sheet ID"}
    remote isolated function deleteRows(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                        @display {label: "Worksheet ID"} int sheetId, 
                                        @display {label: "Starting row"} int row, 
                                        @display {label: "Number of rows to delete"} int numberOfRows) 
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

    # Deletes the given number of rows starting at the given row position by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + row - Starting position of the rows
    # + numberOfRows - Number of row from the starting position
    # + return - Nil on success, else returns an error
    @display {label: "Delete rows by sheet name"}
    remote isolated function deleteRowsBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                   @display {label: "Worksheet name"} string sheetName, 
                                                   @display {label: "Starting row"} int row, 
                                                   @display {label: "Number of rows to delete"} int numberOfRows) 
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
    @display {label: "Set value to a cell"}
    remote isolated function setCell(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                     @display {label: "Worksheet name"} string sheetName, 
                                     @display {label: "Required cell in A1 notation"} string a1Notation, 
                                     @display {label: "Value of the cell to set"} int|string|float value) 
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

    # Gets the value of the given cell of the Sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required cell in A1 notation
    # + return - Value of the given cell on success, else returns an error
    @display {label: "Get value in a cell"}
    remote isolated function getCell(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                     @display {label: "Worksheet name"} string sheetName, 
                                     @display {label: "Required cell in A1 notation"} string a1Notation) 
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
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + a1Notation - The required cell in A1 notation
    # + return - Nil on success, else returns an error
    @display {label: "Clear contents, formats and rules in cell"}
    remote isolated function clearCell(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                       @display {label: "Worksheet name"} string sheetName, 
                                       @display {label: "Required cell in A1 notation"} string a1Notation) 
                                       returns @tainted error? {
        return self->clearRange(spreadsheetId, sheetName, a1Notation);
    }

    # Adds a new row with the given values to the bottom of the sheet.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
        @display {label: "Add new row with given values to the bottom of the worksheet"}
    remote isolated function appendRowToSheet(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                              @display {label: "Worksheet name"} string sheetName, 
                                              @display {label: "Values for new row"} (int|string|float)[] values) 
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
    @display {label: "Add new row with values to the bottom of a given range"}
    remote isolated function appendRow(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                       @display {label: "Worksheet name"} string sheetName, 
                                       @display {label: "Required range in A1 notation"} string a1Notation, 
                                       @display {label: "Values for new row"} (int|string|float)[] values) 
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
    @display {label: "Add new cell with values to the bottom of a given range"}
    remote isolated function appendCell(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                        @display {label: "Worksheet name"} string sheetName, 
                                        @display {label: "Required range in A1 notation"} string a1Notation, 
                                        @display {label: "Value for new cell"} (int|string|float) value) 
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
    @display {label: "Copy sheet to a given spreadsheet by worksheet ID"}
    remote isolated function copyTo(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                    @display {label: "Worksheet ID"} int sheetId, 
                                    @display {label: "Destination spreadsheet ID"} string destinationId) 
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

    # Copies the Sheet to a given Spreadsheet by worksheet name as input.
    #
    # + spreadsheetId - ID of the Spreadsheet
    # + sheetName - The name of the Worksheet
    # + destinationId - ID of the Spreadsheet to copy the sheet to
    # + return - Nil on success, else returns an error
    @display {label: "Copy sheet to given spreadsheet by worksheet name"}
    remote isolated function copyToBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                               @display {label: "Worksheet name"} string sheetName, 
                                               @display {label: "Destination spreadsheet ID"} string destinationId) 
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
    @display {label: "Clear content and formatting rules in a worksheet by worksheet ID"}
    remote isolated function clearAll(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                      @display {label: "Worksheet ID"} int sheetId) returns @tainted error? {
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
    @display {label: "Clear content and formatting rules in a worksheet by worksheet name"}
    remote isolated function clearAllBySheetName(@display {label: "Spreadsheet ID"} string spreadsheetId, 
                                                 @display {label: "Worksheet name"} string sheetName) 
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
public type SpreadsheetConfiguration record {
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig oauthClientConfig;
    http:ClientSecureSocket secureSocketConfig?;
};

// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# Ballerina public API to provide Google Spreadsheet - Sheet related functionality.
public type Sheet client object {
    SheetProperties properties;
    Client clientEp;
    http:Client httpClient;
    string parentId;
    string name;
    int id;

    public function __init(SheetProperties sheetProperties, Client connectorClient, string spreadsheetId) {
        self.properties = sheetProperties;
        self.clientEp = connectorClient;
        self.httpClient = connectorClient.httpClient;
        self.parentId = spreadsheetId;
        self.name = sheetProperties.title;
        self.id = sheetProperties.sheetId;
    }

    # Gets the properties of the Sheet.
    #
    # + return - Properties of the Sheet
    public function getProperties() returns SheetProperties {
        return self.properties;
    }

    # Gets the given range of the Sheet.
    #
    # + a1Notation - The required range in A1 notation
    # + return - The range on success, else returns an error
    public remote function getRange(string a1Notation) returns @tainted Range | error {
        (string | int | float)[][] values = [];
        string notation = self.name;
        if (a1Notation == EMPTY_STRING) {
            error err = error(SPREADSHEET_ERROR_CODE,
            message = "Invalid range notation");
            return err;
        }
        notation = notation + EXCLAMATION_MARK + a1Notation;
        string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH +
        notation;
        var httpResponse = self.httpClient->get(<@untainted>getSheetValuesPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        int i = 0;
                        json[] jsonValues = <json[]>jsonResponse.values;
                        foreach json value in jsonValues {
                            json[] jsonValArray = <json[]>value;
                            int j = 0;
                            (string | int | float)[] val = [];
                            foreach json v in jsonValArray {
                                val[j] = getConvertedValue(v);
                                j = j + 1;
                            }
                            values[i] = val;
                            i = i + 1;
                        }
                    }
                    Range range = {a1Notation: a1Notation, values: values};
                    return range;
                } else {
                    return setResponseError(jsonResponse);
                }
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Sets the values of the given range of cells of the Sheet.
    #
    # + range - The range to be set
    # + return - Nil on success, else returns an error
    public remote function setRange(Range range) returns @tainted error? {
        (string | int | float)[][] values = range.values;
        string a1Notation = range.a1Notation;
        http:Request request = new;
        string notation = self.name;
        if (a1Notation == EMPTY_STRING) {
            error err = error(SPREADSHEET_ERROR_CODE,
            message = "Invalid range notation");
            return err;
        }
        notation = notation + EXCLAMATION_MARK + a1Notation;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH + notation
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
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Gets the values in the given column of the sheet.
    #
    # + column - Column number to retrieve the data
    # + return - Values of the given column in an array on success, else returns an error
    public remote function getColumn(string column) returns @tainted (string | int | float)[] | error {
        (int | string | float)[] values = [];
        string a1Notation = self.name + EXCLAMATION_MARK + column + COLON + column;
        string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH + a1Notation;
        var httpResponse = self.httpClient->get(<@untainted>getColumnDataPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        int i = 0;
                        json[] jsonValues = <json[]>jsonResponse.values;
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
                } else {
                    return setResponseError(jsonResponse);
                }
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Gets the values in the given row of the Sheet.
    #
    # + row - Row number to retrieve the data
    # + return - Values of the given row in an array on success, else returns an error
    public remote function getRow(int row) returns @tainted (string | int | float)[] | error {
        (int | string | float)[] values = [];
        string a1Notation = self.name + EXCLAMATION_MARK + row.toString() + COLON + row.toString();
        string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH + a1Notation;
        var httpResponse = self.httpClient->get(<@untainted>getRowDataPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        int i = 0;
                        json[] jsonValues = <json[]>jsonResponse.values;
                        json[] jsonArray = <json[]>jsonValues[0];
                        foreach json value in jsonArray {
                            values[i] = value.toString();
                            i = i + 1;
                        }
                    }
                    return values;
                } else {
                    return setResponseError(jsonResponse);
                }
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Gets the value of the given cell of the Sheet.
    #
    # + a1Notation - The required cell in A1 notation
    # + return - Value of the given cell on success, else returns an error
    public remote function getCell(string a1Notation) returns @tainted int | string | float | error {
        int | string | float value = EMPTY_STRING;
        string notation = self.name + EXCLAMATION_MARK + a1Notation;
        string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH + notation;
        var httpResponse = self.httpClient->get(<@untainted>getCellDataPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            json | error jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        json[] responseValues = <json[]>jsonResponse.values;
                        json[] firstResponseValue = <json[]>responseValues[0];
                        value = firstResponseValue[0].toString();
                    }
                    return value;
                } else {
                    return setResponseError(jsonResponse);
                }
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Sets the value of the given cell of the sheet.
    #
    # + a1Notation - The required cell in A1 notation
    # + value - Value of the cell to be set
    # + return - Nil on success, else returns an error
    public remote function setCell(string a1Notation, int | string | float value) returns @tainted error? {
        http:Request request = new;
        json jsonPayload = {"values": [[value]]};
        string notatiob = self.name + EXCLAMATION_MARK + a1Notation;
        string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH + a1Notation
        + QUESTION_MARK + VALUE_INPUT_OPTION;
        request.setJsonPayload(jsonPayload);
        var httpResponse = self.httpClient->put(<@untainted>setCellDataPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return setResponse(jsonResponse, statusCode);
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return setResError(httpResponse);
        }
    }

    # Updates the sheet name.
    #
    # + name - The new name for the sheet
    # + return - Nil on success, else returns an error
    public remote function rename(string name) returns @tainted error? {
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [{
                "updateSheetProperties": {
                    "properties": {"title": name},
                    "fields": "title"
                }
            }]
        };
        request.setJsonPayload(sheetJSONPayload);
        string renamePath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(<@untainted>renamePath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                self.properties.title = name;
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Clears the sheet content and formatting rules.
    #
    # + return - Nil on success, else returns an error
    public remote function clearAll() returns error? {
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [{
                "updateCells": {
                    "range": {
                        "sheetId": self.id
                    },
                    "fields": "*"
                }
            }]
        };
        request.setJsonPayload(sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Clears the range of contents, formats, and data validation rules.
    #
    # + a1Notation - The required range in A1 notation
    # + return - Nil on success, else returns an error
    public remote function clearRange(string a1Notation) returns error? {
        string notation = self.name + EXCLAMATION_MARK + a1Notation;
        http:Request request = new;
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH +
        notation + CLEAR_REQUEST;
        var httpResponse = self.httpClient->post(deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Clears the given cell of contents, formats, and data validation rules.
    #
    # + a1Notation - The required cell in A1 notation
    # + return - Nil on success, else returns an error
    public remote function clearCell(string a1Notation) returns error? {
        return self->clearRange(a1Notation);
    }

    # Adds a new row with the given values to the bottom of the sheet.
    #
    # + values - Array of values of the row to be added
    # + return - Nil on success, else returns an error
    public remote function appendRow((int | string | float)[] values) returns @tainted error? {
        http:Request request = new;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + VALUES_PATH + self.name + APPEND_REQUEST;
        json[] jsonValues = [];
        int i = 0;
        foreach (string | int | float) value in values {
            jsonValues[i] = value;
            i = i + 1;
        }
        json jsonPayload = {"values": jsonValues};
        request.setJsonPayload(<@untainted>jsonPayload);
        var httpResponse = self.httpClient->put(setValuePath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return setResponse(jsonResponse, statusCode);
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Copies the Sheet to a given Spreadsheet.
    #
    # + spreadsheet - Spreadsheet to copy the sheet to
    # + return - Nil on success, else returns an error
    public remote function copyTo(Spreadsheet spreadsheet) returns @tainted error? {
        string destinationId = spreadsheet.spreadsheetId;
        http:Request request = new;
        json jsonPayload = {"destinationSpreadsheetId": destinationId};
        string notation = self.id.toString();
        string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + SHEETS_PATH + notation +
        COPY_TO_REQUEST;
        request.setJsonPayload(jsonPayload);
        var httpResponse = self.httpClient->put(setCellDataPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return setResponse(jsonResponse, statusCode);
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return setResError(httpResponse);
        }
    }

    # Deletes the given number of columns starting at the given column position.
    #
    # + column - Starting position of the columns
    # + numberOfColumns - Number of columns from the starting position
    # + return - Nil on success, else returns an error
    public remote function deleteColumns(int column, int numberOfColumns)
    returns error? {
        int startIndex = column;
        int endIndex = startIndex + numberOfColumns;
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [
            {
                "deleteDimension": {
                    "range": {
                        "sheetId": self.id,
                        "dimension": "COLUMNS",
                        "startIndex": startIndex,
                        "endIndex": endIndex
                    }
                }
            }
            ]
        };
        request.setJsonPayload(sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }



    # Deletes the given number of rows starting at the given row position.
    #
    # + row - Starting position of the rows
    # + numberOfRows - Number of row from the starting position
    # + return - Nil on success, else returns an error
    public remote function deleteRows(int row, int numberOfRows) returns error? {
        http:Request request = new;
        int startIndex = row;
        int endIndex = startIndex + numberOfRows;
        json sheetJSONPayload = {
            "requests": [
            {
                "deleteDimension": {
                    "range": {
                        "sheetId": self.id,
                        "dimension": "ROWS",
                        "startIndex": startIndex,
                        "endIndex": endIndex
                    }
                }
            }
            ]
        };
        request.setJsonPayload(sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Inserts the given number of columns after the given column position.
    #
    # + index - The position of the column after which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    public remote function addColumnsAfter(int index, int numberOfColumns)
    returns error? {
        int startIndex = index;
        int endIndex = startIndex + numberOfColumns;
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [
            {
                "insertDimension": {
                    "range": {
                        "sheetId": self.id,
                        "dimension": "COLUMNS",
                        "startIndex": startIndex,
                        "endIndex": endIndex
                    }
                }
            }
            ]
        };
        request.setJsonPayload(<@untainted>sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(<@untainted>deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Inserts the given number of columns before the given column position.
    #
    # + index - The position of the column before which the new columns should be added
    # + numberOfColumns - Number of columns to be added
    # + return - Nil on success, else returns an error
    public remote function addColumnsBefore(int index, int numberOfColumns)
    returns error? {
        int startIndex = index - 1;
        int endIndex = startIndex + numberOfColumns;
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [
            {
                "insertDimension": {
                    "range": {
                        "sheetId": self.id,
                        "dimension": "COLUMNS",
                        "startIndex": startIndex,
                        "endIndex": endIndex
                    }
                }
            }
            ]
        };
        request.setJsonPayload(<@untainted>sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(<@untainted>deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Inserts the given number of rows before the given row position.
    #
    # + index - The position of the row before which the new rows should be added
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    public remote function addRowsBefore(int index, int numberOfRows) returns error? {
        int startIndex = index - 1;
        int endIndex = startIndex + numberOfRows;
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [
            {
                "insertDimension": {
                    "range": {
                        "sheetId": self.id,
                        "dimension": "ROWS",
                        "startIndex": startIndex,
                        "endIndex": endIndex
                    }
                }
            }
            ]
        };
        request.setJsonPayload(<@untainted>sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(<@untainted>deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }

    # Inserts a number of rows after the given row position.
    #
    # + index - The row after which the new rows should be added.
    # + numberOfRows - The number of rows to be added
    # + return - Nil on success, else returns an error
    public remote function addRowsAfter(int index, int numberOfRows) returns error? {
        int startIndex = index;
        int endIndex = startIndex + numberOfRows;
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [
            {
                "insertDimension": {
                    "range": {
                        "sheetId": self.id,
                        "dimension": "ROWS",
                        "startIndex": startIndex,
                        "endIndex": endIndex
                    }
                }
            }
            ]
        };
        request.setJsonPayload(<@untainted>sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.parentId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(<@untainted>deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                return ();
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return createConnectorError(httpResponse);
        }
    }
};

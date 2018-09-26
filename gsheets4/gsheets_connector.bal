// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/mime;
import ballerina/http;

# Spreadsheet client Connector.
# + httpClient - The HTTP Client
public type SpreadsheetConnector object {

    public http:Client httpClient = new;

    # Create a new spreadsheet.
    # + spreadsheetName - Name of the spreadsheet
    # + return - Spreadsheet object on success and SpreadsheetError on failure
    public function createSpreadsheet(string spreadsheetName) returns Spreadsheet|SpreadsheetError;

    # Get a spreadsheet by ID.
    # + spreadsheetId - Id of the spreadsheet
    # + return - Spreadsheet object on success and SpreadsheetError on failure
    public function openSpreadsheetById(string spreadsheetId) returns Spreadsheet|SpreadsheetError;

    # Add a new worksheet.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the sheet. It is an optional parameter. If the title is empty, then sheet will be created with the default name.
    # + return - Sheet object on success and SpreadsheetError on failure
    public function addNewSheet(string spreadsheetId, string sheetName)
                        returns Sheet|SpreadsheetError;

    # Delete specified worksheet.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - The ID of the sheet to delete
    # + return - Sheet object on success and SpreadsheetError on failure
    public function deleteSheet(string spreadsheetId, int sheetId) returns boolean|SpreadsheetError;

    # Get spreadsheet values.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + topLeftCell - Top left cell
    # + bottomRightCell - Bottom right cell
    # + return - Sheet values as a two dimensional array on success and SpreadsheetError on failure
    public function getSheetValues(string spreadsheetId, string sheetName, string topLeftCell, string bottomRightCell)
                        returns (string[][])|SpreadsheetError;

    # Get column data.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to retrieve the data
    # + return - Column data as an array on success and SpreadsheetError on failure
    public function getColumnData(string spreadsheetId, string sheetName, string column)
                        returns (string[])|SpreadsheetError;

    # Get row data.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + row - Row name to retrieve the data
    # + return - Row data as an array on success and SpreadsheetError on failure
    public function getRowData(string spreadsheetId, string sheetName, int row)
                        returns (string[])|SpreadsheetError;

    # Get cell data.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - column
    # + row - Row name to retrieve the data
    # + return - Cell data on success and SpreadsheetError on failure
    public function getCellData(string spreadsheetId, string sheetName, string column, int row)
                        returns (string)|SpreadsheetError;

    # Set cell data.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to set the data
    # + row - Row name to set the data
    # + value - The value to be updated
    # + return - True on success and SpreadsheetError on failure
    public function setCellData(string spreadsheetId, string sheetName, string column, int row, string value)
                        returns (boolean)|SpreadsheetError;

    # Set spreadsheet values.
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + topLeftCell - Top left cell
    # + bottomRightCell - Bottom right cell
    # + values - Values to be updated
    # + return - True on success and SpreadsheetError on failure
    public function setSheetValues(string spreadsheetId, string sheetName, string topLeftCell, string bottomRightCell,
                                   string[][] values) returns (boolean)|SpreadsheetError;
};

function SpreadsheetConnector::createSpreadsheet(string spreadsheetName) returns Spreadsheet|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    Spreadsheet spreadsheetResponse = new;
    SpreadsheetError spreadsheetError = {};
    json spreadsheetJSONPayload = { "properties": { "title": spreadsheetName } };
    request.setJsonPayload(spreadsheetJSONPayload);
    var httpResponse = httpClient->post(SPREADSHEET_PATH, request);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        spreadsheetResponse = convertToSpreadsheet(jsonResponse);
                        return spreadsheetResponse;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::openSpreadsheetById(string spreadsheetId) returns Spreadsheet|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    Spreadsheet spreadsheetResponse = new;
    SpreadsheetError spreadsheetError = {};
    string getSpreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
    var httpResponse = httpClient->get(getSpreadsheetPath);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        spreadsheetResponse = convertToSpreadsheet(jsonResponse);
                        return spreadsheetResponse;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::addNewSheet(string spreadsheetId, string sheetName)
                                          returns Sheet|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    Sheet newSheet = {};
    SpreadsheetError spreadsheetError = {};
    json sheetJSONPayload = { "requests": [{ "addSheet": { "properties": {} } }] };
    json jsonSheetProperties = {};
    if (sheetName != EMPTY_STRING) {
        jsonSheetProperties.title = sheetName;
    }
    sheetJSONPayload.requests[0].addSheet.properties = jsonSheetProperties;
    request.setJsonPayload(sheetJSONPayload);
    string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
    var httpResponse = httpClient->post(addSheetPath, request);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var sheetJSONResponse = response.getJsonPayload();
            match sheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        newSheet = convertToSheet(jsonResponse.replies[0].addSheet);
                        return newSheet;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::deleteSheet(string spreadsheetId, int sheetId)
                                          returns boolean|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    Sheet newSheet = {};
    SpreadsheetError spreadsheetError = {};
    json sheetJSONPayload = { "requests": [{ "deleteSheet": { "sheetId": sheetId } }] };
    request.setJsonPayload(sheetJSONPayload);
    string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
    var httpResponse = httpClient->post(addSheetPath, request);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var sheetJSONResponse = response.getJsonPayload();
            match sheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        return true;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::getSheetValues(string spreadsheetId, string sheetName, string topLeftCell,
                                                     string bottomRightCell) returns (string[][])|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string[][] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName;
    if (topLeftCell != EMPTY_STRING && topLeftCell != null) {
        a1Notation = a1Notation + "!" + topLeftCell;
    }
    if (bottomRightCell != EMPTY_STRING && bottomRightCell != null) {
        a1Notation = a1Notation + ":" + bottomRightCell;
    }
    string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getSheetValuesPath);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        if (jsonResponse.values != null) {
                            int i = 0;
                            foreach value in jsonResponse.values {
                                int j = 0;
                                string[] val = [];
                                foreach v in value {
                                    val[j] = v.toString();
                                    j = j + 1;
                                }
                                values[i] = val;
                                i = i + 1;
                            }
                        }
                        return values;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::getColumnData(string spreadsheetId, string sheetName, string column)
                                          returns (string[])|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + ":" + column;
    string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getColumnDataPath);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        if (jsonResponse.values != null) {
                            int i = 0;
                            foreach value in jsonResponse.values {
                                if (lengthof value > 0) {
                                    values[i] = value[0].toString();
                                } else {
                                    values[i] = EMPTY_STRING;
                                }
                                i = i + 1;
                            }
                        }
                        return values;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::getRowData(string spreadsheetId, string sheetName, int row)
                                          returns (string[])|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + row + ":" + row;
    string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getRowDataPath);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        if (jsonResponse.values != null) {
                            int i = 0;
                            foreach value in jsonResponse.values[0] {
                                values[i] = value.toString();
                                i = i + 1;
                            }
                        }
                        return values;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::getCellData(string spreadsheetId, string sheetName, string column, int row)
                                          returns (string)|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string value = EMPTY_STRING;
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + row;
    string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getCellDataPath);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        if (jsonResponse.values != null) {
                            value = jsonResponse.values[0][0].toString();
                        }
                        return value;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::setCellData(string spreadsheetId, string sheetName, string column, int row,
                                                  string value) returns (boolean)|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    SpreadsheetError spreadsheetError = {};
    json jsonPayload = { "values": [[value]] };
    string a1Notation = sheetName + "!" + column + row;
    string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation
        + QUESTION_MARK + VALUE_INPUT_OPTION;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->put(setCellDataPath, request);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        return true;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

function SpreadsheetConnector::setSheetValues(string spreadsheetId, string sheetName, string topLeftCell,
                                                     string bottomRightCell, string[][] values)
                                          returns (boolean)|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName;
    if (topLeftCell != EMPTY_STRING && topLeftCell != null) {
        a1Notation = a1Notation + "!" + topLeftCell;
    }
    if (bottomRightCell != EMPTY_STRING && bottomRightCell != null) {
        a1Notation = a1Notation + ":" + bottomRightCell;
    }
    string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation + QUESTION_MARK
        + VALUE_INPUT_OPTION;
    json[][] jsonValues = [];
    int i = 0;
    foreach value in values {
        int j = 0;
        json[] val = [];
        foreach v in value {
            val[j] = v;
            j = j + 1;
        }
        jsonValues[i] = val;
        i = i + 1;
    }
    json jsonPayload = { "values": jsonValues };
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->put(setValuePath, request);
    match httpResponse {
        error err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                error err => {
                    spreadsheetError.message = "Error occured while extracting Json Payload";
                    spreadsheetError.cause = err.cause;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == http:OK_200) {
                        return true;
                    } else {
                        spreadsheetError.message = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

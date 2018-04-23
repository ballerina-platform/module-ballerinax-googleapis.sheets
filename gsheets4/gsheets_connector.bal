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

documentation {Spreadsheet client connector
    F{{httpClient}} - The HTTP Client
}
public type SpreadsheetConnector object {
    public {
        http:Client httpClient = new;
    }

    documentation {Create a new spreadsheet
        P{{spreadsheetName}} - Name of the spreadsheet
        R{{}} - Spreadsheet object on success and SpreadsheetError on failure
    }
    public function createSpreadsheet(string spreadsheetName) returns Spreadsheet|SpreadsheetError;

    documentation {Get a spreadsheet by ID
        P{{spreadsheetId}} - Id of the spreadsheet
        R{{}} - Spreadsheet object on success and SpreadsheetError on failure
    }
    public function openSpreadsheetById(string spreadsheetId) returns Spreadsheet|SpreadsheetError;

    documentation {Get spreadsheet values
        P{{spreadsheetId}} - Id of the spreadsheet
        P{{sheetName}} - Name of the sheet
        P{{topLeftCell}} - Top left cell
        P{{bottomRightCell}} - Bottom right cell
        R{{}} - Sheet values as a two dimensional array on success and SpreadsheetError on failure
    }
    public function getSheetValues(string spreadsheetId, string sheetName, string topLeftCell, string bottomRightCell)
                                                     returns (string[][])|SpreadsheetError;

    documentation {Get column data
        P{{spreadsheetId}} - Id of the spreadsheet
        P{{sheetName}} - Name of the sheet
        P{{column}} - Column name to retrieve the data
        R{{}} - Column data as an array on success and SpreadsheetError on failure
    }
    public function getColumnData(string spreadsheetId, string sheetName, string column)
                                                     returns (string[])|SpreadsheetError;

    documentation {Get row data
        P{{spreadsheetId}} - Id of the spreadsheet
        P{{sheetName}} - Name of the sheet
        P{{row}} - Row name to retrieve the data
        R{{}} - Row data as an array on success and SpreadsheetError on failure
    }
    public function getRowData(string spreadsheetId, string sheetName, int row)
                                                     returns (string[])|SpreadsheetError;

    documentation {Get cell data
        P{{spreadsheetId}} - Id of the spreadsheet
        P{{sheetName}} - Name of the sheet
        P{{column}} - Column name to retrieve the data
        P{{row}} - Row name to retrieve the data
        R{{}} - Cell data on success and SpreadsheetError on failure
    }
    public function getCellData(string spreadsheetId, string sheetName, string column, int row)
                                                     returns (string)|SpreadsheetError;

    documentation {Set cell data
        P{{spreadsheetId}} - Id of the spreadsheet
        P{{sheetName}} - Name of the sheet
        P{{column}} - Column name to set the data
        P{{row}} - Row name to set the data
        P{{value}} - The value to be updated
        R{{}} - True on success and SpreadsheetError on failure
    }
    public function setCellData(string spreadsheetId, string sheetName, string column, int row, string value)
                                                     returns (boolean)|SpreadsheetError;

    documentation {Set spreadsheet values
        P{{spreadsheetId}} - Id of the spreadsheet
        P{{sheetName}} - Name of the sheet
        P{{topLeftCell}} - Top left cell
        P{{bottomRightCell}} - Bottom right cell
        P{{values}} - Values to be updated
        R{{}} - True on success and SpreadsheetError on failure
    }
    public function setSheetValues(string spreadsheetId, string sheetName, string topLeftCell, string bottomRightCell,
                                                     string[][] values) returns (boolean)|SpreadsheetError;
};

public function SpreadsheetConnector::createSpreadsheet(string spreadsheetName) returns Spreadsheet|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    Spreadsheet spreadsheetResponse = new;
    SpreadsheetError spreadsheetError = {};
    json spreadsheetJSONPayload = {"properties":{"title":spreadsheetName}};
    request.setJsonPayload(spreadsheetJSONPayload);
    var httpResponse = httpClient->post(SPREADSHEET_PATH, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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

public function SpreadsheetConnector::openSpreadsheetById(string spreadsheetId) returns Spreadsheet|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    Spreadsheet spreadsheetResponse = new;
    SpreadsheetError spreadsheetError = {};
    string getSpreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
    var httpResponse = httpClient->get(getSpreadsheetPath, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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

public function SpreadsheetConnector::getSheetValues(string spreadsheetId, string sheetName, string topLeftCell,
                                                     string bottomRightCell) returns (string[][])|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string[][] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName;
    if (topLeftCell != "" && topLeftCell != null) {
        a1Notation = a1Notation + "!" + topLeftCell;
    }
    if (bottomRightCell != "" && bottomRightCell != null) {
        a1Notation = a1Notation + ":" + bottomRightCell;
    }
    string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getSheetValuesPath, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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

public function SpreadsheetConnector::getColumnData(string spreadsheetId, string sheetName, string column)
                                                     returns (string[])|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + ":" + column;
    string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getColumnDataPath, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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
                                    values[i] = "";
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

public function SpreadsheetConnector::getRowData(string spreadsheetId, string sheetName, int row)
                                                     returns (string[])|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + row + ":" + row;
    string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getRowDataPath, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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

public function SpreadsheetConnector::getCellData(string spreadsheetId, string sheetName, string column, int row)
                                                     returns (string)|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    string value = "";
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + row;
    string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getCellDataPath, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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

public function SpreadsheetConnector::setCellData(string spreadsheetId, string sheetName, string column, int row,
                                                  string value) returns (boolean)|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    SpreadsheetError spreadsheetError = {};
    json jsonPayload = {"values":[[value]]};
    string a1Notation = sheetName + "!" + column + row;
    string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation
        + QUESTION_MARK + VALUE_INPUT_OPTION;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->put(setCellDataPath, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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

public function SpreadsheetConnector::setSheetValues(string spreadsheetId, string sheetName, string topLeftCell,
                                                     string bottomRightCell, string[][] values)
                                                     returns (boolean)|SpreadsheetError {
    endpoint http:Client httpClient = self.httpClient;
    http:Request request = new;
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName;
    if (topLeftCell != "" && topLeftCell != null) {
        a1Notation = a1Notation + "!" + topLeftCell;
    }
    if (bottomRightCell != "" && bottomRightCell != null) {
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
    json jsonPayload = {"values":jsonValues};
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->put(setValuePath, request = request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.message = err.message;
            spreadsheetError.cause = err.cause;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                http:PayloadError err => {
                    spreadsheetError.message = "Error occured while receiving Json Payload";
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

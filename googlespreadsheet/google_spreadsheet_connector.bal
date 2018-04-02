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

package googlespreadsheet;

import ballerina/io;
import ballerina/mime;
import ballerina/net.http;
import oauth2;

public struct SpreadsheetConnector {
    oauth2:OAuth2Endpoint oauth2EP;
}

@Description {value : "Create a new spreadsheet"}
@Param {value : "spreadsheetName: Name of the spreadsheet"}
@Return{ value : "spreadsheet: Spreadsheet object"}
public function <SpreadsheetConnector gsClient> createSpreadsheet (string spreadsheetName)
                                                              returns Spreadsheet | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    Spreadsheet spreadsheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    string createSpreadsheetPath = "/v4/spreadsheets";
    json spreadsheetJSONPayload = {"properties": {"title": spreadsheetName}};
    request.setJsonPayload(spreadsheetJSONPayload);
    var httpResponse = oauth2EP -> post(createSpreadsheetPath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse =? response.getJsonPayload();
            if (statusCode == 200) {
                spreadsheetResponse = convertToSpreadsheet(spreadsheetJSONResponse);
                return spreadsheetResponse;
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        }
    }
}

@Description {value : "Get a spreadsheet by ID"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Return{ value : "spreadsheet: Spreadsheet object"}
public function <SpreadsheetConnector gsClient> openSpreadsheetById (string spreadsheetId)
                                                                returns Spreadsheet | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    Spreadsheet spreadsheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId;
    var httpResponse = oauth2EP -> get(getSpreadsheetPath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse =? response.getJsonPayload();
            if (statusCode == 200) {
                spreadsheetResponse = convertToSpreadsheet(spreadsheetJSONResponse);
                return spreadsheetResponse;
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        }
    }
}

@Description {value : "Get spreadsheet values"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Sheet values"}
public function <SpreadsheetConnector gsClient> getSheetValues (string spreadsheetId, string sheetName,
                                                                string topLeftCell, string bottomRightCell)
                                                                returns (string[][]) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string[][] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + topLeftCell;
    if (bottomRightCell != "" && bottomRightCell != null) {
        a1Notation = a1Notation + ":" + bottomRightCell;
    }
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse =? response.getJsonPayload();
            if (statusCode == 200) {
                if (spreadsheetJSONResponse.values != null) {
                    int i = 0;
                    foreach value in spreadsheetJSONResponse.values {
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
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        }
    }
}

@Description {value : "Get column data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Column data"}
public function <SpreadsheetConnector gsClient> getColumnData (string spreadsheetId, string sheetName, string column)
                                                                returns (string[]) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + ":" + column;
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                mime:EntityError err => {
                    spreadsheetError.errorMessage = err.message;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == 200) {
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
                        spreadsheetError.errorMessage = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

@Description {value : "Get row data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Row data"}
public function <SpreadsheetConnector gsClient> getRowData (string spreadsheetId, string sheetName, int row)
                                                                returns (string[]) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + row + ":" + row;
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                mime:EntityError err => {
                    spreadsheetError.errorMessage = err.message;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == 200) {
                        if (jsonResponse.values != null) {
                            int i = 0;
                            foreach value in jsonResponse.values[0] {
                                values[i] = value.toString();
                                i = i + 1;
                            }
                        }
                        return values;
                    } else {
                        spreadsheetError.errorMessage = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

@Description {value : "Get cell data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Cell data"}
public function <SpreadsheetConnector gsClient> getCellData (string spreadsheetId, string sheetName, string column,
                                                                    int row) returns (string) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string value = "";
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + row;
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                mime:EntityError err => {
                    spreadsheetError.errorMessage = err.message;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == 200) {
                        if (jsonResponse.values != null) {
                            value = jsonResponse.values[0][0].toString();
                        }
                        return value;
                    } else {
                        spreadsheetError.errorMessage = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

@Description {value : "Set cell data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Cell data"}
public function <SpreadsheetConnector gsClient> setCellData (string spreadsheetId, string sheetName,
                                         string column, int row, string value) returns Range | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    Range rangeResponse = {};
    SpreadsheetError spreadsheetError = {};
    json jsonPayload = {"values" : [[value]]};
    string a1Notation = sheetName + "!" + column + row;
    string setValuePath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?valueInputOption=RAW";
    request.setJsonPayload(jsonPayload);
    var httpResponse = oauth2EP -> put(setValuePath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                mime:EntityError err => {
                    spreadsheetError.errorMessage = err.message;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == 200) {
                        rangeResponse = convertToRange(jsonResponse);
                        return rangeResponse;
                    } else {
                        spreadsheetError.errorMessage = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}

@Description {value : "Get column data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Column data"}
public function <SpreadsheetConnector gsClient> getNumberOfRowsOrColumns (string spreadsheetId,
                                              string a1Notation, string dimension) returns (int) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    int numberOfRowsOrColumns = 0;
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?majorDimension="
                                + dimension;
    var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var spreadsheetJSONResponse = response.getJsonPayload();
            match spreadsheetJSONResponse {
                mime:EntityError err => {
                    spreadsheetError.errorMessage = err.message;
                    return spreadsheetError;
                }
                json jsonResponse => {
                    if (statusCode == 200) {
                        if (jsonResponse.values != null) {
                            numberOfRowsOrColumns = lengthof jsonResponse.values;
                        }
                        return numberOfRowsOrColumns;
                    } else {
                        spreadsheetError.errorMessage = jsonResponse.error.message.toString();
                        spreadsheetError.statusCode = statusCode;
                        return spreadsheetError;
                    }
                }
            }
        }
    }
}
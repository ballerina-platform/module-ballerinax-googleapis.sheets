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
import wso2/oauth2;

documentation {Spreadsheet client connector
    F{{oauth2Client}} OAuth2 client endpoint
}
public type SpreadsheetConnector object {
    public {
        oauth2:APIClient oauth2Client;
    }

    documentation {Create a new spreadsheet
        P{{spreadsheetName}} Name of the spreadsheet
        returns Spreadsheet object on success and SpreadsheetError on failure
    }
    public function createSpreadsheet (string spreadsheetName) returns Spreadsheet | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
        http:Request request = new;
        Spreadsheet spreadsheetResponse = new;
        SpreadsheetError spreadsheetError = {};
        string createSpreadsheetPath = "/v4/spreadsheets";
        json spreadsheetJSONPayload = {"properties": {"title": spreadsheetName}};
        request.setJsonPayload(spreadsheetJSONPayload);
        try {
            var httpResponse = oauth2EP -> post(createSpreadsheetPath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                spreadsheetResponse = convertToSpreadsheet(spreadsheetJSONResponse);
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError.errorMessage = err.message;
            return spreadsheetError;
        }
        return spreadsheetResponse;
    }

    documentation {Get a spreadsheet by ID
        P{{spreadsheetId}} Id of the spreadsheet
        returns Spreadsheet object on success and SpreadsheetError on failure
    }
    public function openSpreadsheetById (string spreadsheetId) returns Spreadsheet | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
        http:Request request = new;
        Spreadsheet spreadsheetResponse = new;
        SpreadsheetError spreadsheetError = {};
        string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId;
        try {
            var httpResponse = oauth2EP -> get(getSpreadsheetPath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                spreadsheetResponse = convertToSpreadsheet(spreadsheetJSONResponse);
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError.errorMessage = err.message;
            return spreadsheetError;
        }
        return spreadsheetResponse;
    }

    documentation {Get spreadsheet values
        P{{spreadsheetId}} Id of the spreadsheet
        P{{sheetName}} Name of the sheet
        P{{topLeftCell}} Top left cell
        P{{bottomRightCell}} Bottom right cell
        returns Sheet values as a two dimensional array on success and SpreadsheetError on failure
    }
    public function getSheetValues (string spreadsheetId, string sheetName, string topLeftCell, string bottomRightCell)
                    returns (string[][]) | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
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
        string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
        try {
            var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                if (spreadsheetJSONResponse.values != null) {
                    int i = 0;
                    foreach value in spreadsheetJSONResponse.values {
                        int j = 0;
                        string[] val = [];
                        foreach v in value {
                            val[j] = v.toString() ?: "";
                            j = j + 1;
                        }
                        values[i] = val;
                        i = i + 1;
                    }
                }
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError.errorMessage = err.message;
            return spreadsheetError;
        }
        return values;
    }

    documentation {Get column data
        P{{spreadsheetId}} Id of the spreadsheet
        P{{sheetName}} Name of the sheet
        P{{column}} Column name to retrieve the data
        returns Column data as an array on success and SpreadsheetError on failure
    }
    public function getColumnData (string spreadsheetId, string sheetName, string column)
                    returns (string[]) | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
        http:Request request = new;
        string[] values = [];
        SpreadsheetError spreadsheetError = {};
        string a1Notation = sheetName + "!" + column + ":" + column;
        string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
        try {
            var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                if (spreadsheetJSONResponse.values != null) {
                    int i = 0;
                    json[][] jsonVals = check <json[][]> spreadsheetJSONResponse.values;
                    foreach value in jsonVals {
                        if (lengthof value > 0) {
                            values[i] = value[0].toString() ?: "";
                        } else {
                            values[i] = "";
                        }
                        i = i + 1;
                    }
                }
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError.errorMessage = err.message;
            return spreadsheetError;
        }
        return values;
    }

    documentation {Get row data
        P{{spreadsheetId}} Id of the spreadsheet
        P{{sheetName}} Name of the sheet
        P{{row}} Row name to retrieve the data
        returns Row data as an array on success and SpreadsheetError on failure
    }
    public function getRowData (string spreadsheetId, string sheetName, int row)
                    returns (string[]) | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
        http:Request request = new;
        string[] values = [];
        SpreadsheetError spreadsheetError = {};
        string a1Notation = sheetName + "!" + row + ":" + row;
        string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
        try {
            var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                if (spreadsheetJSONResponse.values != null) {
                    int i = 0;
                    json[][] jsonVals = check <json[][]>spreadsheetJSONResponse.values;
                    foreach value in jsonVals[0] {
                        values[i] = value.toString() ?: "";
                        i = i + 1;
                    }
                }
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError.errorMessage = err.message;
            return spreadsheetError;
        }
        return values;
    }

    documentation {Get cell data
        P{{spreadsheetId}} Id of the spreadsheet
        P{{sheetName}} Name of the sheet
        P{{column}} Column name to retrieve the data
        P{{row}} Row name to retrieve the data
        returns Cell data on success and SpreadsheetError on failure
    }
    public function getCellData (string spreadsheetId, string sheetName, string column, int row)
                    returns (string) | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
        http:Request request = new;
        string value = "";
        SpreadsheetError spreadsheetError = {};
        string a1Notation = sheetName + "!" + column + row;
        string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
        try {
            var httpResponse = oauth2EP -> get(getSheetValuesPath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                if (spreadsheetJSONResponse.values != null) {
                    json[][] jsonVals = check <json[][]>spreadsheetJSONResponse.values;
                    value = jsonVals[0][0].toString() ?: "";
                }
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError.errorMessage = err.message;
            return spreadsheetError;
        }
        return value;
    }

    documentation {Set cell data
        P{{spreadsheetId}} Id of the spreadsheet
        P{{sheetName}} Name of the sheet
        P{{column}} Column name to set the data
        P{{row}} Row name to set the data
        P{{value}} The value to be updated
        returns True on success and SpreadsheetError on failure
    }
    public function setCellData (string spreadsheetId, string sheetName, string column, int row, string value)
                    returns (boolean) | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
        http:Request request = new;
        SpreadsheetError spreadsheetError = {};
        json jsonPayload = {"values" : [[value]]};
        string a1Notation = sheetName + "!" + column + row;
        string setValuePath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?valueInputOption=RAW";
        request.setJsonPayload(jsonPayload);
        try {
            var httpResponse = oauth2EP -> put(setValuePath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                return true;
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError. errorMessage = err.message;
            return spreadsheetError;
        }
    }

    documentation {Set spreadsheet values
        P{{spreadsheetId}} Id of the spreadsheet
        P{{sheetName}} Name of the sheet
        P{{topLeftCell}} Top left cell
        P{{bottomRightCell}} Bottom right cell
        P{{values}} Values to be updated
        returns True on success and SpreadsheetError on failure
    }
    public function setSheetValues (string spreadsheetId, string sheetName, string topLeftCell, string bottomRightCell,
                                    string[][] values) returns (boolean) | SpreadsheetError {
        endpoint oauth2:APIClient oauth2EP = self.oauth2Client;
        http:Request request = new;
        SpreadsheetError spreadsheetError = {};
        string a1Notation = sheetName + "!" + topLeftCell + ":" + bottomRightCell;
        string setValuePath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?valueInputOption=RAW";
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
        json jsonPayload = {"values" : jsonValues};
        request.setJsonPayload(jsonPayload);
        try {
            var httpResponse = oauth2EP -> put(setValuePath, request);
            http:Response response = check httpResponse;
            int statusCode = response.statusCode;
            var jsonRes = response.getJsonPayload();
            json spreadsheetJSONResponse = check jsonRes;
            if (statusCode == http:OK_200) {
                return true;
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString() ?: "";
                spreadsheetError.statusCode = statusCode;
                return spreadsheetError;
            }
        } catch (http:HttpConnectorError err) {
            spreadsheetError.errorMessage = err.message;
            spreadsheetError.statusCode = err.statusCode;
            return spreadsheetError;
        } catch (mime:EntityError err) {
            spreadsheetError. errorMessage = err.message;
            return spreadsheetError;
        }
    }
};

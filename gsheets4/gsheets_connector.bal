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

# Object to initialize the connection with Google Spreadsheet.
#
# + spreadsheetClient - The HTTP Client
public type SpreadsheetConnector client object {

    public http:Client spreadsheetClient;

    public function __init(string url, http:ClientEndpointConfig config) {
        self.spreadsheetClient = new(url, config = config);
    }

    remote function createSpreadsheet(string spreadsheetName) returns Spreadsheet|error;

    remote function openSpreadsheetById(string spreadsheetId) returns Spreadsheet|error;

    remote function addNewSheet(string spreadsheetId, string sheetName) returns Sheet|error;

    remote function deleteSheet(string spreadsheetId, int sheetId) returns boolean|error;

    remote function getSheetValues(string spreadsheetId, string sheetName, string topLeftCell = "",
                                                string bottomRightCell = "") returns string[][]|error;

    remote function getColumnData(string spreadsheetId, string sheetName, string column)
                                                returns string[]|error;

    remote function getRowData(string spreadsheetId, string sheetName, int row)
                                                returns string[]|error;

    remote function getCellData(string spreadsheetId, string sheetName, string column, int row)
                                                returns string|error;

    remote function setCellData(string spreadsheetId, string sheetName, string column, int row, string value)
                                                returns boolean|error;

    remote function setSheetValues(string spreadsheetId, string sheetName, string topLeftCell = "",
                                                string bottomRightCell = "", string[][] values) returns boolean|error;
};

remote function SpreadsheetConnector.createSpreadsheet(string spreadsheetName) returns Spreadsheet|error {
    http:Client httpClient = self.spreadsheetClient;
    string requestPath = SPREADSHEET_PATH;
    http:Request request = new;
    json spreadsheetJSONPayload = { "properties": { "title": spreadsheetName } };
    request.setJsonPayload(spreadsheetJSONPayload);
    var httpResponse = httpClient->post(SPREADSHEET_PATH, request);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                Spreadsheet spreadsheet = convertToSpreadsheet(jsonResponse);
                return spreadsheet;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}


remote function SpreadsheetConnector.openSpreadsheetById(string spreadsheetId) returns Spreadsheet|error {
    http:Client httpClient =  self.spreadsheetClient;
    string getSpreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
    var httpResponse = httpClient->get(getSpreadsheetPath);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                Spreadsheet spreadsheet = convertToSpreadsheet(jsonResponse);
                return spreadsheet;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function SpreadsheetConnector.addNewSheet(string spreadsheetId, string sheetName)
                                            returns Sheet|error {
    http:Client httpClient =  self.spreadsheetClient;
    http:Request request = new;
    json sheetJSONPayload = {"requests" : [{"addSheet":{"properties":{}}}]};
    json jsonSheetProperties = {};
    if (sheetName != EMPTY_STRING) {
        jsonSheetProperties.title = sheetName;
    }
    sheetJSONPayload.requests[0].addSheet.properties = jsonSheetProperties;
    request.setJsonPayload(sheetJSONPayload);
    string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
    var httpResponse = httpClient->post(addSheetPath, request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                Sheet newSheet = convertToSheet(jsonResponse);
                return newSheet;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}


remote function SpreadsheetConnector.deleteSheet(string spreadsheetId, int sheetId)
                                                     returns boolean|error {
    http:Client httpClient = self.spreadsheetClient;
    http:Request request = new;
    json sheetJSONPayload = {"requests" : [{"deleteSheet":{"sheetId":sheetId}}]};
    request.setJsonPayload(sheetJSONPayload);
    string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
    var httpResponse = httpClient->post(deleteSheetPath, request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                return true;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function SpreadsheetConnector.getSheetValues(string spreadsheetId, string sheetName, string topLeftCell = "",
                                                     string bottomRightCell = "") returns string[][]|error {
    http:Client httpClient = self.spreadsheetClient;
    string[][] values = [];
    string a1Notation = sheetName;
    if (topLeftCell != EMPTY_STRING) {
        a1Notation = a1Notation + "!" + topLeftCell;
    }
    if (bottomRightCell != EMPTY_STRING) {
        a1Notation = a1Notation + ":" + bottomRightCell;
    }
    string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getSheetValuesPath);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
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
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function SpreadsheetConnector.getColumnData(string spreadsheetId, string sheetName, string column)
                                                     returns string[]|error {
    http:Client httpClient = self.spreadsheetClient;
    string[] values = [];
    string a1Notation = sheetName + "!" + column + ":" + column;
    string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getColumnDataPath);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                if (jsonResponse.values != null) {
                    int i = 0;
                    foreach value in jsonResponse.values {
                        if (value.length() > 0) {
                            values[i] = value[0].toString();
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
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function SpreadsheetConnector.getRowData(string spreadsheetId, string sheetName, int row)
                                                     returns string[]|error {
    http:Client httpClient = self.spreadsheetClient;
    string[] values = [];
    string a1Notation = sheetName + "!" + row + ":" + row;
    string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getRowDataPath);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
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
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function SpreadsheetConnector.getCellData(string spreadsheetId, string sheetName, string column, int row)
                                                     returns string|error {
    http:Client httpClient = self.spreadsheetClient;
    string value = EMPTY_STRING;
    string a1Notation = sheetName + "!" + column + row;
    string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
    var httpResponse = httpClient->get(getCellDataPath);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                if (jsonResponse.values != null) {
                    value = jsonResponse.values[0][0].toString();
                }
                return value;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function SpreadsheetConnector.setCellData(string spreadsheetId, string sheetName, string column, int row,
                                                  string value) returns boolean|error {
    http:Client httpClient = self.spreadsheetClient;
    http:Request request = new;
    json jsonPayload = {"values":[[value]]};
    string a1Notation = sheetName + "!" + column + row;
    string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation
        + QUESTION_MARK + VALUE_INPUT_OPTION;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->put(setCellDataPath, request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                return true;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

remote function SpreadsheetConnector.setSheetValues(string spreadsheetId, string sheetName, string topLeftCell = "",
                                                     string bottomRightCell = "", string[][] values)
                                                     returns boolean|error {
    http:Client httpClient = self.spreadsheetClient;
    http:Request request = new;
    string a1Notation = sheetName;
    if (topLeftCell != EMPTY_STRING ) {
        a1Notation = a1Notation + "!" + topLeftCell;
    }
    if (bottomRightCell != EMPTY_STRING) {
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
    request.setJsonPayload(untaint jsonPayload);
    var httpResponse = httpClient->put(setValuePath, request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                return true;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

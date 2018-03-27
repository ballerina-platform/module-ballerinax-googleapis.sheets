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

public struct GoogleSpreadsheetClientConnector {
    oauth2:OAuth2Client oAuth2Client;
}

GoogleSpreadsheetClientConnector gsClientGlobal = {};
boolean isConnectorInitialized = false;

public function <GoogleSpreadsheetClientConnector gsClient> init (string accessToken, string refreshToken,
                                                                 string clientId, string clientSecret) {
    oauth2:OAuth2Client oauth = {};
    oauth.init("https://sheets.googleapis.com", accessToken, refreshToken, clientId, clientSecret,
                                    "https://www.googleapis.com", "/oauth2/v3/token", "", "");
    gsClient.oAuth2Client = oauth;
    gsClientGlobal = gsClient;
    isConnectorInitialized = true;
}

@Description {value : "Create a new spreadsheet"}
@Param {value : "spreadsheetName: Name of the spreadsheet"}
@Return{ value : "spreadsheet: Spreadsheet object"}
public function <GoogleSpreadsheetClientConnector gsClient> createSpreadsheet (string spreadsheetName)
                                                              returns Spreadsheet | SpreadsheetError {
    http:Request request = {};
    Spreadsheet spreadsheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    string createSpreadsheetPath = "/v4/spreadsheets";
    json spreadsheetJSONPayload = {"properties": {"title": spreadsheetName}};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    request.setJsonPayload(spreadsheetJSONPayload);
    var httpResponse = gsClient.oAuth2Client.post(createSpreadsheetPath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                       spreadsheetError.statusCode = err.statusCode;
                                       return spreadsheetError;
                                     }
        http:Response response => { int statusCode = response.statusCode;
                                    var spreadsheetJSONResponse = response.getJsonPayload();
                                    match spreadsheetJSONResponse {
                                        mime:EntityError err => {
                                            spreadsheetError.errorMessage = err.message;
                                            return spreadsheetError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                spreadsheetResponse = <Spreadsheet, convertToSpreadsheet()> jsonResponse;
                                                return spreadsheetResponse;
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

@Description {value : "Get a spreadsheet by ID"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Return{ value : "spreadsheet: Spreadsheet object"}
public function <GoogleSpreadsheetClientConnector gsClient> openSpreadsheetById (string spreadsheetId)
                                                                returns Spreadsheet | SpreadsheetError {
    http:Request request = {};
    Spreadsheet spreadsheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    var httpResponse = gsClient.oAuth2Client.get(getSpreadsheetPath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                         spreadsheetError.statusCode = err.statusCode;
                                         return spreadsheetError;
                                       }
        http:Response response => { int statusCode = response.statusCode;
                                    var spreadsheetJSONResponse = response.getJsonPayload();
                                    match spreadsheetJSONResponse {
                                        mime:EntityError err => {
                                            spreadsheetError.errorMessage = err.message;
                                            return spreadsheetError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                spreadsheetResponse = <Spreadsheet, convertToSpreadsheet()> jsonResponse;
                                                return spreadsheetResponse;
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

@Description {value : "Get spreadsheet values"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Sheet values"}
public function <GoogleSpreadsheetClientConnector gsClient> getSheetValues (string spreadsheetId, string a1Notation)
                                                                returns (string[][]) | SpreadsheetError {
    http:Request request = {};
    string[][] values = [];
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    var httpResponse = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                         spreadsheetError.statusCode = err.statusCode;
                                         return spreadsheetError;
                                       }
        http:Response response => { int statusCode = response.statusCode;
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
public function <GoogleSpreadsheetClientConnector gsClient> getColumnData (string spreadsheetId, string a1Notation)
                                                                returns (string[]) | SpreadsheetError {
    http:Request request = {};
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    var httpResponse = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                         spreadsheetError.statusCode = err.statusCode;
                                         return spreadsheetError;
                                       }
        http:Response response => { int statusCode = response.statusCode;
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
public function <GoogleSpreadsheetClientConnector gsClient> getRowData (string spreadsheetId, string a1Notation)
                                                                returns (string[]) | SpreadsheetError {
    http:Request request = {};
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    var httpResponse = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                         spreadsheetError.statusCode = err.statusCode;
                                         return spreadsheetError;
                                       }
        http:Response response => { int statusCode = response.statusCode;
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
public function <GoogleSpreadsheetClientConnector gsClient> getCellData (string spreadsheetId, string a1Notation)
                                                                returns (string) | SpreadsheetError {
    http:Request request = {};
    string value = "";
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    var httpResponse = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                         spreadsheetError.statusCode = err.statusCode;
                                         return spreadsheetError;
                                       }
        http:Response response => { int statusCode = response.statusCode;
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
public function <GoogleSpreadsheetClientConnector gsClient> setValue (string spreadsheetId, string a1Notation,
                                                                string value) returns Range | SpreadsheetError {
    http:Request request = {};
    Range rangeResponse = {};
    SpreadsheetError spreadsheetError = {};
    json jsonPayload = {"values" : [[value]]};
    string setValuePath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?valueInputOption=RAW";
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    request.setJsonPayload(jsonPayload);
    var httpResponse = gsClient.oAuth2Client.put(setValuePath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                         spreadsheetError.statusCode = err.statusCode;
                                         return spreadsheetError;
                                       }
        http:Response response => { int statusCode = response.statusCode;
                                    var spreadsheetJSONResponse = response.getJsonPayload();
                                    match spreadsheetJSONResponse {
                                        mime:EntityError err => {
                                            spreadsheetError.errorMessage = err.message;
                                            return spreadsheetError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                rangeResponse = <Range, convertToRange()> jsonResponse;
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
public function <GoogleSpreadsheetClientConnector gsClient> getNumberOfRowsOrColumns (string spreadsheetId,
                                              string a1Notation, string dimension) returns (int) | SpreadsheetError {
    http:Request request = {};
    int numberOfRowsOrColumns = 0;
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?majorDimension="
                                + dimension;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return spreadsheetError;
    }
    var httpResponse = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    match httpResponse {
        http:HttpConnectorError err => { spreadsheetError.errorMessage = err.message;
                                         spreadsheetError.statusCode = err.statusCode;
                                         return spreadsheetError;
        }
        http:Response response => { int statusCode = response.statusCode;
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
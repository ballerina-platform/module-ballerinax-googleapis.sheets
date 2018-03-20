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

package src.wso2.spreadsheet;

import ballerina.io;
import ballerina.net.http;
import src.wso2.oauth2;

public struct GoogleSpreadsheetClientConnector {
    oauth2:OAuth2Client oAuth2Client;
}

GoogleSpreadsheetClientConnector gsClientGlobal = {};
boolean isConnectorInitialized = false;

public function <GoogleSpreadsheetClientConnector gsClient> init (string accessToken, string refreshToken,
                                                                 string clientId, string clientSecret) {
    oauth2:OAuth2Client oauth = {};
    oauth.init("https://sheets.googleapis.com", accessToken, refreshToken, clientId, clientSecret,
                                    "https://www.googleapis.com", "/oauth2/v3/token");
    gsClient.oAuth2Client = oauth;
    gsClientGlobal = gsClient;
    isConnectorInitialized = true;
}

@Description {value : "Create a new spreadsheet"}
@Param {value : "spreadsheetName: Name of the spreadsheet"}
@Return{ value : "spreadsheet: Spreadsheet object"}
public function <GoogleSpreadsheetClientConnector gsClient> createSpreadsheet (string spreadsheetName)
                                                                (Spreadsheet, SpreadsheetError) {
    http:Request request = {};
    http:Response response = {};
    Spreadsheet spreadsheetResponse = {};
    http:HttpConnectorError connectorError;
    SpreadsheetError spreadsheetError = {};
    string createSpreadsheetPath = "/v4/spreadsheets";
    json spreadsheetJSONPayload = {"properties": {"title": spreadsheetName}};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    request.setJsonPayload(spreadsheetJSONPayload);
    response, connectorError = gsClient.oAuth2Client.post(createSpreadsheetPath, request);
    if (connectorError != null) {
        spreadsheetError.errorMessage = connectorError.message;
        spreadsheetError.statusCode = connectorError.statusCode;
        return null, spreadsheetError;
    }
    int statusCode = response.statusCode;
    var spreadsheetJSONResponse, _ = response.getJsonPayload();
    if (statusCode == 200) {
        spreadsheetResponse = <Spreadsheet, convertToSpreadsheet()> spreadsheetJSONResponse;
    } else {
        spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
        spreadsheetError.statusCode = statusCode;
    }
    return spreadsheetResponse, spreadsheetError;
}

@Description {value : "Get a spreadsheet by ID"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Return{ value : "spreadsheet: Spreadsheet object"}
public function <GoogleSpreadsheetClientConnector gsClient> openSpreadsheetById (string spreadsheetId)
                                                                (Spreadsheet, SpreadsheetError) {
    http:Request request = {};
    http:Response response = {};
    Spreadsheet spreadsheetResponse = {};
    http:HttpConnectorError connectorError;
    SpreadsheetError spreadsheetError = {};
    string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    response, connectorError = gsClient.oAuth2Client.get(getSpreadsheetPath, request);
    if (connectorError != null) {
        spreadsheetError.errorMessage = connectorError.message;
        spreadsheetError.statusCode = connectorError.statusCode;
        return null, spreadsheetError;
    }
    int statusCode = response.statusCode;
    var spreadsheetJSONResponse, _ = response.getJsonPayload();
    if (statusCode == 200) {
        spreadsheetResponse = <Spreadsheet, convertToSpreadsheet()> spreadsheetJSONResponse;
    } else {
        spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
        spreadsheetError.statusCode = statusCode;
    }
    return spreadsheetResponse, spreadsheetError;
}

@Description {value : "Get spreadsheet values"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Sheet values"}
public function <GoogleSpreadsheetClientConnector gsClient> getSheetValues (string spreadsheetId, string a1Notation)
                                                                (string[][], SpreadsheetError) {
    http:Request request = {};
    http:Response response = {};
    string[][] values = [];
    http:HttpConnectorError connectorError;
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    response, connectorError = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    if (connectorError != null) {
        spreadsheetError.errorMessage = connectorError.message;
        spreadsheetError.statusCode = connectorError.statusCode;
        return null, spreadsheetError;
    }
    int statusCode = response.statusCode;
    var spreadsheetJSONResponse, _ = response.getJsonPayload();
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
    }  else {
        spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
        spreadsheetError.statusCode = statusCode;
    }
    return values, spreadsheetError;
}

@Description {value : "Get column data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return {value : "Column data"}
public function <GoogleSpreadsheetClientConnector gsClient> getColumnData (string spreadsheetId, string a1Notation)
                                                                (string[], SpreadsheetError) {
    http:Request request = {};
    http:Response response = {};
    string[] values = [];
    http:HttpConnectorError connectorError;
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    response, connectorError = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    if (connectorError != null) {
        spreadsheetError.errorMessage = connectorError.message;
        spreadsheetError.statusCode = connectorError.statusCode;
        return null, spreadsheetError;
    }
    int statusCode = response.statusCode;
    var spreadsheetJSONResponse, _ = response.getJsonPayload();
    if (statusCode == 200) {
        if (spreadsheetJSONResponse.values != null) {
            int i = 0;
            foreach value in spreadsheetJSONResponse.values {
                if (lengthof value > 0) {
                    values[i] = value[0].toString();
                } else {
                    values[i] = "";
                }
                i = i + 1;
            }
        }
    }  else {
        spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
        spreadsheetError.statusCode = statusCode;
    }
    return values, spreadsheetError;
}

@Description {value : "Get row data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Row data"}
public function <GoogleSpreadsheetClientConnector gsClient> getRowData (string spreadsheetId, string a1Notation)
                                                                (string[], SpreadsheetError) {
    http:Request request = {};
    http:Response response = {};
    string[] values = [];
    http:HttpConnectorError connectorError;
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    response, connectorError = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    if (connectorError != null) {
        spreadsheetError.errorMessage = connectorError.message;
        spreadsheetError.statusCode = connectorError.statusCode;
        return null, spreadsheetError;
    }
    int statusCode = response.statusCode;
    var spreadsheetJSONResponse, _ = response.getJsonPayload();
    if (statusCode == 200 && spreadsheetJSONResponse.values != null) {
        int i = 0;
        foreach value in spreadsheetJSONResponse.values[0] {
            values[i] = value.toString();
            i = i + 1;
        }
    }  else {
        spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
        spreadsheetError.statusCode = statusCode;
    }
    return values, spreadsheetError;
}

@Description{ value : "Get cell data"}
@Param{ value : "spreadsheetId: Id of the spreadsheet"}
@Param{ value : "a1Notation: The A1 notation of the values to retrieve"}
@Return{ value : "Cell data"}
public function <GoogleSpreadsheetClientConnector gsClient> getCellData (string spreadsheetId, string a1Notation)
                                                                (string, SpreadsheetError) {
    http:Request request = {};
    http:Response response = {};
    string value = "";
    http:HttpConnectorError connectorError;
    SpreadsheetError spreadsheetError = {};
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    response, connectorError = gsClient.oAuth2Client.get(getSheetValuesPath, request);
    if (connectorError != null) {
        spreadsheetError.errorMessage = connectorError.message;
        spreadsheetError.statusCode = connectorError.statusCode;
        return null, spreadsheetError;
    }
    int statusCode = response.statusCode;
    var spreadsheetJSONResponse, _ = response.getJsonPayload();
    if (statusCode == 200 && spreadsheetJSONResponse.values != null) {
        value = spreadsheetJSONResponse.values[0][0].toString();
    }  else {
        spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
        spreadsheetError.statusCode = statusCode;
    }
    return value, spreadsheetError;
}

@Description {value : "Set cell value"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "a1Notation: The A1 notation of the value to set"}
@Return {value : "rangeResponse: Updated range"}
public function <GoogleSpreadsheetClientConnector gsClient> setValue(string spreadsheetId, string a1Notation,
                                                                     string value) (Range, SpreadsheetError) {
    http:Request request = {};
    http:Response response = {};
    Range rangeResponse = {};
    http:HttpConnectorError connectorError;
    SpreadsheetError spreadsheetError = {};
    json jsonPayload = {"values" : [[value]]};
    string setValuePath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation +
                            "?valueInputOption=RAW";
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    request.setJsonPayload(jsonPayload);
    response, connectorError = gsClient.oAuth2Client.put(setValuePath, request);
    if (connectorError != null) {
        spreadsheetError.errorMessage = connectorError.message;
        spreadsheetError.statusCode = connectorError.statusCode;
        return null, spreadsheetError;
    }
    int statusCode = response.statusCode;
    var spreadsheetJSONResponse, _ = response.getJsonPayload();
    if (statusCode == 200) {
        rangeResponse = <Range, convertToRange()> spreadsheetJSONResponse;
    } else {
        spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
        spreadsheetError.statusCode = statusCode;
    }
    return rangeResponse, spreadsheetError;
}
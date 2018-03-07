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

package src.wso2.googlespreadsheet;

import ballerina.net.http;
import org.wso2.ballerina.connectors.oauth2;

@Description {value : "Google Spreadsheet client connector"}
@Param {value : "accessToken: The accessToken of the Google Spreadsheet account to access the Google Spreadsheet REST API"}
@Param {value : "refreshToken: The refreshToken of the Google Spreadsheet App to access the Google Spreadsheet REST API"}
@Param {value : "clientId: The clientId of the App to access the Google Spreadsheet REST API"}
@Param {value : "clientSecret: The clientSecret of the App to access the Google Spreadsheet REST API"}
public connector GoogleSpreadsheetClientConnector (string accessToken, string refreshToken, string clientId,
                                                   string clientSecret) {
    endpoint<oauth2:ClientConnector> googleSpreadsheetEP {
        create oauth2:ClientConnector("https://sheets.googleapis.com", accessToken, clientId, clientSecret,
                                      refreshToken, "https://www.googleapis.com", "/oauth2/v3/token");
    }

    @Description {value : "Get a spreadsheet by ID"}
    @Param {value : "spreadsheetId: Id of the spreadsheet"}
    @Return{ value : "spreadsheet: Spreadsheet object"}
    action openById(string spreadsheetId) (Spreadsheet, SpreadsheetError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        Spreadsheet spreadsheetResponse = {};
        http:HttpConnectorError connectorError;
        SpreadsheetError spreadsheetError = {};

        string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId;

        response, connectorError = googleSpreadsheetEP.get(getSpreadsheetPath, request);

        if (connectorError != null) {
            spreadsheetError.errorMessage = connectorError.message;
            spreadsheetError.statusCode = connectorError.statusCode;
        } else {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse = response.getJsonPayload();
            if (statusCode == 200) {
                spreadsheetResponse = <Spreadsheet, convertToSpreadsheet()>spreadsheetJSONResponse;
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
                spreadsheetError.statusCode = statusCode;
            }
        }
        return spreadsheetResponse, spreadsheetError;
    }

    @Description {value : "Get spreadsheet values"}
    @Param {value : "spreadsheetId: Id of the spreadsheet"}
    @Param {value : "a1Notation: The A1 notation of the values to retrieve"}
    @Return{ value : "Sheet values"}
    action getSheetValues(string spreadsheetId, string a1Notation) (string[][], SpreadsheetError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        string[][] values = [];
        http:HttpConnectorError connectorError;
        SpreadsheetError spreadsheetError = {};

        string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;

        response, connectorError = googleSpreadsheetEP.get(getSpreadsheetPath, request);
        if (connectorError != null) {
            spreadsheetError.errorMessage = connectorError.message;
            spreadsheetError.statusCode = connectorError.statusCode;
        } else {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse = response.getJsonPayload();
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
        }
        return values, spreadsheetError;
    }

    @Description {value : "Get column data"}
    @Param {value : "spreadsheetId: Id of the spreadsheet"}
    @Param {value : "a1Notation: The A1 notation of the values to retrieve"}
    @Return {value : "Column data"}
    action getColumnData(string spreadsheetId, string a1Notation) (string[], SpreadsheetError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        string[] values = [];
        http:HttpConnectorError connectorError;
        SpreadsheetError spreadsheetError = {};

        string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;

        response, connectorError = googleSpreadsheetEP.get(getSpreadsheetPath, request);
        if (connectorError != null) {
            spreadsheetError.errorMessage = connectorError.message;
            spreadsheetError.statusCode = connectorError.statusCode;
        } else {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse = response.getJsonPayload();
            if (statusCode == 200) {
                if (spreadsheetJSONResponse.values != null) {
                    int i = 0;
                    foreach value in spreadsheetJSONResponse.values {
                        if(lengthof value > 0){
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
        }
        return values, spreadsheetError;
    }

    @Description{ value : "Get row data"}
    @Param{ value : "spreadsheetId: Id of the spreadsheet"}
    @Param{ value : "a1Notation: The A1 notation of the values to retrieve"}
    @Return{ value : "Row data"}
    action getRowData(string spreadsheetId, string a1Notation) (string[], SpreadsheetError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        string[] values = [];
        http:HttpConnectorError connectorError;
        SpreadsheetError spreadsheetError = {};

        string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;

        response, connectorError = googleSpreadsheetEP.get(getSpreadsheetPath, request);
        if (connectorError != null) {
            spreadsheetError.errorMessage = connectorError.message;
            spreadsheetError.statusCode = connectorError.statusCode;
        } else {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse = response.getJsonPayload();
            if (statusCode == 200) {
                if (spreadsheetJSONResponse.values != null) {
                    int i = 0;
                    foreach value in spreadsheetJSONResponse.values[0] {
                        values[i] = value.toString();
                        i = i + 1;
                    }
                }
            }  else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
                spreadsheetError.statusCode = statusCode;
            }
        }
        return values, spreadsheetError;
    }

    @Description{ value : "Get cell data"}
    @Param{ value : "spreadsheetId: Id of the spreadsheet"}
    @Param{ value : "a1Notation: The A1 notation of the values to retrieve"}
    @Return{ value : "Row data"}
    action getCellData(string spreadsheetId, string a1Notation) (string, SpreadsheetError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        string value = "";
        http:HttpConnectorError connectorError;
        SpreadsheetError spreadsheetError = {};

        string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;

        response, connectorError = googleSpreadsheetEP.get(getSpreadsheetPath, request);
        if (connectorError != null) {
            spreadsheetError.errorMessage = connectorError.message;
            spreadsheetError.statusCode = connectorError.statusCode;
        } else {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse = response.getJsonPayload();
            if (statusCode == 200) {
                if (spreadsheetJSONResponse.values != null) {
                    value = spreadsheetJSONResponse.values[0][0].toString();
                }
            }  else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
                spreadsheetError.statusCode = statusCode;
            }
        }
        return value, spreadsheetError;
    }

    @Description {value : "Set cell value"}
    @Param {value : "spreadsheetId: Id of the spreadsheet"}
    @Param {value : "a1Notation: The A1 notation of the value to set"}
    @Return {value : "rangeResponse: Updated range"}
    action setValue(string spreadsheetId, string a1Notation, string value) (Range, SpreadsheetError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        Range rangeResponse = {};
        http:HttpConnectorError connectorError;
        SpreadsheetError spreadsheetError = {};

        json jsonPayload = {"values" : [[value]]};
        string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation +
                                    "?valueInputOption=RAW";

        request.setJsonPayload(jsonPayload);
        response, connectorError = googleSpreadsheetEP.put(getSpreadsheetPath, request);
        if (connectorError != null) {
            spreadsheetError.errorMessage = connectorError.message;
            spreadsheetError.statusCode = connectorError.statusCode;
        } else {
            int statusCode = response.statusCode;
            json spreadsheetJSONResponse = response.getJsonPayload();
            if (statusCode == 200) {
                if (spreadsheetJSONResponse.values != null) {
                    rangeResponse = <Range, convertToRange()>spreadsheetJSONResponse;
                }
            } else {
                spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
                spreadsheetError.statusCode = statusCode;
            }
        }
        return rangeResponse, spreadsheetError;
    }
}
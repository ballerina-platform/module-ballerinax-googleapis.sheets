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

import ballerina/http;
import ballerina/io;
import ballerina/oauth2;

# Google Spreadsheet Client object.
#
# + spreadsheetClient - SpreadsheetConnector client endpoint
public type Client client object {

    public http:Client spreadsheetClient;

    public function __init(SpreadsheetConfiguration spreadsheetConfig) {
        // Create OAuth2 provider.
        oauth2:OutboundOAuth2Provider oauth2Provider = new(spreadsheetConfig.clientConfig);
        // Create bearer auth handler using created provider.
        http:BearerAuthHandler bearerHandler = new(oauth2Provider);
        // Create salesforce http client.
        self.spreadsheetClient = new(BASE_URL, {
            auth: {
                authHandler: bearerHandler
            }
        });
    }

    # Create a new spreadsheet.
    #
    # + spreadsheetName - Name of the spreadsheet
    # + return - If success, returns json with of task list, else returns `error` object
    public remote function createSpreadsheet(string spreadsheetName) returns @tainted (Spreadsheet|error) {
        string requestPath = SPREADSHEET_PATH;
        http:Request request = new;
        json spreadsheetJSONPayload = { "properties": { "title": spreadsheetName } };
        request.setJsonPayload(spreadsheetJSONPayload);
        var httpResponse = self.spreadsheetClient->post(SPREADSHEET_PATH, request);

        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return setJsonResponse(jsonResponse, statusCode);
            }
            error err = error(SPREADSHEET_ERROR_CODE,
                        message = "Error occurred while accessing the JSON payload of the response");
            return err;
        } else {
            return setResError(httpResponse);
        }
    }

    # Get a spreadsheet by ID.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + return - Spreadsheet object on success and error on failure
    public remote function openSpreadsheetById(string spreadsheetId) returns @tainted (Spreadsheet|error) {
        string getSpreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        var httpResponse = self.spreadsheetClient->get(getSpreadsheetPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return setJsonResponse(jsonResponse, statusCode);
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                    message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return setResError(httpResponse);
        }
    }

    # Add a new worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the sheet. It is an optional parameter. If the title is empty, then sheet will be created with the default name.
    # + return - Sheet object on success and error on failure
    public remote function addNewSheet(string spreadsheetId, string sheetName) returns @tainted (Sheet|error) {
        http:Request request = new;
        map<json> sheetJSONPayload = {"requests" : [{"addSheet":{"properties":{}}}]};
        map<json> jsonSheetProperties = {};
        if (sheetName != EMPTY_STRING) {
            jsonSheetProperties["title"] = sheetName;
        }
        json[] requestsElement = <json[]> sheetJSONPayload["requests"];
        map<json> firstRequestsElement = <map<json>> requestsElement[0];
        map<json> sheetElement = <map<json>> firstRequestsElement.addSheet;
        sheetElement["properties"] = jsonSheetProperties;
        request.setJsonPayload(sheetJSONPayload);
        string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.spreadsheetClient->post(addSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    json[] replies = <json[]>jsonResponse.replies;
                    json|error addSheet = replies[0].addSheet;
                    Sheet newSheet = convertToSheet(!(addSheet is error) ? addSheet : {});
                    return newSheet;
                } else {
                    return setResponseError(jsonResponse);
                }
            } else {
                error err = error(SPREADSHEET_ERROR_CODE,
                    message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return setResError(httpResponse);
        }
    }

    # Delete specified worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - The ID of the sheet to delete
    # + return - Boolean value true on success and error on failure
    public remote function deleteSheet(string spreadsheetId, int sheetId) returns @tainted (boolean|error) {
        http:Request request = new;
        json sheetJSONPayload = {"requests" : [{"deleteSheet":{"sheetId":sheetId}}]};
        request.setJsonPayload(sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.spreadsheetClient->post(deleteSheetPath, request);
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

    # Get spreadsheet values.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + topLeftCell - Top left cell
    # + bottomRightCell - Bottom right cell
    # + return - Sheet values as a two dimensional array on success and error on failure
    public remote function getSheetValues(string spreadsheetId, string sheetName, string topLeftCell = "",
                                                string bottomRightCell = "") returns @tainted (string[][]|error) {
        string[][] values = [];
        string a1Notation = sheetName;
        if (topLeftCell != EMPTY_STRING) {
            a1Notation = a1Notation + EXCLAMATION_MARK + topLeftCell;
        }
        if (bottomRightCell != EMPTY_STRING) {
            a1Notation = a1Notation + COLON + bottomRightCell;
        }
        string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        var httpResponse = self.spreadsheetClient->get(getSheetValuesPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        int i = 0;
                        json[] jsonValues = <json[]> jsonResponse.values;
                        foreach json value in jsonValues {
                            json[] jsonValArray = <json[]> value;
                            int j = 0;
                            string[] val = [];
                            foreach json v in jsonValArray {
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
                    message = "Error occurred while accessing the JSON payload of the response");
                return err;
            }
        } else {
            return setResError(httpResponse);
        }
    }

    # Get column data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to retrieve the data
    # + return - Column data as an array on success and error on failure
    public remote function getColumnData(string spreadsheetId, string sheetName, string column)
                                                  returns @tainted (string[]|error) {
        string[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + column + COLON + column;
        string getColumnDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        var httpResponse = self.spreadsheetClient->get(getColumnDataPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        int i = 0;
                        json[] jsonValues = <json[]> jsonResponse.values;
                        foreach json value in jsonValues {
                            json[] jsonValArray = <json[]> value;
                            if (jsonValArray.length() > 0) {
                                values[i] = jsonValArray[0].toString();
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
            return setResError(httpResponse);
        }
    }

    # Get row data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + row - Row name to retrieve the data
    # + return - Row data as an array on success and error on failure
    public remote function getRowData(string spreadsheetId, string sheetName, int row)
                                                   returns @tainted (string[]|error) {
        string[] values = [];
        string a1Notation = sheetName + EXCLAMATION_MARK + io:sprintf ("%s", row) + COLON + io:sprintf ("%s", row);
        string getRowDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        var httpResponse = self.spreadsheetClient->get(getRowDataPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        int i = 0;
                        json[] jsonValues = <json[]> jsonResponse.values;
                        json[] jsonArray = <json[]> jsonValues[0];
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
            return setResError(httpResponse);
        }
    }

    # Get cell data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to retrieve the data
    # + row - Row name to retrieve the data
    # + return - Cell data on success and error on failure
    public remote function getCellData(string spreadsheetId, string sheetName, string column, int row)
                                                    returns @tainted (string|error) {
        string value = EMPTY_STRING;
        string a1Notation = sheetName + EXCLAMATION_MARK + column + io:sprintf ("%s", row);
        string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation;
        var httpResponse = self.spreadsheetClient->get(getCellDataPath);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            json|error jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    if (!(jsonResponse.values is error)) {
                        json[] responseValues = <json[]> jsonResponse.values;
                        json[] firstResponseValue = <json[]> responseValues[0];
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
            return setResError(httpResponse);
        }
    }

    # Set cell data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to set the data
    # + row - Row name to set the data
    # + value - The value to be updated
    # + return - Boolean value true on success and error on failure
    public remote function setCellData(string spreadsheetId, string sheetName, string column, int row, string value)
                                                     returns @tainted (boolean|error) {
        http:Request request = new;
        json jsonPayload = {"values":[[value]]};
        string a1Notation = sheetName + EXCLAMATION_MARK + column + io:sprintf ("%s", row);
        string setCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation
            + QUESTION_MARK + VALUE_INPUT_OPTION;
        request.setJsonPayload(jsonPayload);
        var httpResponse = self.spreadsheetClient->put(setCellDataPath, request);
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

    # Set spreadsheet values.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + topLeftCell - Top left cell
    # + bottomRightCell - Bottom right cell
    # + values - Values to be updated
    # + return - Boolean value true on success and error on failure
    public remote function setSheetValues(string spreadsheetId, string sheetName, string[][] values, string topLeftCell = "",
                                    string bottomRightCell = "") returns @tainted (boolean|error) {
        http:Request request = new;
        string a1Notation = sheetName;
        if (topLeftCell != EMPTY_STRING ) {
            a1Notation = a1Notation + EXCLAMATION_MARK + topLeftCell;
        }
        if (bottomRightCell != EMPTY_STRING) {
            a1Notation = a1Notation + COLON + bottomRightCell;
        }
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + a1Notation
            + QUESTION_MARK + VALUE_INPUT_OPTION;
        json[][] jsonValues = [];
        int i = 0;
        foreach string[] value in values {
            int j = 0;
            json[] val = [];
            foreach string v in value {
                val[j] = v;
                j = j + 1;
            }
            jsonValues[i] = val;
            i = i + 1;
        }
        json jsonPayload = { "values": jsonValues };
        request.setJsonPayload(<@untainted> jsonPayload);
        var httpResponse = self.spreadsheetClient->put(setValuePath, request);
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
};

# Object for Spreadsheet configuration.
#
# + clientConfig - The http client endpoint
public type SpreadsheetConfiguration record {
    oauth2:DirectTokenConfig clientConfig;
};

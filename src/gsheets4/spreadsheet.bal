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

# Spreadsheet client object.
#
# + spreadsheetId - Id of the spreadsheet
# + properties - Properties of a spreadsheet
# + sheets - The sheets that are part of a spreadsheet
# + spreadsheetUrl - The URL of the spreadsheet
public type Spreadsheet client object {

    public string spreadsheetId;
    private SpreadsheetProperties properties;
    public string spreadsheetUrl;
    Client spreadsheetClient;
    http:Client httpClient;
    public Sheet[] sheets;

    public function __init(Client spreadsheetClient1, string id, SpreadsheetProperties props, string u, Sheet[] sheit) {
        self.spreadsheetClient = spreadsheetClient1;
        self.spreadsheetId = id;
        self.properties = props;
        self.spreadsheetUrl = u;
        self.httpClient = spreadsheetClient1.httpClient;
        self.sheets = sheit;
    }

    # Get the name of the spreadsheet.
    # + return - Name of the spreadsheet object on success and error on failure
    public function getProperties() returns SpreadsheetProperties {
        return self.properties;
    }

    # Get sheets of the spreadsheet.
    # + return - Sheet array on success and error on failure
    public function getSheets() returns Sheet[] | error {
        Sheet[] sheets = [];
        if (self.sheets.length() == 0) {
            error err = error(SPREADSHEET_ERROR_CODE, message = "No sheets found");
            return err;
        }
        sheets = self.sheets;
        return sheets;
    }

    # Get sheets of the spreadsheet.
    # + sheetName - Name of the sheet to retrieve
    # + return - Sheet object on success and error on failure
    public function getSheetByName(string sheetName) returns Sheet | error {
        Sheet[] sheets = self.sheets;
        error err = error(SPREADSHEET_ERROR_CODE, message = "No sheet found");
        if (sheets.length() == 0) {
            return err;
        } else {
            foreach var sheet in sheets {
                if (equalsIgnoreCase(sheet.properties.title, sheetName)) {
                    return sheet;
                }
            }
            return err;
        }
    }

    # Add a new worksheet.
    #
    # + sheetName - The name of the sheet. It is an optional parameter.
    #               If the title is empty, then sheet will be created with the default name.
    # + return - Sheet object on success and error on failure
    public remote function addSheet(string sheetName) returns @tainted Sheet | error {
        http:Request request = new;
        map<json> sheetJSONPayload = {"requests": [{"addSheet": {"properties": {}}}]};
        map<json> jsonSheetProperties = {};
        if (sheetName != EMPTY_STRING) {
            jsonSheetProperties["title"] = sheetName;
        }
        json[] requestsElement = <json[]>sheetJSONPayload["requests"];
        map<json> firstRequestsElement = <map<json>>requestsElement[0];
        map<json> sheetElement = <map<json>>firstRequestsElement.addSheet;
        sheetElement["properties"] = jsonSheetProperties;
        request.setJsonPayload(sheetJSONPayload);
        string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.spreadsheetId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(addSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                if (statusCode == http:STATUS_OK) {
                    json[] replies = <json[]>jsonResponse.replies;
                    json | error addSheet = replies[0].addSheet;
                    Sheet newSheet = convertToSheet(!(addSheet is error) ? addSheet : {}, self.spreadsheetClient,
                    self.spreadsheetId);
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
            return createConnectorError(httpResponse);
        }
    }

    # Delete specified worksheet.
    #
    # + sheetId - The ID of the sheet to delete
    # + return - Boolean value true on success and error on failure
    public remote function removeSheet(int sheetId) returns @tainted error? {
        http:Request request = new;
        json sheetJSONPayload = {"requests": [{"deleteSheet": {"sheetId": sheetId}}]};
        request.setJsonPayload(sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.spreadsheetId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(deleteSheetPath, request);
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

    # Renames the Spreadsheet with the given name.
    #
    # + name - New name for the Spreadsheet
    # + return - Nil on success, else returns an error
    public remote function rename(string name) returns error? {
        http:Request request = new;
        json sheetJSONPayload = {
            "requests": [{
                "updateSpreadsheetProperties": {
                    "properties": {"title": name},
                    "fields": "title"
                }
            }]
        };
        request.setJsonPayload(sheetJSONPayload);
        string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.spreadsheetId + BATCH_UPDATE_REQUEST;
        var httpResponse = self.httpClient->post(deleteSheetPath, request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                //return setResponse(jsonResponse, statusCode);
                self.properties.title = name;
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

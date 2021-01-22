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

# Google spreadsheet connector client endpoint.
#
# + httpClient - Connector http endpoint
# + driveClient - Drive connector http endpoint
public client class Client {

    public http:Client httpClient;
    public http:Client driveClient;

    # Initializes the Google spreadsheet connector client endpoint.
    #
    # +  spreadsheetConfig - Configurations required to initialize the `Client` endpoint
    public function init(SpreadsheetConfiguration spreadsheetConfig) returns error? {
        http:ClientSecureSocket? socketConfig = spreadsheetConfig?.secureSocketConfig;
        self.httpClient = checkpanic new (BASE_URL, {
            auth: spreadsheetConfig.oauth2Config,
            secureSocket: socketConfig
        });

        self.driveClient = checkpanic new (DRIVE_URL, {
            auth: spreadsheetConfig.oauth2Config,
            secureSocket: socketConfig
        });
    }

    # Creates a new spreadsheet.
    #
    # + name - Name of the spreadsheet
    # + return - A Spreadsheet client object on success, else returns an error
    remote function createSpreadsheet(string name) returns @tainted Spreadsheet | error {
        json jsonPayload = {"properties": {"title": name}};
        json | error response = sendRequestWithPayload(self.httpClient, SPREADSHEET_PATH, jsonPayload);
        if (response is json) {
            return convertToSpreadsheet(response, self);
        } else {
            return response;
        }
    }

    # Opens a Spreadsheet by the given ID.
    #
    # + id - ID of the Spreadsheet
    # + return - A Spreadsheet client object on success, else returns an error
    remote function openSpreadsheetById(string id) returns @tainted Spreadsheet | error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + id;
        json | error response = sendRequest(self.httpClient, spreadsheetPath);
        if (response is json) {
            return convertToSpreadsheet(response, self);
        } else {
            return response;
        }
    }

    # Opens a Spreadsheet by the given URL.
    #
    # + url - URL of the Spreadsheet
    # + return - A Spreadsheet client object on success, else returns an error
    remote function openSpreadsheetByUrl(string url) returns @tainted Spreadsheet | error {
        string | error id = self.getIdFromUrl(url);
        if (id is string) {
            return self->openSpreadsheetById(id);
        } else {
            return getSpreadsheetError(id);
        }
    }

    # Get all Spreadsheet files
    # 
    # + return - Array of files records on success, else returns an error
    remote function getAllSpreadsheets() returns  @tainted stream<File>|error {
        File[] files = [];
        return getFilesStream(self.driveClient, files);
    }

    isolated function getIdFromUrl(string url) returns string | error {
        if (!url.startsWith(URL_START)) {
            return error("Invalid url: " + url);
        } else {
            int? endIndex = url.indexOf(URL_END);
            if (endIndex is ()) {
                return error("Invalid url: " + url);
            } else {
                return url.substring(ID_START_INDEX, endIndex);
            }
        }
    }
}

# Holds the parameters used to create a `Client`.
#
# + oauth2Config - OAuth client configuration
# + secureSocketConfig - Secure socket configuration
public type SpreadsheetConfiguration record {
    http:OAuth2DirectTokenConfig oauth2Config;
    http:ClientSecureSocket secureSocketConfig?;
};

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
import ballerina/oauth2;

# Google spreadsheet connector client endpoint.
#
# + httpClient - Connector http endpoint
public type Client client object {

    public http:Client httpClient;

    # Initializes the Google spreadsheet connector client endpoint.
    #
    # +  spreadsheetConfig - Configurations required to initialize the `Client` endpoint
    public function __init(SpreadsheetConfiguration spreadsheetConfig) {
        oauth2:OutboundOAuth2Provider oauth2Provider = new (spreadsheetConfig.oAuthClientConfig);
        http:BearerAuthHandler bearerHandler = new (oauth2Provider);
        http:ClientSecureSocket? socketConfig = spreadsheetConfig?.secureSocketConfig;
        if (socketConfig is http:ClientSecureSocket) {
            self.httpClient = new (BASE_URL, {
                auth: {
                    authHandler: bearerHandler
                },
                secureSocket: socketConfig
            });
        } else {
            self.httpClient = new (BASE_URL, {
                auth: {
                    authHandler: bearerHandler
                }
            });
        }
    }

    # Creates a new spreadsheet.
    #
    # + name - Name of the spreadsheet
    # + return - A Spreadsheet client object on success, else returns an error
    public remote function createSpreadsheet(string name) returns @tainted Spreadsheet | error {
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
    public remote function openSpreadsheetById(string id) returns @tainted Spreadsheet | error {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + id;
        json | error response = sendRequest(self.httpClient, spreadsheetPath);
        if (response is json) {
            return convertToSpreadsheet(response, self);
        } else {
            return response;
        }
    }
};

# Holds the parameters used to create a `Client`.
#
# + oAuthClientConfig - OAuth client configuration
# + secureSocketConfig - Secure socket configuration
public type SpreadsheetConfiguration record {
    oauth2:DirectTokenConfig oAuthClientConfig;
    http:ClientSecureSocket secureSocketConfig?;
};

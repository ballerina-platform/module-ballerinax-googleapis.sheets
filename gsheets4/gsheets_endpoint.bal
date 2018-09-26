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

# SpreadsheetConfiguration is used to set up the Google Spreadsheet configuration. In order to use
# this Connector, you need to provide the oauth2 credentials.
# + clientConfig - The HTTP client congiguration
public type SpreadsheetConfiguration record {
    http:ClientEndpointConfig clientConfig = {};
};

# Google Spreadsheet Endpoint object.
# + spreadsheetConfig - Spreadsheet client endpoint configuration object
# + spreadsheetConnector - Spreadsheet Connector object
public type Client object {

    public SpreadsheetConfiguration spreadsheetConfig = {};
    public SpreadsheetConnector spreadsheetConnector = new;

    # Spreadsheet endpoint initialization function.
    # + config - Spreadsheet client endpoint configuration object
    public function init(SpreadsheetConfiguration config);

    # Get Spreadsheet Connector Client.
    # + return - Spreadsheet Connector Client
    public function getCallerActions() returns SpreadsheetConnector;
};

function Client::init(SpreadsheetConfiguration config) {
    config.clientConfig.url = BASE_URL;
    match config.clientConfig.auth {
        () => {}
        http:AuthConfig authConfig => {
            authConfig.refreshUrl = REFRESH_URL;
            authConfig.scheme = http:OAUTH2;
        }
    }
    self.spreadsheetConnector.httpClient.init(config.clientConfig);
}

function Client::getCallerActions() returns SpreadsheetConnector {
    return self.spreadsheetConnector;
}
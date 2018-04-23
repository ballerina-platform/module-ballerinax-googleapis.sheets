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

documentation {SpreadsheetConfiguration is used to set up the Google Spreadsheet configuration. In order to use
this connector, you need to provide the oauth2 credentials.
    F{{clientConfig}} - The HTTP client congiguration
}
public type SpreadsheetConfiguration {
    http:ClientEndpointConfig clientConfig = {};
};

documentation {Google Spreadsheet Endpoint object.
    E{{}}
    F{{spreadsheetConfig}} - Spreadsheet client endpoint configuration object
    F{{spreadsheetConnector}} - Spreadsheet connector object
}
public type Client object {
    public {
        SpreadsheetConfiguration spreadsheetConfig = {};
        SpreadsheetConnector spreadsheetConnector = new;
    }

    documentation {Spreadsheet endpoint initialization function
        P{{spreadsheetConfig}} - Spreadsheet client endpoint configuration object
    }
    public function init(SpreadsheetConfiguration spreadsheetConfig);

    documentation {Get Spreadsheet connector client
        R{{}} - Spreadsheet connector client
    }
    public function getCallerActions() returns SpreadsheetConnector;
};

public function Client::init(SpreadsheetConfiguration spreadsheetConfig) {
    spreadsheetConfig.clientConfig.url = BASE_URL;
    match spreadsheetConfig.clientConfig.auth {
        () => {}
        http:AuthConfig authConfig => {
            authConfig.refreshUrl = REFRESH_URL;
            authConfig.scheme = SCHEME;
        }
    }
    self.spreadsheetConnector.httpClient.init(spreadsheetConfig.clientConfig);
}

public function Client::getCallerActions() returns SpreadsheetConnector {
    return self.spreadsheetConnector;
}
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

import wso2/oauth2;

documentation {SpreadsheetConfiguration is used to set up the Google Spreadsheet configuration. In order to use
this connector, you to provide the oauth2 credentials.
    F{{oAuth2ClientConfig}} OAuth2 congiguration
}
public type SpreadsheetConfiguration {
    oauth2:OAuth2ClientEndpointConfiguration oAuth2ClientConfig;
};

documentation {Google Spreadsheet Endpoint object.
    F{{oauth2Client}} OAuth2 client
    F{{spreadsheetConfig}} Spreadsheet connector configurations
    F{{spreadsheetConnector}} Spreadsheet connector object
}
public type Client object {
    public {
        oauth2:APIClient oauth2Client;
        SpreadsheetConfiguration spreadsheetConfig;
        SpreadsheetConnector spreadsheetConnector;
    }
    new () {}

    documentation {Spreadsheet connector endpoint initialization function
        P{{spreadsheetConfig}} Spreadsheet connector configuration
    }
    public function init (SpreadsheetConfiguration spreadsheetConfig) {
        spreadsheetConfig.oAuth2ClientConfig.baseUrl = "https://sheets.googleapis.com";
        spreadsheetConfig.oAuth2ClientConfig.refreshTokenEP = "https://www.googleapis.com";
        spreadsheetConfig.oAuth2ClientConfig.refreshTokenPath = "/oauth2/v3/token";
        oauth2Client.init(spreadsheetConfig.oAuth2ClientConfig);
        spreadsheetConnector.oauth2Client = oauth2Client;
    }

    documentation {Register Spreadsheet connector endpoint
        P{{serviceType}} Accepts types of data (int, float, string, boolean, etc)
    }
    public function register (typedesc serviceType) {
    }

    documentation {Start Spreadsheet connector client
    }
    public function start () {
    }

    documentation {Get Spreadsheet connector client
        returns Spreadsheet connector client
    }
    public function getClient () returns SpreadsheetConnector {
        return self.spreadsheetConnector;
    }

    documentation {Stop Spreadsheet connector client}
    public function stop () {

    }

};


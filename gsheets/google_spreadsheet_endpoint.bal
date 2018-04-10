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

@Description {value:"SpreadsheetConfiguration is used to set up the Google Spreadsheet configuration. In order to use
this connector, you to provide the oauth2 credentials."}
public type SpreadsheetConfiguration {
    oauth2:OAuth2ClientEndpointConfiguration oAuth2ClientConfig;
};

@Description {value:"Google Spreadsheet Endpoint object."}
@Field {value:"oauth2EP: OAuth2 client endpoint"}
@Field {value:"spreadsheetConfig: Spreadsheet connector configurations"}
@Field {value:"spreadsheetConnector: Spreadsheet connector object"}
public type Client object {
    public {
        oauth2:Client oauth2EP;
        SpreadsheetConfiguration spreadsheetConfig;
        SpreadsheetConnector spreadsheetConnector;
    }
    new () {}

    @Description {value:"Spreadsheet connector endpoint initialization function"}
    @Param {value:"spreadsheetConfig: Spreadsheet connector configuration"}
    public function init (SpreadsheetConfiguration spreadsheetConfig) {
        spreadsheetConfig.oAuth2ClientConfig.baseUrl = "https://sheets.googleapis.com";
        spreadsheetConfig.oAuth2ClientConfig.refreshTokenEP = "https://www.googleapis.com";
        spreadsheetConfig.oAuth2ClientConfig.refreshTokenPath = "/oauth2/v3/token";
        oauth2EP.init(spreadsheetConfig.oAuth2ClientConfig);
        spreadsheetConnector.oauth2EP = oauth2EP;
    }

    @Description {value:"Register Spreadsheet connector endpoint"}
    @Param {value:"typedesc: Accepts types of data (int, float, string, boolean, etc)"}
    public function register (typedesc serviceType) {
    }

    @Description {value:"Start Spreadsheet connector endpoint"}
    public function start () {
    }

    @Description {value:"Return the Spreadsheet connector client"}
    @Return {value:"SpreadsheetConnector client"}
    public function getClient () returns SpreadsheetConnector {
        return self.spreadsheetConnector;
    }

    @Description {value:"Stop Spreadsheet connector client"}
    public function stop () {

    }

};


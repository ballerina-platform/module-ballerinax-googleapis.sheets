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

package googlespreadsheet;

import ballerina/io;


@Description {value:"Struct to define the Google Spreadsheet configuration."}
public struct SpreadsheetConfiguration {
    oauth2:OAuth2Configuration oauthClientConfig;
    //string accessToken;
    //string baseUrl;
    //string clientId;
    //string clientSecret;
    //string refreshToken;
    //string refreshTokenEP;
    //string refreshTokenPath;
    //boolean useUriParams = false;
    //http:ClientEndpointConfiguration clientConfig;
}

@Description {value:"Google Spreadsheet Endpoint struct."}
public struct SpreadsheetEndpoint {
    SpreadsheetConfiguration spreadsheetConfig;
    SpreadsheetConnector spreadsheetConnector;
}

public function <SpreadsheetEndpoint spreadsheetEP> init (SpreadsheetConfiguration spreadsheetConfig) {
    endpoint oauth2:OAuth2Endpoint oauth2Endpoint {
        baseUrl:"https://sheets.googleapis.com",
        accessToken:spreadsheetConfig.oauthClientConfig.accessToken,
        clientConfig:{},
        refreshToken:spreadsheetConfig.oauthClientConfig.refreshToken,
        clientId:spreadsheetConfig.oauthClientConfig.clientId,
        clientSecret:spreadsheetConfig.oauthClientConfig.clientSecret,
        refreshTokenEP:"https://www.googleapis.com",
        refreshTokenPath:"/oauth2/v3/token",
        useUriParams:true
    };

    spreadsheetEP.spreadsheetConnector = {oauth2EP:oauth2Endpoint};
}

public function <SpreadsheetEndpoint spreadsheetEP> register(typedesc serviceType) {

}

public function <SpreadsheetEndpoint spreadsheetEP> start() {

}

@Description { value:"Returns the connector that client code uses"}
@Return { value:"The connector that client code uses" }
public function <SpreadsheetEndpoint spreadsheetEP> getClient() returns SpreadsheetConnector {
    return spreadsheetEP.spreadsheetConnector;
}

@Description { value:"Stops the registered service"}
@Return { value:"Error occured during registration" }
public function <SpreadsheetEndpoint spreadsheetEP> stop() {

}

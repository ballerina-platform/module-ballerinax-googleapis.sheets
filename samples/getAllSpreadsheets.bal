// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerinax/googleapis_sheets as sheets;
import ballerina/os;
import ballerina/log;

sheets:SpreadsheetConfiguration config = {
    oauthClientConfig: {
            clientId: os:getEnv("CLIENT_ID"),
            clientSecret: os:getEnv("CLIENT_SECRET"),
            refreshUrl: sheets:REFRESH_URL,
            refreshToken: os:getEnv("REFRESH_TOKEN")
    }
};

sheets:Client spreadsheetClient = new (config);

public function main() {

    // Get All Spreadsheets associated with the user account
    stream<sheets:File>|error response = spreadsheetClient->getAllSpreadsheets();
    if (response is stream<sheets:File>) {
        error? e = response.forEach(function (sheets:File spreadsheet) {
            log:print("Spreadsheet Name: " + spreadsheet.name.toString() + " | Spreadsheet ID: " 
                + spreadsheet.id.toString());
        }); 
    } else {
        log:printError("Error: " + response.toString());
    }
}

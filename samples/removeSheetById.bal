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
import ballerina/log;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: refreshToken
    }
};

sheets:Client spreadsheetClient = checkpanic new (spreadsheetConfig);

public function main() {
    string spreadsheetId = "";
    int sheetId = 0;

    // Create Spreadsheet with given name
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("NewSpreadsheet");
    if (response is sheets:Spreadsheet) {
        log:print("Spreadsheet Details: " + response.toString());
        spreadsheetId = response.spreadsheetId;
    } else {
        log:printError("Error: " + response.toString());
    }

    // Add a New Worksheet with given name to the Spreadsheet with the given Spreadsheet ID  
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
    if (sheet is sheets:Sheet) {
        log:print("Sheet Details: " + sheet.toString());
        sheetId = sheet.properties.sheetId;
    } else {
        log:printError("Error: " + sheet.toString());
    }

    // Remove Worksheet with given ID from the Spreadsheet with the given Spreadsheet ID
    error? spreadsheetRes = spreadsheetClient->removeSheet(spreadsheetId, sheetId);
    if (spreadsheetRes is ()) {
        sheets:Sheet|error openRes = spreadsheetClient->getSheetByName(spreadsheetId, "NewSpreadsheet");
        if (openRes is sheets:Sheet) {
            log:print("Sheet Details: " + openRes.toString());
        } else {
            log:printError("Error: " + openRes.toString());
        }
    } else {
        log:printError("Error: " + spreadsheetRes.toString());
    }
}

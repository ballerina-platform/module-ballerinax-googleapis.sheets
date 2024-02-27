// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerinax/googleapis.sheets;
import ballerina/log;
import ballerina/os;

configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");
configurable string & readonly refreshUrl = sheets:REFRESH_URL;

sheets:Client spreadsheetClient = check new ({
    auth: {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl
    }
});

public function main() returns error? {
    string spreadsheetId = "";
    string sheetName = "";

    // Create spreadsheet with given name
    sheets:Spreadsheet response = check spreadsheetClient->createSpreadsheet("NewSpreadsheet");
    spreadsheetId = response.spreadsheetId;


    // Add a new worksheet with given name
    sheets:Sheet sheet = check spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
    sheetName = sheet.properties.title;

    string a1Notation = "B2";

    // Sets the value of the given cell of the sheet
    _ = check spreadsheetClient->setCell(spreadsheetId, sheetName, a1Notation, "ModifiedValue");

    // Gets the value of the given cell of the sheet
    sheets:Cell getValues = check spreadsheetClient->getCell(spreadsheetId, sheetName, a1Notation);
    log:printInfo("Cell Details: " + getValues.toString());

    // Clears the given cell of contents, formats, and data validation rules.
    _ = check spreadsheetClient->clearCell(spreadsheetId, sheetName, a1Notation);

    // Gets the value of the given cell value after clearing the cell
    getValues = check spreadsheetClient->getCell(spreadsheetId, sheetName, a1Notation);
    log:printInfo("Cell Details: " + getValues.toString());

}

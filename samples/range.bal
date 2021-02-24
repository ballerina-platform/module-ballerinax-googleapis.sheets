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
    string spreadsheetId = "";
    string sheetName = "";

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
        sheetName = sheet.properties.title;
    } else {
        log:printError("Error: " + sheet.toString());
    }

    string a1Notation = "A1:D5";
    string[][] entries = [
        ["Name", "Score", "Performance", "Average"],
        ["Keetz", "12"],
        ["Niro", "78"],
        ["Nisha", "98"],
        ["Kana", "86"]
    ];
    sheets:Range range = {a1Notation: a1Notation, values: entries};

    // Sets the values of the given range of cells of the Sheet
    error? spreadsheetRes = spreadsheetClient->setRange(spreadsheetId, sheetName, range);
    if (spreadsheetRes is ()) {
        // Gets the given range of the Sheet
        sheets:Range|error getValuesResult = spreadsheetClient->getRange(spreadsheetId, sheetName, a1Notation);
        if (getValuesResult is sheets:Range) {
            log:print("Range Details: " + getValuesResult.values.toString());
        } else {
            log:printError("Error: " + getValuesResult.toString());
        }

        // Clears the range of contents, formats, and data validation rules
        error? clear = spreadsheetClient->clearRange(spreadsheetId, sheetName, a1Notation);
        if (clear is ()) {
            sheets:Range|error openRes = spreadsheetClient->getRange(spreadsheetId, sheetName, a1Notation);
            if (openRes is sheets:Range) {
                log:print("Range Details: " + openRes.values.toString());
            } else {
                log:printError("Error: " + openRes.toString());
            }
        } else {
            log:printError("Error: " + clear.toString());
        }
    } else {
        log:printError("Error: " + spreadsheetRes.toString());
    }
}

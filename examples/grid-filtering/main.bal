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
        refreshUrl,
        refreshToken
    }
});

public function main() returns error? {
    string spreadsheetId1 = "";
    string spreadsheetId2 = "";
    string sheetName = "";
    int sheetId = 0;

    // Create spreadsheet with given name
    sheets:Spreadsheet response = check spreadsheetClient->createSpreadsheet("NewSpreadsheet1");
    spreadsheetId1 = response.spreadsheetId;

    response = check spreadsheetClient->createSpreadsheet("NewSpreadsheet2");
    spreadsheetId2 = response.spreadsheetId;

    // Add a new Worksheet with given name to the spreadsheet with the given spreadsheet ID
    sheets:Sheet sheet = check spreadsheetClient->addSheet(spreadsheetId1, "NewWorksheet");
    log:printInfo("Sheet Details: " + sheet.toString());
    sheetName = sheet.properties.title;
    sheetId = sheet.properties.sheetId;

    string a1Notation = "A1:D5";
    string[][] entries = [
        ["Name", "Score", "Performance", "Average"],
        ["Keetz", "12"],
        ["Niro", "78"],
        ["Nisha", "98"],
        ["Kana", "86"]
    ];
    sheets:Range range = {a1Notation: a1Notation, values: entries};

    // Set the values of the given range of cells of the Sheet
    _ = check spreadsheetClient->setRange(spreadsheetId1, sheetName, range);

    // Copy the worksheet with a given ID from a source to a destination
    _ = check spreadsheetClient->copyTo(spreadsheetId1, sheetId, spreadsheetId2);

    // Copy the worksheet with a given Name from a source to a destination
    _ = check spreadsheetClient->copyToBySheetName(spreadsheetId1, sheetName, spreadsheetId2);

    // Create or update a column with the given array of values in a worksheet with given name
    string[] values = ["Sami", "66"];
    _ = check spreadsheetClient->createOrUpdateRow(spreadsheetId1, sheetName, 6, values);

    // Define grid filter to filter by range
    sheets:GridRangeFilter gridRangeFilter = {
        sheetId: sheetId,
        startRowIndex: 5,
        endRowIndex: 7,
        startColumnIndex: 0,
        endColumnIndex: 2
    };

    // Filter rows in given worksheets
    sheets:ValueRange[] filteredRows = check spreadsheetClient->getRowByDataFilter(spreadsheetId2, sheetId, gridRangeFilter);
    filteredRows.forEach(function(sheets:ValueRange filteredRow) {
        log:printInfo("Filtered Sheet: " + filteredRow.toString());
    });

    // Get all worksheets in the spreadsheet with the given spreadsheet ID
    sheets:Sheet[] sheetsRes = check spreadsheetClient->getSheets(spreadsheetId2);
    sheetsRes.forEach(function(sheets:Sheet worksheet) {
        log:printInfo("Worksheet Name: " + worksheet.properties.title.toString() + " | Worksheet ID: "
            + worksheet.properties.sheetId.toString());
    });
}

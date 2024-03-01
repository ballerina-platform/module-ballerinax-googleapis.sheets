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

import ballerinax/googleapis.gsheets;
import ballerina/log;
import ballerina/os;

configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");
configurable string & readonly refreshUrl = gsheets:REFRESH_URL;

gsheets:ConnectionConfig spreadsheetConfig = {
    auth: {
        clientId,
        clientSecret,
        refreshUrl,
        refreshToken
    }
};

gsheets:Client spreadsheetClient = check new (spreadsheetConfig);

public function main() returns error? {
    string spreadsheetId = "";
    string sheetName = "";
    int sheetId = 0;
    string a1Notation = "A1:D5";

    // Create spreadsheet with given name
    gsheets:Spreadsheet response = check spreadsheetClient->createSpreadsheet("NewSpreadsheet");
    spreadsheetId = response.spreadsheetId;

    // Add a new worksheet with given name
    gsheets:Sheet sheet = check spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
    sheetName = sheet.properties.title;
    sheetId = sheet.properties.sheetId;

    string[][] entries = [
        ["Name", "Score", "Performance", "Average"],
        ["Keetz", "12"],
        ["Niro", "78"],
        ["Nisha", "98"],
        ["Kana", "86"]
    ];

    gsheets:Range range = {a1Notation: a1Notation, values: entries};

    // Sets the values of the given range of cells of the sheet
    _ = check spreadsheetClient->setRange(spreadsheetId, sheetName, range);

    // Inserts the given number of columns before the given column position with given sheet id
    _ = check spreadsheetClient->addColumnsBefore(spreadsheetId, sheetId, 3, 1);

    // Inserts the given number of columns after the given column position with given sheet name
    _ = check spreadsheetClient->addColumnsAfterBySheetName(spreadsheetId, sheetName, 6, 1);

    // Create or update a column with the given array of values in a worksheet with given name
    string[] values = ["Update", "Column", "Values"];
    _ = check spreadsheetClient->createOrUpdateColumn(spreadsheetId, sheetName, "I", values);

    // Deletes the given number of columns starting at the given column position
    _ = check spreadsheetClient->deleteColumnsBySheetName(spreadsheetId, sheetName, 4, 2);

    // Inserts the given number of rows before the given row position with given sheet ID.
    _ = check spreadsheetClient->addRowsBefore(spreadsheetId, sheetId, 4, 1);

    // Inserts the given number of rows after the given row position with given sheet name.
    _ = check spreadsheetClient->addRowsAfterBySheetName(spreadsheetId, sheetName, 7, 1);

    // Create or update a row with the given array of values with given sheet name.
    values = ["Update", "Row", "Values"];
    _ = check spreadsheetClient->createOrUpdateRow(spreadsheetId, sheetName, 10, values);

    // Get row from a given sheet
    gsheets:Row row = check spreadsheetClient->getRow(spreadsheetId, sheetName, 10);
    log:printInfo("Row : " + row.values.toString());

    // Deletes the given number of rows starting at the given row position
    _ = check spreadsheetClient->deleteRowsBySheetName(spreadsheetId, sheetName, 4, 2);

    // Get row from a given sheet
    row = check spreadsheetClient->getRow(spreadsheetId, sheetName, 2);
    log:printInfo("Row : " + row.values.toString());
}

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

import ballerina/os;
import ballerina/test;
import ballerina/log;

configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");

ConnectionConfig spreadsheetConfig = {
    auth: {
        refreshUrl: REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
};

Client spreadsheetClient = check new (spreadsheetConfig);

var randomString = createRandomUUIDWithoutHyphens();

string spreadsheetId = "";
string createSpreadsheetName = "Ballerina Connector New";
string testSheetName = string `Dance_${randomString.toString()}`;
string[][] entries = [
    ["Name", "Score", "Performance", "Average"],
    ["Keetz", "12"],
    ["Niro", "78"],
    ["Nisha", "98"],
    ["Kana", "84"]
];

// Tests the Client actions

// Spreadsheet Management Operations
@test:Config {
    enable: true
}
function testCreateSpreadsheet() {
    var spreadsheetRes = spreadsheetClient->createSpreadsheet(createSpreadsheetName);
    if (spreadsheetRes is Spreadsheet) {
        log:printInfo(spreadsheetRes.toString());
        test:assertNotEquals(spreadsheetRes.spreadsheetId, "", msg = "Failed to create spreadsheet");
        spreadsheetId =  <@untainted> spreadsheetRes.spreadsheetId;
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testCreateSpreadsheet ],
    enable: true
}
function testOpenSpreadsheetById() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        log:printInfo(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testOpenSpreadsheetById ],
    enable: true
}
function testOpenSpreadsheetByUrl() {
    string url = "https://docs.google.com/spreadsheets/d/" + spreadsheetId + "/edit#gid=0";
    var spreadsheetRes = spreadsheetClient->openSpreadsheetByUrl(url);
    if (spreadsheetRes is Spreadsheet) {
        log:printInfo(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testOpenSpreadsheetByUrl ],
    enable: true
}
function testRenameSpreadsheet() {
    string newName = createSpreadsheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->renameSpreadsheet(spreadsheetId, newName);
    if (spreadsheetRes is ()) {
        var openRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
        if (openRes is Spreadsheet) {
            test:assertEquals(openRes.properties.title, newName, msg = "Failed to rename the spreadsheet");
        } else {
            test:assertFail(openRes.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config { 
    dependsOn: [ testRenameSpreadsheet ],
    enable: true
}
function testGetAllSpreadSheets() {
    log:printInfo("testGetAllSpreadSheets");    
    var response = spreadsheetClient->getAllSpreadsheets();
    if (response is stream<File,error?>) {
        record {|File value;|}|error? fileResponse = response.next();
        if (fileResponse is record {|File value;|}) {
            test:assertNotEquals(fileResponse.value["id"], "", msg = "Found 0 records");
        } else if (fileResponse is error) {
            test:assertFail(fileResponse.message());
        }
    } else {
        test:assertFail(response.message());
    }
}

// Sheet Management Operations

@test:Config {
    dependsOn: [ testGetAllSpreadSheets ],
    enable: true
}
function testAddSheet() {
    var spreadsheetRes = spreadsheetClient->addSheet(spreadsheetId, testSheetName);
    if (spreadsheetRes is Sheet) {
        log:printInfo(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.properties.title, testSheetName, msg = "Failed to add a new sheet");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testAddSheet ],
    enable: true
}
function testGetSheetByName() {
    var spreadsheetRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (spreadsheetRes is Sheet) {
        log:printInfo(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.properties.title, testSheetName, msg = "Failed to get the sheet by name");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testGetSheetByName ],
    enable: true
}
function testRenameSheet() {
    string newName = testSheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->renameSheet(spreadsheetId, "Sheet1", newName);
    if (spreadsheetRes is ()) {
        var openRes = spreadsheetClient->getSheetByName(spreadsheetId, newName);
        if (openRes is Sheet) {
            test:assertEquals(openRes.properties.title, newName, msg = "Failed to rename the sheet");
        } else {
            test:assertFail(openRes.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testRenameSheet ],
    enable: true
}
function testRemoveSheet() {
    string newName = string `${testSheetName}_${randomString.toString()}`;
    var openRes = spreadsheetClient->addSheet(spreadsheetId, newName);
    if (openRes is Sheet) {
        test:assertEquals(openRes.properties.title, newName, msg = "Failed to remove the sheet");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->removeSheet(spreadsheetId, sheetId);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to remove the sheet");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testRemoveSheet ],
    enable: true
}
function testRemoveSheetByName() {
    string newName = string `${testSheetName}_${randomString.toString()}`;
    var openRes = spreadsheetClient->addSheet(spreadsheetId, newName);
    if (openRes is Sheet) {
        test:assertEquals(openRes.properties.title, newName, msg = "Failed to remove the sheet");
        var spreadsheetRes = spreadsheetClient->removeSheetByName(spreadsheetId, newName);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to remove the sheet");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testRemoveSheetByName ],
    enable: true
}
function testGetSheets() {
    var spreadsheetRes = spreadsheetClient->getSheets(spreadsheetId);
    if (spreadsheetRes is Sheet[]) {
        log:printInfo(spreadsheetRes.toString());
        test:assertNotEquals(spreadsheetRes.length(), 0, msg = "Failed to retrieve the sheets");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

// Sheet Service Operations

@test:Config {
    dependsOn: [ testGetSheets ],
    enable: true
}
function testSetRange() {
    Range range = {a1Notation: "A1:D5", values: entries};
    var spreadsheetRes = spreadsheetClient->setRange(spreadsheetId, testSheetName, range);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to set the values of the range");
}

@test:Config {
    dependsOn: [ testSetRange ],
    enable: true
}
function testGetRange() {
    var spreadsheetRes = spreadsheetClient->getRange(spreadsheetId, testSheetName, "A1:D5", "FORMULA");
    if (spreadsheetRes is Range) {
        log:printInfo(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.values, entries, msg = "Failed to get the values of the range");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testGetRange ],
    enable: true
}
function testClearRange() {
    Range range = {a1Notation: "F1:I5", values: entries};
    var openRes = spreadsheetClient->setRange(spreadsheetId, testSheetName, range);
    test:assertEquals(openRes, (), msg = "Failed to set the values of the range");
    if (openRes is ()) {
        var spreadsheetRes = spreadsheetClient->clearRange(spreadsheetId, testSheetName, "F1:I5");
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the range");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testClearRange ],
    enable: true
}
function testAddColumnsBefore() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add columns before the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addColumnsBefore(spreadsheetId, sheetId, 3, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add columns before the given index");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testAddColumnsBefore ],
    enable: true
}
function testAddColumnsBeforeBySheetName() {
    string newName = testSheetName + " Renamed";

    Range range = {a1Notation: "A1:D5", values: entries};
    var setRangeRes = spreadsheetClient->setRange(spreadsheetId, newName, range);
    test:assertEquals(setRangeRes, (), msg = "Failed to set the values of the range");

    var spreadsheetRes = spreadsheetClient->addColumnsBeforeBySheetName(spreadsheetId, newName, 3, 2);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to add columns before the given index");
}

@test:Config {
    dependsOn: [ testAddColumnsBeforeBySheetName ],
    enable: true
}
function testAddColumnsAfter() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add columns after the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addColumnsAfter(spreadsheetId, sheetId, 5, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add columns after the given index");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testAddColumnsAfter ],
    enable: true
}
function testAddColumnsAfterBySheetName() {
    string newName = testSheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->addColumnsAfterBySheetName(spreadsheetId, newName, 5, 2);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to add columns after the given index");
}

@test:Config {
    dependsOn: [ testAddColumnsAfterBySheetName ],
    enable: true
}
function testCreateOrUpdateColumn() {
    (string|int|decimal)[] values = ["Update", "Column", "Values"];
    var spreadsheetRes = spreadsheetClient->createOrUpdateColumn(spreadsheetId, testSheetName, "I", values);
    if (spreadsheetRes is ()) {
        test:assertEquals(spreadsheetRes, (), msg = "Failed to create or update column");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testCreateOrUpdateColumn ],
    enable: true
}
function testGetColumn() {
    var spreadsheetRes = spreadsheetClient->getColumn(spreadsheetId, testSheetName, "I", "FORMULA");
    if (spreadsheetRes is Column) {
        log:printInfo(spreadsheetRes.toString());
        (int|string|decimal)[] expectedValue = ["Update", "Column", "Values"];
        test:assertEquals(spreadsheetRes.values, expectedValue, msg = "Failed to get the column values");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testGetColumn ],
    enable: true
}
function testDeleteColumns() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to delete columns");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->deleteColumns(spreadsheetId, sheetId, 3, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to delete columns");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testDeleteColumns ],
    enable: true
}
function testDeleteColumnsBySheetName() {
    string newName = testSheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->deleteColumnsBySheetName(spreadsheetId, newName, 3, 2);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to delete columns");
}

@test:Config {
    dependsOn: [ testDeleteColumnsBySheetName ],
    enable: true
}
function testAddRowsBefore() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add rows before the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addRowsBefore(spreadsheetId, sheetId, 4, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add rows before the given index");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testAddRowsBefore ],
    enable: true
}
function testAddRowsBeforeBySheetName() {
    string newName = testSheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->addRowsBeforeBySheetName(spreadsheetId, newName, 4, 2);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to add rows before the given index");
}

@test:Config {
    dependsOn: [ testAddRowsBeforeBySheetName ],
    enable: true
}
function testAddRowsAfter() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add rows after the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addRowsAfter(spreadsheetId, sheetId, 6, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add rows after the given index");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testAddRowsAfter ],
    enable: true
}
function testAddRowsAfterBySheetName() {
    string newName = testSheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->addRowsAfterBySheetName(spreadsheetId, newName, 6, 2);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to add rows after the given index");
}

@test:Config {
    dependsOn: [ testAddRowsAfterBySheetName ],
    enable: true
}
function testCreateOrUpdateRow() {
    (string|int|decimal)[] values = ["Update", "Row", "Values"];
    var spreadsheetRes = spreadsheetClient->createOrUpdateRow(spreadsheetId, testSheetName, 10, values);
    if (spreadsheetRes is ()) {
        test:assertEquals(spreadsheetRes, (), msg = "Failed to create or update row");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}


@test:Config {
    dependsOn: [ testCreateOrUpdateRow ],
    enable: true
}
function testGetRow() {
    var spreadsheetRes = spreadsheetClient->getRow(spreadsheetId, testSheetName, 10, "FORMULA");
    if (spreadsheetRes is Row) {
        log:printInfo(spreadsheetRes.toString());
        (int|string|decimal)[] expectedValue = ["Update", "Row", "Values"];
        test:assertEquals(spreadsheetRes.values, expectedValue, msg = "Failed to get the row values");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testGetRow ],
    enable: true
}
function testDeleteRows() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to delete rows");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->deleteRows(spreadsheetId, sheetId, 4, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to delete rows");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testDeleteRows ],
    enable: true
}
function testDeleteRowsBySheetName() {
    string newName = testSheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->deleteRowsBySheetName(spreadsheetId, newName, 4, 2);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to delete rows");
}

@test:Config {
    dependsOn: [ testDeleteRowsBySheetName ],
    enable: true
}
function testSetCell() {
    var spreadsheetRes = spreadsheetClient->setCell(spreadsheetId, testSheetName, "H1", "ModifiedValue");
    if (spreadsheetRes is ()) {
        test:assertEquals(spreadsheetRes, (), msg = "Failed to set the cell value");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testSetCell ],
    enable: true
}
function testGetCell() {
    var spreadsheetRes = spreadsheetClient->getCell(spreadsheetId, testSheetName, "H1", "FORMULA");
    if (spreadsheetRes is Cell) {
        log:printInfo(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.value, "ModifiedValue", msg = "Failed to get the cell value");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testGetCell ],
    enable: true
}
function testClearCell() {
    var spreadsheetRes = spreadsheetClient->clearCell(spreadsheetId, testSheetName, "H1");
    if (spreadsheetRes is ()) {
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the cell");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testClearCell ],
    enable: true
}
function testAppendRowToSheet() {
    string[] values = ["Appending", "Some", "Values"];
    var spreadsheetRes = spreadsheetClient->appendRowToSheet(spreadsheetId, testSheetName, values);
    if (spreadsheetRes is ()) {
        test:assertEquals(spreadsheetRes, (), msg = "Appending a row to sheet failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testAppendRowToSheet ],
    enable: true
}
function testAppendRow() {
    string[] values = ["Appending", "Some", "Values"];
    var spreadsheetRes = spreadsheetClient->appendRowToSheet(spreadsheetId, testSheetName, values, "F1:H3");
    if (spreadsheetRes is ()) {
        test:assertEquals(spreadsheetRes, (), msg = "Appending a row to range failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testAppendRow ],
    enable: true
}
function testAppendCell() {
    string[] value = ["AppendingValue"];
    var spreadsheetRes = spreadsheetClient->appendRowToSheet(spreadsheetId, testSheetName, value, "F1");
    if (spreadsheetRes is ()) {
        test:assertEquals(spreadsheetRes, (), msg = "Appending a cell to range failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testAppendCell ],
    enable: true
}
function testCopyTo() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to copy the sheet");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->copyTo(spreadsheetId, sheetId, spreadsheetId);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to copy the sheet");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testAppendRow ],
    enable: true
}
function testAppendValueToTestSetMetadata() returns error? {
    string[] values = ["Appending", "Some", "Values for Metadata"];
    var spreadsheetRes = spreadsheetClient->appendValue(spreadsheetId, values, <A1Range>{sheetName: testSheetName});
    if spreadsheetRes !is error {
        test:assertEquals({"rowPosition": spreadsheetRes["rowPosition"], "values": spreadsheetRes["values"], "startIndex": spreadsheetRes["a1Range"].startIndex, "endIndex": spreadsheetRes["a1Range"].endIndex},
        {"rowPosition": 1, "values": ["Appending", "Some", "Values for Metadata"], startIndex: "A1", endIndex: "C1"}, msg = "Appending a row to sheet failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testAppendValueToTestSetMetadata ],
    enable: true
}

function testSetRowMetadata() returns error? {
    Sheet sheet = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    error? response = spreadsheetClient->setRowMetaData(spreadsheetId, sheet.properties.sheetId, 1, "DOCUMENT", "metadataKey", "value1");
    if response !is error {
        test:assertEquals(response, (), msg = "Appending a row to sheet with metadata failed");
    } else {
        test:assertFail(response.message());
    }
}

@test:Config {
    dependsOn: [ testSetRowMetadata ],
    enable: true
}
function testAppendValueToSheetForFilterTests() returns error? {
    string[] values = ["Appending", "Some", "Values"];
    var spreadsheetRes = spreadsheetClient->appendValue(spreadsheetId, values, <A1Range>{sheetName: testSheetName});
    if spreadsheetRes !is error {
        test:assertEquals({"rowPosition": spreadsheetRes["rowPosition"], "values": spreadsheetRes["values"], "startIndex": spreadsheetRes["a1Range"].startIndex, "endIndex": spreadsheetRes["a1Range"].endIndex},
        {"rowPosition": 2, "values": ["Appending", "Some", "Values"], startIndex: "A2", endIndex: "C2"}, msg = "Appending a row to sheet failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
    spreadsheetRes = spreadsheetClient->appendValue(spreadsheetId, values, <A1Range>{sheetName: testSheetName});
    if spreadsheetRes !is error {
        test:assertEquals({"rowPosition": spreadsheetRes["rowPosition"], "values": spreadsheetRes["values"], "startIndex": spreadsheetRes["a1Range"].startIndex, "endIndex": spreadsheetRes["a1Range"].endIndex},
        {"rowPosition": 3, "values": ["Appending", "Some", "Values"], startIndex: "A3", endIndex: "C3"}, msg = "Appending a row to sheet failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAppendValueToSheetForFilterTests],
    enable: true
}
function testUpdateRowFromSheetWithFilter() returns error? {
    (string|float|boolean)[] values = ["Appending", false, 0.1f];
    string[] values_metadata = ["Appending", "Some", "Values Updated With Metadata"];
    string[] values_gridRange = ["Appending", "Some", "Values Updated With gridrange"];

    Sheet sheet = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    error? response = spreadsheetClient->updateRowByDataFilter(spreadsheetId, sheet.properties.sheetId, <A1Range>{sheetName: testSheetName, startIndex: "A3", endIndex: "C3"}, values, valueInputOption = "USER_ENTERED");
    if response !is error {
        test:assertEquals(response, (), msg = "Update using A1Range filter failed");
    } else {
        test:assertFail(response.message());
    }

    GridRangeFilter gridRangeFilter = {sheetId: sheet.properties.sheetId, startRowIndex: 1, endRowIndex: 2, startColumnIndex: 0, endColumnIndex: 4};
    DeveloperMetadataLookupFilter developerMetadataLookupFilter = {locationType: "ROW", metadataKey: "metadataKey", metadataValue: "value1"};
    response = spreadsheetClient->updateRowByDataFilter(spreadsheetId, sheet.properties.sheetId, gridRangeFilter, values_gridRange, valueInputOption = "USER_ENTERED");
    if response !is error {
        test:assertEquals(response, (), msg = "Update using GridRangeFilter failed");
    } else {
        test:assertFail(response.message());
    }

    response = spreadsheetClient->updateRowByDataFilter(spreadsheetId, sheet.properties.sheetId, developerMetadataLookupFilter, values_metadata, valueInputOption = "USER_ENTERED");
    if response !is error {
        test:assertEquals(response, (), msg = "Update using DeveloperMetadataLookupFilter failed");
    } else {
        test:assertFail(response.message());
    }
}


@test:Config {
    dependsOn: [ testUpdateRowFromSheetWithFilter ],
    enable: true
}
function testGetRowFromSheetWithFilter() returns error? {
    Sheet sheet = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    ValueRange[]|error spreadsheetRes = spreadsheetClient->getRowByDataFilter(spreadsheetId, sheet.properties.sheetId, <A1Range>{sheetName: testSheetName, startIndex: "A3", endIndex: "C3"});
    if spreadsheetRes is ValueRange[] {
        test:assertEquals({"rowPosition": spreadsheetRes[0]["rowPosition"], "values": spreadsheetRes[0]["values"], "startIndex": spreadsheetRes[0]["a1Range"].startIndex, "endIndex": spreadsheetRes[0]["a1Range"].endIndex},
        {"rowPosition": 3, "values": ["Appending", "FALSE", "0.1"], startIndex: "A3", endIndex: "C3"}, msg = "Fetching of Data using A1Range filter failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
    GridRangeFilter gridRangeFilter = {sheetId: sheet.properties.sheetId, startRowIndex: 1, endRowIndex: 2, startColumnIndex: 0, endColumnIndex: 4};
    DeveloperMetadataLookupFilter developerMetadataLookupFilter = {locationType: "ROW", metadataKey: "metadataKey", metadataValue: "value1"};
    spreadsheetRes = spreadsheetClient->getRowByDataFilter(spreadsheetId, sheet.properties.sheetId, gridRangeFilter);
    if spreadsheetRes is ValueRange[] {
        test:assertEquals({"rowPosition": spreadsheetRes[0]["rowPosition"], "values": spreadsheetRes[0]["values"], "startIndex": spreadsheetRes[0]["a1Range"].startIndex, "endIndex": spreadsheetRes[0]["a1Range"].endIndex},
        {"rowPosition": 2, "values": ["Appending", "Some", "Values Updated With gridrange"], startIndex: "A2", endIndex: "D2"}, msg = "Fetching of Data using GridRangeFilter failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }

    spreadsheetRes = spreadsheetClient->getRowByDataFilter(spreadsheetId, sheet.properties.sheetId, developerMetadataLookupFilter);
    if spreadsheetRes is ValueRange[] {
        test:assertEquals({"rowPosition": spreadsheetRes[0]["rowPosition"], "values": spreadsheetRes[0]["values"], "startIndex": spreadsheetRes[0]["a1Range"].startIndex, "endIndex": spreadsheetRes[0]["a1Range"].endIndex},
        {"rowPosition": 1, "values": ["Appending", "Some", "Values Updated With Metadata"], startIndex: "A1", endIndex: "AB1"}, msg = "Fetching of Data using DeveloperMetadataLookupFilter failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}
@test:Config {}
function testGetRowFromSheetWithAFaultyMetadataFilter() returns error? {
    Sheet sheet = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    DeveloperMetadataLookupFilter developerMetadataLookupFilter = {locationType: "ROW", metadataKey: "metadataKey", metadataValue: "valueNone"};
    ValueRange[]|error rowResp = spreadsheetClient->getRowByDataFilter(spreadsheetId, sheet.properties.sheetId, developerMetadataLookupFilter);
    if rowResp !is error {
        test:assertEquals(rowResp, <Row[]>[], msg = "Fetching with faulty filter failed");
    } else {
        test:assertFail(rowResp.message());
    }
}

@test:Config {
    dependsOn: [testGetRowFromSheetWithFilter],
    enable: true
}
function testDeleteRowFromSheetWithFilter() returns error? {
    Sheet sheet = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    error? response = spreadsheetClient->deleteRowByDataFilter(spreadsheetId, sheet.properties.sheetId, <A1Range>{sheetName: testSheetName, startIndex: "A3", endIndex: "C3"});
    if response is () {
        test:assertEquals(response, (), msg = "Delete using A1Range failed");
    } else {
        test:assertFail(response.message());
    }

    GridRangeFilter gridRangeFilter = {sheetId: sheet.properties.sheetId, startRowIndex: 1, endRowIndex: 2, startColumnIndex: 0, endColumnIndex: 4};
    DeveloperMetadataLookupFilter developerMetadataLookupFilter = {locationType: "ROW", metadataKey: "metadataKey", metadataValue: "value1"};
    response = spreadsheetClient->deleteRowByDataFilter(spreadsheetId, sheet.properties.sheetId, gridRangeFilter);
    if response is () {
        test:assertEquals(response, (), msg = "Delete using grid range filter failed");
    } else {
        test:assertFail(response.message());
    }

    response = spreadsheetClient->deleteRowByDataFilter(spreadsheetId, sheet.properties.sheetId, developerMetadataLookupFilter);
    if response is () {
        test:assertEquals(response, (), msg = "Delete using metadata filter failed");
    } else {
        test:assertFail(response.message());
    }
}

@test:Config {
    dependsOn: [ testDeleteRowFromSheetWithFilter ],
    enable: true
}
function testGetRowFromSheetWithFilterAfterDelete() returns error? {
    Sheet sheet = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    ValueRange[]|error rowResp = spreadsheetClient->getRowByDataFilter(spreadsheetId, sheet.properties.sheetId, <A1Range>{sheetName: testSheetName, startIndex: "A3", endIndex: "C3"});
    if rowResp !is error {
        test:assertEquals(rowResp, <ValueRange[]>[], msg = "Fetching of Data using A1Range filter failed");
    } else {
        test:assertFail(rowResp.message());
    }
    GridRangeFilter gridRangeFilter = {sheetId: sheet.properties.sheetId, startRowIndex: 1, endRowIndex: 2, startColumnIndex: 0, endColumnIndex: 4};
    DeveloperMetadataLookupFilter developerMetadataLookupFilter = {locationType: "ROW", metadataKey: "metadataKey", metadataValue: "value1"};
    rowResp = spreadsheetClient->getRowByDataFilter(spreadsheetId, sheet.properties.sheetId, gridRangeFilter);
    if rowResp !is error {
        test:assertEquals(rowResp, <ValueRange[]>[], msg = "Fetching of Data using GridRangeFilter failed");
    } else {
        test:assertFail(rowResp.message());
    }
    rowResp = spreadsheetClient->getRowByDataFilter(spreadsheetId, sheet.properties.sheetId, developerMetadataLookupFilter);
    if rowResp !is error {
        test:assertEquals(rowResp, <ValueRange[]>[], msg = "Fetching of Data using DeveloperMetadataLookupFilter failed");
    } else {
        test:assertFail(rowResp.message());
    }
}

@test:Config {
    dependsOn: [ testCopyTo ],
    enable: true
}
function testCopyToBySheetName() {
    var spreadsheetRes = spreadsheetClient->copyToBySheetName(spreadsheetId, testSheetName, spreadsheetId);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to copy the sheet");
}

@test:Config {
    dependsOn: [ testCopyToBySheetName ],
    enable: true
}
function testClearAll() {
    string newName = "Copy of " + testSheetName;
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, newName);
    if openRes is Sheet {
        log:printInfo(openRes.toString());
        test:assertEquals(openRes.properties.title, newName, msg = "Failed to clear the sheet");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->clearAll(spreadsheetId, sheetId);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the sheet");
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: [ testClearAll ],
    enable: true
}
function testClearAllBySheetName() {
    var spreadsheetRes = spreadsheetClient->clearAllBySheetName(spreadsheetId, testSheetName);
    if spreadsheetRes is () {
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the sheet");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testClearCell ],
    enable: true
}
function testAppendValue() {
    string[] values = ["Appending", "Some", "Values"];
    var spreadsheetRes = spreadsheetClient->appendValue(spreadsheetId, values, <A1Range>{sheetName: testSheetName});
    if spreadsheetRes is ValueRange {
        test:assertEquals({"rowPosition": spreadsheetRes["rowPosition"], "values": spreadsheetRes["values"], "startIndex": spreadsheetRes["a1Range"].startIndex, "endIndex": spreadsheetRes["a1Range"].endIndex},
        {"rowPosition": 1, "values": ["Appending", "Some", "Values"], "startIndex": "A1", "endIndex": "C1"}, msg = "Appending a row to sheet failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testAppendValue ],
    enable: true
}
function testAppendValueWithBooleanAndFloat() {
    (string|boolean|float)[] values = ["Appending", "Some", "Values", false, 10.0f];
    var spreadsheetRes = spreadsheetClient->appendValue(spreadsheetId, values, <A1Range>{sheetName: testSheetName, startIndex: "F1", endIndex: "I3"});
    if spreadsheetRes is ValueRange {
        test:assertEquals({"rowPosition": spreadsheetRes["rowPosition"], "values": spreadsheetRes["values"], "startIndex": spreadsheetRes["a1Range"].startIndex, "endIndex": spreadsheetRes["a1Range"].endIndex},
        {"rowPosition": 1, "values": ["Appending", "Some", "Values", false, 10.0f], "startIndex": "F1", "endIndex": "J1"}, msg = "Appending a row to range failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}


@test:Config {
    dependsOn: [ testAppendValueWithBooleanAndFloat ],
    enable: true
}
function testAppendValueWithAllDataTypes() {
    decimal dec = 0.2453;
    (string|boolean|float|decimal)[] values = ["Appending", "Some", "Values", false, 10.1f, dec];
    var spreadsheetRes = spreadsheetClient->appendValue(spreadsheetId, values, <A1Range>{sheetName: testSheetName, startIndex: "F1", endIndex: "I3"});
    if spreadsheetRes is ValueRange {
        test:assertEquals({"rowPosition": spreadsheetRes["rowPosition"], "values": spreadsheetRes["values"], "startIndex": spreadsheetRes["a1Range"].startIndex, "endIndex": spreadsheetRes["a1Range"].endIndex},
        {"rowPosition": 2, "values": ["Appending", "Some", "Values", false, 10.1f, dec], "startIndex": "F2", "endIndex": "K2"}, msg = "Appending a row to range failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [ testAppendValueWithBooleanAndFloat ],
    enable: true
}
function testAppendCellWithAppendValue() {
    string[] value = ["AppendingValue"];
    var spreadsheetRes = spreadsheetClient->appendValue(spreadsheetId, value, <A1Range>{sheetName: testSheetName, startIndex: "F1", endIndex: "H3"});
    if spreadsheetRes is ValueRange {
        test:assertEquals({"rowPosition": spreadsheetRes["rowPosition"], "values": spreadsheetRes["values"], "startIndex": spreadsheetRes["a1Range"].startIndex},
        {"rowPosition": 3, "values": ["AppendingValue"], startIndex: "F3"}, msg = "Appending a cell to range failed");
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}


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

import ballerina/config;
import ballerina/system;
import ballerina/test;
import ballerina/log;

SpreadsheetConfiguration config = {
    oauth2Config: {
        accessToken: "<Access token here>",
        refreshConfig: {
            clientId: system:getEnv("CLIENT_ID") == "" ? config:getAsString("CLIENT_ID") :
            system:getEnv("CLIENT_ID"),
            clientSecret: system:getEnv("CLIENT_SECRET") == "" ? config:getAsString("CLIENT_SECRET") :
            system:getEnv("CLIENT_SECRET"),
            refreshUrl: REFRESH_URL,
            refreshToken: system:getEnv("REFRESH_TOKEN") == "" ? config:getAsString("REFRESH_TOKEN") :
            system:getEnv("REFRESH_TOKEN")
        }
    }
};

Client spreadsheetClient = new (config);

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
        log:print(spreadsheetRes.toString());
        test:assertNotEquals(spreadsheetRes.spreadsheetId, "", msg = "Failed to create spreadsheet");
        spreadsheetId =  <@untainted> spreadsheetRes.spreadsheetId;
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"],
    enable: true
}
function testOpenSpreadsheetById() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"],
    enable: true
}
function testOpenSpreadsheetByUrl() {
    string url = "https://docs.google.com/spreadsheets/d/" + spreadsheetId + "/edit#gid=0";
    var spreadsheetRes = spreadsheetClient->openSpreadsheetByUrl(url);
    if (spreadsheetRes is Spreadsheet) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"],
    enable: true
}
function testRenameSpreadsheet() {
    string newName = createSpreadsheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->renameSpreadsheet(spreadsheetId, newName);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        var openRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
        if (openRes is Spreadsheet) {
            test:assertEquals(openRes.properties.title, newName, msg = "Failed to rename the spreadsheet");
        } else {
            test:assertFail(openRes.message());
        }
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}


@test:Config { 
    dependsOn: ["testCreateSpreadsheet"],
    enable: true
}
function testGetAllSpreadSheets() {
    var response = spreadsheetClient->getAllSpreadsheets();
    if (response is stream<File>) {
        var file = response.next();
        test:assertNotEquals(file?.value, "", msg = "Found 0 records");
        
    } else {
        test:assertFail(response.message());
    }
}

// Sheet Management Operations

@test:Config {
    enable: true
}
function testAddSheet() {
    var spreadsheetRes = spreadsheetClient->addSheet(spreadsheetId, testSheetName);
    if (spreadsheetRes is Sheet) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.properties.title, testSheetName, msg = "Failed to add a new sheet");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddSheet"],
    enable: true
}
function testGetSheetByName() {
    var spreadsheetRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (spreadsheetRes is Sheet) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.properties.title, testSheetName, msg = "Failed to get the sheet by name");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddSheet"],
    enable: true
}
function testRenameSheet() {
    string newName = testSheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->renameSheet(spreadsheetId, newName);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        var openRes = spreadsheetClient->getSheetByName(spreadsheetId, newName);
        if (openRes is Sheet) {
            test:assertEquals(openRes.properties.title, newName, msg = "Failed to rename the sheet");
        } else {
            test:assertFail(openRes.message());
        }
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddSheet"],
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
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddSheet"],
    enable: true
}
function testRemoveSheetByName() {
    string newName = string `${testSheetName}_${randomString.toString()}`;
    var openRes = spreadsheetClient->addSheet(spreadsheetId, newName);
    if (openRes is Sheet) {
        test:assertEquals(openRes.properties.title, newName, msg = "Failed to remove the sheet");
        var spreadsheetRes = spreadsheetClient->removeSheetByName(spreadsheetId, newName);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to remove the sheet");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddSheet"],
    enable: true
}
function testGetSheets() {
    var spreadsheetRes = spreadsheetClient->getSheets(spreadsheetId);
    if (spreadsheetRes is Sheet[]) {
        log:print(spreadsheetRes.toString());
        test:assertNotEquals(spreadsheetRes.length(), 0, msg = "Failed to retrieve the sheets");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

// Sheet Service Operations

@test:Config {
    dependsOn: ["testAddSheet"],
    enable: true
}
function testSetRange() {
    Range range = {a1Notation: "A1:D5", values: entries};
    var spreadsheetRes = spreadsheetClient->setRange(spreadsheetId, testSheetName, range);
    test:assertEquals(spreadsheetRes, (), msg = "Failed to set the values of the range");
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"],
    enable: true
}
function testGetRange() {
    var spreadsheetRes = spreadsheetClient->getRange(spreadsheetId, testSheetName, "A1:D5");
    if (spreadsheetRes is Range) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.values, entries, msg = "Failed to get the values of the range");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"],
    enable: true
}
function testClearRange() {
    Range range = {a1Notation: "F1:I5", values: entries};
    var openRes = spreadsheetClient->setRange(spreadsheetId, testSheetName, range);
    test:assertEquals(openRes, (), msg = "Failed to set the values of the range");
    if (openRes is ()) {
        var spreadsheetRes = spreadsheetClient->clearRange(spreadsheetId, testSheetName, "F1:I5");
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the range");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"],
    enable: true
}
function testAddColumnsBefore() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add columns before the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addColumnsBefore(spreadsheetId, sheetId, 3, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add columns before the given index");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddColumnsBefore"],
    enable: true
}
function testAddColumnsAfter() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add columns after the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addColumnsAfter(spreadsheetId, sheetId, 5, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add columns after the given index");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddSheet"],
    enable: true
}
function testCreateOrUpdateColumn() {
    string[] values = ["Update", "Column", "Values"];
    var spreadsheetRes = spreadsheetClient->createOrUpdateColumn(spreadsheetId, testSheetName, "I", values);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Failed to create or update column");
    } else {
        log:print(spreadsheetRes.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateOrUpdateColumn"],
    enable: true
}
function testGetColumn() {
    var spreadsheetRes = spreadsheetClient->getColumn(spreadsheetId, testSheetName, "I");
    if (spreadsheetRes is (string|int|float)[]) {
        log:print(spreadsheetRes.toString());
        (int|string|float)[] expectedValue = ["Update", "Column", "Values"];
        test:assertEquals(spreadsheetRes.toString(), expectedValue.toString(), msg = "Failed to get the column values");
    } else {
        log:print(spreadsheetRes.toString());
    }
}

@test:Config {
    dependsOn: ["testAddColumnsBefore"],
    enable: true
}
function testDeleteColumns() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to delete columns");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->deleteColumns(spreadsheetId, sheetId, 3, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to delete columns");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"],
    enable: true
}
function testAddRowsBefore() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add rows before the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addRowsBefore(spreadsheetId, sheetId, 4, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add rows before the given index");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddRowsBefore"],
    enable: true
}
function testAddRowsAfter() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to add rows after the given index");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->addRowsAfter(spreadsheetId, sheetId, 6, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to add rows after the given index");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddSheet"],
    enable: true
}
function testCreateOrUpdateRow() {
    string[] values = ["Update", "Row", "Values"];
    var spreadsheetRes = spreadsheetClient->createOrUpdateRow(spreadsheetId, testSheetName, 10, values);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Failed to create or update row");
    } else {
        log:print(spreadsheetRes.toString());
    }
}


@test:Config {
    dependsOn: ["testCreateOrUpdateRow"],
    enable: true
}
function testGetRow() {
    var spreadsheetRes = spreadsheetClient->getRow(spreadsheetId, testSheetName, 10);
    if (spreadsheetRes is (string|int|float)[]) {
        log:print(spreadsheetRes.toString());
        (int|string|float)[] expectedValue = ["Update", "Row", "Values"];
        test:assertEquals(spreadsheetRes.toString(), expectedValue.toString(), msg = "Failed to get the row values");
    } else {
        log:print(spreadsheetRes.toString());
    }
}

@test:Config {
    dependsOn: ["testAddRowsBefore"],
    enable: true
}
function testDeleteRows() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to delete rows");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->deleteRows(spreadsheetId, sheetId, 4, 2);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to delete rows");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testAddSheet"],
    enable: true
}
function testSetCell() {
    var spreadsheetRes = spreadsheetClient->setCell(spreadsheetId, testSheetName, "H1", "ModifiedValue");
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Failed to set the cell value");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testSetCell"],
    enable: true
}
function testGetCell() {
    var spreadsheetRes = spreadsheetClient->getCell(spreadsheetId, testSheetName, "H1");
    if (spreadsheetRes is (string|int|float)) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes.toString(), "ModifiedValue", msg = "Failed to get the cell value");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testSetCell", "testGetCell"],
    enable: true
}
function testClearCell() {
    var spreadsheetRes = spreadsheetClient->clearCell(spreadsheetId, testSheetName, "H1");
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the cell");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testDeleteRows"],
    enable: true
}
function testAppendRowToSheet() {
    string[] values = ["Appending", "Some", "Values"];
    var spreadsheetRes = spreadsheetClient->appendRowToSheet(spreadsheetId, testSheetName, values);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Appending a row to sheet failed");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testAppendRowToSheet"],
    enable: true
}
function testAppendRow() {
    string[] values = ["Appending", "Some", "Values"];
    var spreadsheetRes = spreadsheetClient->appendRow(spreadsheetId, testSheetName, "F1:H3", values);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Appending a row to range failed");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: ["testAppendRow"],
    enable: true
}
function testAppendCell() {
    string value = "AppendingValue";
    var spreadsheetRes = spreadsheetClient->appendCell(spreadsheetId, testSheetName, "F1", value);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Appending a cell to range failed");
    } else {
        log:print(spreadsheetRes.toString());
    }
}

@test:Config {
    dependsOn: ["testAddSheet"],
    enable: true
}
function testCopyTo() {
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, testSheetName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, testSheetName, msg = "Failed to copy the sheet");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->copyTo(spreadsheetId, sheetId, spreadsheetId);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to copy the sheet");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testCopyTo"],
    enable: true
}
function testClearAll() {
    string newName = "Copy of " + testSheetName;
    var openRes = spreadsheetClient->getSheetByName(spreadsheetId, newName);
    if (openRes is Sheet) {
        log:print(openRes.toString());
        test:assertEquals(openRes.properties.title, newName, msg = "Failed to clear the sheet");
        int sheetId = openRes.properties.sheetId;
        var spreadsheetRes = spreadsheetClient->clearAll(spreadsheetId, sheetId);
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the sheet");
        if (spreadsheetRes is ()) {
            log:print(spreadsheetRes.toString());
        } else {
            log:print(spreadsheetRes.toString());
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        log:print(openRes.toString());
        test:assertFail(openRes.message());
    }
}

@test:Config {
    dependsOn: ["testClearAll"],
    enable: true
}
function testClearAllBySheetName() {
    var spreadsheetRes = spreadsheetClient->clearAllBySheetName(spreadsheetId, testSheetName);
    if (spreadsheetRes is ()) {
        log:print(spreadsheetRes.toString());
        test:assertEquals(spreadsheetRes, (), msg = "Failed to clear the sheet");
    } else {
        log:print(spreadsheetRes.toString());
        test:assertFail(spreadsheetRes.message());
    }
}

// // Tests the Client actions
// @test:Config {
//     enable: false
// }
// function testCreateSpreadsheet() {
//     var spreadsheetRes = spreadsheetClient->createSpreadsheet(createSpreadsheetName);
//     if (spreadsheetRes is Spreadsheet) {
//         Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
//         test:assertNotEquals(spreadsheetRes.spreadsheetId, "", msg = "Failed to create spreadsheet");
//         spreadsheetId = testSpreadsheet.spreadsheetId;
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testCreateSpreadsheet"],
//     enable: false
// }
// function testOpenSpreadsheetById() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
//         Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     enable: false
// }
// function testOpenSpreadsheetByUrl() {
//     string url = "https://docs.google.com/spreadsheets/d/" + spreadsheetId + "/edit#gid=0";
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetByUrl(url);
//     if (spreadsheetRes is Spreadsheet) {
//         test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
//         Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// //Tests the Spreadsheet client actions
// @test:Config {
//     dependsOn: ["testCreateSpreadsheet"],
//     enable: false
// }
// function testGetProperties() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         SpreadsheetProperties props = spreadsheetRes.getProperties();
//         test:assertEquals(props.title, createSpreadsheetName, msg = "Failed to get properties of the spreadsheet");
//         Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testCreateSpreadsheet"],
//     enable: false
// }
// function testAddSheet() {
//     var response = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (response is Spreadsheet) {
//         Sheet | error addSheetRes = response->addSheet(testSheetName);
//         if (addSheetRes is Sheet) {
//             testSheetId = <@untainted>addSheetRes.properties.sheetId;
//             test:assertNotEquals(addSheetRes.properties.sheetId, "", msg = "Failed to add a new sheet");
//         } else {
//             test:assertFail(addSheetRes.message());
//         }
//     } else {
//         test:assertFail(response.message());

//     }
// }

// @test:Config {
//     dependsOn: ["testCreateSpreadsheet", "testAddSheet"],
//     enable: false
// }
// function testGetSheets() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             test:assertNotEquals(sheets.length(), 0, msg = "Failed to retrieve the sheets");
//             test:assertEquals(sheets[0].parentId, spreadsheetId);
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testCreateSpreadsheet", "testAddSheet"],
//     enable: false
// }
// function testGetSheetByName() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet | error sheet = spreadsheetRes.getSheetByName(testSheetName);
//         if (sheet is Sheet) {
//             test:assertEquals(sheet.properties.title, testSheetName, msg = "Failed to get the sheet by name");
//         } else {
//             test:assertFail(sheet.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testCreateSpreadsheet"],
//     enable: false
// }
// function testRemoveSheet() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet | error addSheetRes = spreadsheetRes->addSheet(testDeleteSheetName);
//         if (addSheetRes is Sheet) {
//             testSheetId = <@untainted>addSheetRes.properties.sheetId;
//             test:assertNotEquals(addSheetRes.properties.sheetId, "", msg = "Failed to remove the sheet");
//             error? removeRes = spreadsheetRes->removeSheet(<@untainted>addSheetRes.id);
//             test:assertEquals(removeRes, (), msg = "Failed to remove the sheet");
//         } else {
//             test:assertFail(addSheetRes.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testCreateSpreadsheet"],
//     enable: false
// }
// function testRename() {
//     string newName = createSpreadsheetName + " Renamed";
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         test:assertEquals(spreadsheetRes.getProperties().title, createSpreadsheetName, msg = "Failed to " +
//         "rename the spreadsheet");
//         error? res = spreadsheetRes->rename(newName);
//         if (res is ()) {
//             createSpreadsheetName = newName;
//             test:assertEquals(spreadsheetRes.getProperties().title, newName, msg = "Failed");
//         } else {
//             test:assertFail(res.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// // Tests the Sheet client actions
// @test:Config {
//     dependsOn: ["testAddSheet"],
//     enable: false
// }
// function testSheetRename() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     string newName = "Renamed";
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var res = sheet->rename(newName);
//             if (res is ()) {
//                 test:assertEquals(sheet.getProperties().title, newName, msg = "Failed to rename the sheet");
//             } else {
//                 test:assertFail(res.message());
//             }
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddSheet", "testSetRange"],
//     enable: false
// }
// function testSetCell() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->setCell("A10", "ModifiedValue");
//             test:assertEquals(setRes, (), msg = "Failed to set the cell value");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddSheet", "testSetCell"],
//     enable: false
// }
// function testGetCell() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->getCell("A10");
//             test:assertEquals(setRes, "ModifiedValue", msg = "Failed to get the cell value");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddSheet", "testSetRange"],
//     enable: false
// }
// function testGetRow() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var valueReturned = sheet->getRow(2);
//             //var valueReturned contains (string | int | float)[]
//             (int|string|float)[] expectedValue = ["Keetz", "12"];
//             test:assertEquals(valueReturned.toString(), expectedValue.toString() , msg = "Failed to get the row values");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddSheet", "testSetRange"],
//     enable: false
// }
// function testGetColumn() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var valueReturned = sheet->getColumn("B");
//             //var valueReturned contains (string | int | float)[]
//             (int|string|float)[] expectedValue = ["Score", "12", "78", "98", "86"];
            
//             test:assertEquals(valueReturned.toString(), expectedValue.toString(), msg = "Failed to get the column values");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddSheet"],
//     enable: false
// }
// function testSetRange() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             Range range = {a1Notation: "A1:D5", values: entries};
//             var setRes = sheet->setRange(<@untainted>range);
//             test:assertEquals(setRes, (), msg = "Failed to set the values of the range");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddSheet", "testSetRange"],
//     enable: false
// }
// function testGetRange() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->getRange("A1:D5");
//             if (setRes is Range) {
//                 test:assertEquals(setRes.values, entries, msg = "Failed to get the values of the range");
//             } else {
//                 test:assertFail(setRes.message());
//             }
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testSetRange", "testGetRange", "testGetColumn", "testGetCell", "testGetRow"],
//     enable: false
// }
// function testAddRowsBefore() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->addRowsBefore(1, 2);
//             test:assertEquals(setRes, (), msg = "Failed to add rows before the given index");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddRowsBefore"],
//     enable: false
// }
// function testAddRowsAfter() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->addRowsAfter(4, 2);
//             test:assertEquals(setRes, (), msg = "Failed to add rows after the given index");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddRowsBefore"],
//     enable: false
// }
// function testAddColumnsBefore() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->addColumnsBefore(1, 2);
//             test:assertEquals(setRes, (), msg = "Failed to add columns before the given index");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddColumnsBefore"],
//     enable: false
// }
// function testAddColumnsAfter() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->addColumnsAfter(3, 2);
//             test:assertEquals(setRes, (), msg = "Failed to add columns after the given index");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddColumnsAfter"],
//     enable: false
// }
// function testDeleteColumns() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var res = sheet->deleteColumns(1, 2);
//             test:assertEquals(res, (), msg = "Failed to delete columns");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testAddRowsAfter"],
//     enable: false
// }
// function testDeleteRows() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var res = sheet->deleteRows(5, 2);
//             test:assertEquals(res, (), msg = "Failed to delete rows");
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testDeleteRows"],
//     enable: false
// }
// function testCopyTo() {
//     var copyToSpreadsheet = spreadsheetClient->createSpreadsheet(copyToSpreadsheet);
//     if (copyToSpreadsheet is Spreadsheet) {
//         var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//         if (spreadsheetRes is Spreadsheet) {
//             Sheet[] | error sheets = spreadsheetRes.getSheets();
//             if (sheets is Sheet[]) {
//                 Sheet sheet = sheets[0];
//                 var res = sheet->copyTo(<@untainted>copyToSpreadsheet);
//                 test:assertEquals(res, (), msg = "Failed to copy the sheet");
//             } else {
//                 test:assertFail(sheets.message());
//             }
//         } else {
//             test:assertFail(spreadsheetRes.message());
//         }
//     } else {
//         test:assertFail(copyToSpreadsheet.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testCopyTo"],
//     enable: false
// }
// function testClearCell() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->setCell("G1", "TestValue");
//             if (setRes is ()) {
//                 var getRes = sheet->getCell("G1");
//                 test:assertEquals(getRes, "TestValue", msg = "The set value didn't match the value of the cell");
//             } else {
//                 test:assertFail(setRes.message());
//             }
//             var clearRes = sheet->clearCell("G1");
//             if (clearRes is ()) {
//                 var getClearRes = sheet->getCell("G1");
//                 test:assertEquals(getClearRes.toString(), "", msg = "Failed to clear the cell");
//             } else {
//                 test:assertFail(clearRes.message());
//             }
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testDeleteRows"],
//     enable: false
// }
// function testClearRange() {
//     Range setRange = {a1Notation: "A15:D19", values: entries};
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var setRes = sheet->setRange(setRange);
//             if (setRes is ()) {
//                 var getRes = sheet->getRange("A15:D19");
//                 if (getRes is Range) {
//                     Range expectedValue={"a1Notation":"A15:D19","values":[["Name","Score","Performance","Average"],["Keetz","12"],["Niro","78"],["Nisha","98"],["Kana","86"]]};
//                     test:assertEquals(getRes.values.toString(), expectedValue.values.toString(), msg = "Failed to get the values of the range");
//                 } else {
//                     test:assertFail(getRes.message());
//                 }
//                 var clearRange = sheet->clearRange("A15:D19");
//                 if (clearRange is ()) {
//                     var getClear = sheet->getRange("A15:D19");
//                     if (getClear is Range) {
//                         Range expectedValue={"a1Notation":"A15:D19","values":[]};
//                         test:assertEquals(getClear.values.toString(), expectedValue.values.toString() , msg = "Failed to clear the range");
//                     } else {
//                         test:assertFail(getClear.message());
//                     }
//                 } else {
//                     test:assertFail(clearRange.message());
//                 }
//             } else {
//                 test:assertFail(setRes.message());
//             }
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     dependsOn: ["testClearRange"],
//     enable: false
// }
// function testClearAll() {
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var clearAll = sheet->clearAll();
//             if (clearAll is ()) {
//                 var getRes = sheet->getRange("A1:H20");
//                 if (getRes is Range) {
//                     Range expectedValue={"a1Notation":"A15:D19","values":[]};
//                     test:assertEquals(getRes.values.toString(), expectedValue.values.toString() , msg = "Failed to clear the sheet");
//                 } else {
//                     test:assertFail(getRes.message());
//                 }
//             } else {
//                 test:assertFail(clearAll.message());
//             }
//         } else {
//             test:assertFail(sheets.message());
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config {
//     enable: false
// }
// function testAppendRow() {
//     string[] values = ["Appending", "Some", "Values"];
//     var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
//     if (spreadsheetRes is Spreadsheet) {
//         Sheet[] | error sheets = spreadsheetRes.getSheets();
//         if (sheets is Sheet[]) {
//             Sheet sheet = sheets[0];
//             var appendRes = sheet->appendRow(values);
//             test:assertEquals(appendRes, (), msg = "Appending a row failed");
//         }
//     } else {
//         test:assertFail(spreadsheetRes.message());
//     }
// }

// @test:Config { 
//     dependsOn: ["testCreateSpreadsheet"],
//     enable: false
// }
// function testGetAllSpreadSheet() {
//     var response = spreadsheetClient->getAllSpreadsheets();
//     if (response is stream<File>) {
//         var file = response.next();
//         test:assertNotEquals(file?.value, "", msg = "Found 0 records");
        
//     } else {
//         test:assertFail(response.message());
//     }
// }

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

import ballerina/test;
import ballerina/system;

SpreadsheetConfiguration config = {
    oAuthClientConfig: {
        accessToken: system:getEnv("ACCESS_TOKEN"),
        refreshConfig: {
            clientId: system:getEnv("CLIENT_ID"),
            clientSecret: system:getEnv("CLIENT_SECRET"),
            refreshUrl: REFRESH_URL,
            refreshToken: system:getEnv("REFRESH_TOKEN")
        }
    }
};

Client spreadsheetClient = new (config);

string spreadsheetId = "";
string testSpreadsheetName = "Ballerina Connector";
string createSpreadsheetName = "Ballerina Connector New";
string testSheetName = "Dance";
string testDeleteSheetName = "Remove Dance";
int testSheetId = 0;
string[][] entries = [["Name", "Score", "Performance", "Average"], ["Keetz", "12"], ["Niro", "78"],
["Nisha", "98"], ["Kana", "86"]];

// Tests the Client actions
@test:Config {}
function testCreateSpreadsheet() {
    var spreadsheetRes = spreadsheetClient->createSpreadsheet(createSpreadsheetName);
    if (spreadsheetRes is Spreadsheet) {
        Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
        test:assertNotEquals(spreadsheetRes.spreadsheetId, "", msg = "Failed to create spreadsheet");
        spreadsheetId = testSpreadsheet.spreadsheetId;
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"]
}
function testOpenSpreadsheetById() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
        Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

//Tests the Spreadsheet client actions
@test:Config {
    dependsOn: ["testCreateSpreadsheet"]
}
function testGetProperties() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        SpreadsheetProperties props = spreadsheetRes.getProperties();
        test:assertEquals(props.title, createSpreadsheetName, msg = "Failed to open the spreadsheet");
        Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"]
}
function testAddSheet() {
    var response = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (response is Spreadsheet) {
        Sheet | error addSheetRes = response->addSheet(testSheetName);
        if (addSheetRes is Sheet) {
            testSheetId = <@untainted>addSheetRes.properties.sheetId;
            test:assertNotEquals(addSheetRes.properties.sheetId, "", msg = "Failed to add sheet");
        } else {
            test:assertFail(msg = <string>addSheetRes.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>response.detail()["message"]);

    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddSheet"]
}
function testGetSheets() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            test:assertNotEquals(sheets.length(), 0, msg = "Failed to get sheets");
            test:assertEquals(sheets[0].parentId, spreadsheetId);
        } else {
            test:assertFail(msg = <string>sheets.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddSheet"]
}
function testGetSheetByName() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet | error sheet = spreadsheetRes.getSheetByName(testSheetName);
        if (sheet is Sheet) {
            test:assertEquals(sheet.properties.title, testSheetName, msg = "Failed to get sheets");
        } else {
            test:assertFail(msg = <string>sheet.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"]
}
function testRemoveSheet() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet | error addSheetRes = spreadsheetRes->addSheet(testDeleteSheetName);
        if (addSheetRes is Sheet) {
            testSheetId = <@untainted>addSheetRes.properties.sheetId;
            test:assertNotEquals(addSheetRes.properties.sheetId, "", msg = "Failed to add sheet");
            error? removeRes = spreadsheetRes->removeSheet(<@untainted>addSheetRes.id);
            test:assertEquals(removeRes, (), msg = "Fsilrf");
        } else {
            test:assertFail(msg = <string>addSheetRes.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"]
}
function testRename() {
    string newName = createSpreadsheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        test:assertEquals(spreadsheetRes.getProperties().title, createSpreadsheetName, msg = "Failed");
        error? res = spreadsheetRes->rename(newName);
        if (res is ()) {
            createSpreadsheetName = newName;
            test:assertEquals(spreadsheetRes.getProperties().title, newName, msg = "Failed");
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

//// Tests the Sheet client actions
@test:Config {
    dependsOn: ["testAddSheet"]
}
function testSheetRename() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    string newName = "Renamed";
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var res = sheet->rename(newName);
            if (res is ()) {
                test:assertEquals(sheet.getProperties().title, newName, msg = "Failed");
            } else {
                test:assertFail(msg = <string>res.detail()["message"]);
            }
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"]
}
function testSetCell() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->setCell("A10", "ModifiedValue");
            test:assertEquals(setRes, (), msg = "Failed");
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetCell"]
}
function testGetCell() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->getCell("A10");
            test:assertEquals(setRes, "ModifiedValue", msg = "Failed");
        } else {
            test:assertFail(msg = <string>sheets.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"]
}
function testGetRow() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var res = sheet->getRow(2);
            test:assertEquals(res.toString(), "Keetz 12", msg = "Failed");
        } else {
            test:assertFail(msg = <string>sheets.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"]
}
function testGetColumn() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var res = sheet->getColumn("B");
            test:assertEquals(res.toString(), "Score 12 78 98 86", msg = "Failed");
        } else {
            test:assertFail(msg = <string>sheets.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddSheet"]
}
function testSetRange() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            Range range = {a1Notation: "A1:D5", values: entries};
            var setRes = sheet->setRange(<@untainted>range);
            test:assertEquals(setRes, (), msg = "Failed");
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddSheet", "testSetRange"]
}
function testGetRange() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->getRange("A1:D5");
            if (setRes is Range) {
                test:assertEquals(setRes.values, entries, msg = "Fail");
            }
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testSetRange", "testGetRange", "testGetColumn", "testGetCell", "testGetRow"]
}
function testAddRowsBefore() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addRowsBefore(1, 2);
            test:assertEquals(setRes, (), msg = "Failed");
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddRowsBefore"]
}
function testAddRowsAfter() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addRowsAfter(4, 2);
            test:assertEquals(setRes, (), msg = "Failed");
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddRowsBefore"]
}
function testAddColumnsBefore() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addColumnsBefore(1, 2);
            test:assertEquals(setRes, (), msg = "Failed");
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddColumnsBefore"]
}
function testAddColumnsAfter() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addColumnsAfter(3, 2);
            test:assertEquals(setRes, (), msg = "Failed");
        }
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail()["message"]);
    }
}

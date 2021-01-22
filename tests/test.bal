//Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
//WSO2 Inc. licenses this file to you under the Apache License,
//Version 2.0 (the "License"); you may not use this file except
//in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing,
//software distributed under the License is distributed on an
//"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//KIND, either express or implied.  See the License for the
//specific language governing permissions and limitations
//under the License.

import ballerina/os;
import ballerina/test;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");

SpreadsheetConfiguration config = {
    oauth2Config: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: REFRESH_URL,
        refreshToken: refreshToken
    }
};

Client spreadsheetClient = checkpanic new (config);

string copyToSpreadsheet = "Copy To";
string spreadsheetId = "";
string testSpreadsheetName = "Ballerina Connector";
string createSpreadsheetName = "Ballerina Connector New";
string testSheetName = "Dance";
string testDeleteSheetName = "Remove Dance";
int testSheetId = 0;
string[][] entries = [
    ["Name", "Score", "Performance", "Average"],
    ["Keetz", "12"],
    ["Niro", "78"],
    ["Nisha", "98"],
    ["Kana", "86"]
];

// Tests the Client actions
@test:Config {}
function testCreateSpreadsheet() {
    var spreadsheetRes = spreadsheetClient->createSpreadsheet(createSpreadsheetName);
    if (spreadsheetRes is Spreadsheet) {
        Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
        test:assertNotEquals(spreadsheetRes.spreadsheetId, "", msg = "Failed to create spreadsheet");
        spreadsheetId = testSpreadsheet.spreadsheetId;
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testCreateSpreadsheet]
}
function testOpenSpreadsheetById() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
        Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {}
function testOpenSpreadsheetByUrl() {
    string url = "https://docs.google.com/spreadsheets/d/" + spreadsheetId + "/edit#gid=0";
    var spreadsheetRes = spreadsheetClient->openSpreadsheetByUrl(url);
    if (spreadsheetRes is Spreadsheet) {
        test:assertEquals(spreadsheetRes.spreadsheetId, spreadsheetId, msg = "Failed to open the spreadsheet");
        Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

//Tests the Spreadsheet client actions
@test:Config {
    dependsOn: [testCreateSpreadsheet]
}
function testGetProperties() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        SpreadsheetProperties props = spreadsheetRes.getProperties();
        test:assertEquals(props.title, createSpreadsheetName, msg = "Failed to get properties of the spreadsheet");
        Spreadsheet testSpreadsheet = <@untainted>spreadsheetRes;
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testCreateSpreadsheet]
}
function testAddSheet() {
    var response = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (response is Spreadsheet) {
        Sheet | error addSheetRes = response->addSheet(testSheetName);
        if (addSheetRes is Sheet) {
            testSheetId = <@untainted>addSheetRes.properties.sheetId;
            test:assertNotEquals(addSheetRes.properties.sheetId, "", msg = "Failed to add a new sheet");
        } else {
            test:assertFail(addSheetRes.message());
        }
    } else {
        test:assertFail(response.message());

    }
}

@test:Config {
    dependsOn: [testCreateSpreadsheet, testAddSheet]
}
function testGetSheets() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            test:assertNotEquals(sheets.length(), 0, msg = "Failed to retrieve the sheets");
            test:assertEquals(sheets[0].parentId, spreadsheetId);
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testCreateSpreadsheet, testAddSheet]
}
function testGetSheetByName() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet | error sheet = spreadsheetRes.getSheetByName(testSheetName);
        if (sheet is Sheet) {
            test:assertEquals(sheet.properties.title, testSheetName, msg = "Failed to get the sheet by name");
        } else {
            test:assertFail(sheet.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testCreateSpreadsheet]
}
function testRemoveSheet() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet | error addSheetRes = spreadsheetRes->addSheet(testDeleteSheetName);
        if (addSheetRes is Sheet) {
            testSheetId = <@untainted>addSheetRes.properties.sheetId;
            test:assertNotEquals(addSheetRes.properties.sheetId, "", msg = "Failed to remove the sheet");
            error? removeRes = spreadsheetRes->removeSheet(<@untainted>addSheetRes.id);
            test:assertEquals(removeRes, (), msg = "Failed to remove the sheet");
        } else {
            test:assertFail(addSheetRes.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testCreateSpreadsheet]
}
function testRename() {
    string newName = createSpreadsheetName + " Renamed";
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        test:assertEquals(spreadsheetRes.getProperties().title, createSpreadsheetName, msg = "Failed to " +
        "rename the spreadsheet");
        error? res = spreadsheetRes->rename(newName);
        if (res is ()) {
            createSpreadsheetName = newName;
            test:assertEquals(spreadsheetRes.getProperties().title, newName, msg = "Failed");
        } else {
            test:assertFail(res.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

// Tests the Sheet client actions
@test:Config {
    dependsOn: [testAddSheet]
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
                test:assertEquals(sheet.getProperties().title, newName, msg = "Failed to rename the sheet");
            } else {
                test:assertFail(res.message());
            }
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddSheet, testSetRange]
}
function testSetCell() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->setCell("A10", "ModifiedValue");
            test:assertEquals(setRes, (), msg = "Failed to set the cell value");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddSheet, testSetCell]
}
function testGetCell() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->getCell("A10");
            test:assertEquals(setRes, "ModifiedValue", msg = "Failed to get the cell value");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddSheet, testSetRange]
}
function testGetRow() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            (string | int | float)[] | error valueReturned = sheet->getRow(2);
            //var valueReturned contains (string | int | float)[]
            (int|string|float)[] expectedValue = ["Keetz", "12"];
            if (valueReturned is error) {
                test:assertFail("retrieving second row failed");
            } else {
                test:assertEquals(valueReturned.toString(), expectedValue.toString() , 
                msg = "Failed to get the row values");
            }
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddSheet, testSetRange]
}
function testGetColumn() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            (string|int|float)[] | error valueReturned = sheet->getColumn("B");
            //var valueReturned contains (string | int | float)
            (int|string|float)[] expectedValue = ["Score", "12", "78", "98", "86"];
            
            if (valueReturned is error) {
                test:assertFail("retrieving column B failed");
            } else {
                test:assertEquals(valueReturned.toString(), expectedValue.toString(), 
                msg = "Failed to get the column values");
            }
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddSheet]
}
function testSetRange() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            Range range = {a1Notation: "A1:D5", values: entries};
            var setRes = sheet->setRange(<@untainted>range);
            test:assertEquals(setRes, (), msg = "Failed to set the values of the range");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddSheet, testSetRange]
}
function testGetRange() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->getRange("A1:D5");
            if (setRes is Range) {
                test:assertEquals(setRes.values, entries, msg = "Failed to get the values of the range");
            } else {
                test:assertFail(setRes.message());
            }
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testSetRange, testGetRange, testGetColumn, testGetCell, testGetRow]
}
function testAddRowsBefore() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addRowsBefore(1, 2);
            test:assertEquals(setRes, (), msg = "Failed to add rows before the given index");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddRowsBefore]
}
function testAddRowsAfter() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addRowsAfter(4, 2);
            test:assertEquals(setRes, (), msg = "Failed to add rows after the given index");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddRowsBefore]
}
function testAddColumnsBefore() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addColumnsBefore(1, 2);
            test:assertEquals(setRes, (), msg = "Failed to add columns before the given index");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddColumnsBefore]
}
function testAddColumnsAfter() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->addColumnsAfter(3, 2);
            test:assertEquals(setRes, (), msg = "Failed to add columns after the given index");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddColumnsAfter]
}
function testDeleteColumns() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var res = sheet->deleteColumns(1, 2);
            test:assertEquals(res, (), msg = "Failed to delete columns");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testAddRowsAfter]
}
function testDeleteRows() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var res = sheet->deleteRows(5, 2);
            test:assertEquals(res, (), msg = "Failed to delete rows");
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testDeleteRows]
}
function testCopyTo() {
    var copyToSpreadsheet = spreadsheetClient->createSpreadsheet(copyToSpreadsheet);
    if (copyToSpreadsheet is Spreadsheet) {
        var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
        if (spreadsheetRes is Spreadsheet) {
            Sheet[] | error sheets = spreadsheetRes.getSheets();
            if (sheets is Sheet[]) {
                Sheet sheet = sheets[0];
                var res = sheet->copyTo(<@untainted>copyToSpreadsheet);
                test:assertEquals(res, (), msg = "Failed to copy the sheet");
            } else {
                test:assertFail(sheets.message());
            }
        } else {
            test:assertFail(spreadsheetRes.message());
        }
    } else {
        test:assertFail(copyToSpreadsheet.message());
    }
}

@test:Config {
    dependsOn: [testCopyTo]
}
function testClearCell() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->setCell("G1", "TestValue");
            if (setRes is ()) {
                var getRes = sheet->getCell("G1");
                test:assertEquals(getRes, "TestValue", msg = "The set value didn't match the value of the cell");
            } else {
                test:assertFail(setRes.message());
            }
            var clearRes = sheet->clearCell("G1");
            if (clearRes is ()) {
                int | string | float | error getClearRes = sheet->getCell("G1");
                if (getClearRes is error) {
                    test:assertFail("retrieving cell G1 failed");
                } else {
                    test:assertEquals(getClearRes.toString(), "", msg = "Failed to clear the cell");
                }
            } else {
                test:assertFail(clearRes.message());
            }
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testDeleteRows]
}
function testClearRange() {
    Range setRange = {a1Notation: "A15:D19", values: entries};
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var setRes = sheet->setRange(setRange);
            if (setRes is ()) {
                var getRes = sheet->getRange("A15:D19");
                if (getRes is Range) {
                    Range expectedValue={"a1Notation":"A15:D19","values":[["Name","Score","Performance","Average"],["Keetz","12"],["Niro","78"],["Nisha","98"],["Kana","86"]]};
                    test:assertEquals(getRes.values.toString(), expectedValue.values.toString(), msg = "Failed to get the values of the range");
                } else {
                    test:assertFail(getRes.message());
                }
                var clearRange = sheet->clearRange("A15:D19");
                if (clearRange is ()) {
                    var getClear = sheet->getRange("A15:D19");
                    if (getClear is Range) {
                        Range expectedValue={"a1Notation":"A15:D19","values":[]};
                        test:assertEquals(getClear.values.toString(), expectedValue.values.toString() , msg = "Failed to clear the range");
                    } else {
                        test:assertFail(getClear.message());
                    }
                } else {
                    test:assertFail(clearRange.message());
                }
            } else {
                test:assertFail(setRes.message());
            }
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {
    dependsOn: [testClearRange]
}
function testClearAll() {
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var clearAll = sheet->clearAll();
            if (clearAll is ()) {
                var getRes = sheet->getRange("A1:H20");
                if (getRes is Range) {
                    Range expectedValue={"a1Notation":"A15:D19","values":[]};
                    test:assertEquals(getRes.values.toString(), expectedValue.values.toString() , msg = "Failed to clear the sheet");
                } else {
                    test:assertFail(getRes.message());
                }
            } else {
                test:assertFail(clearAll.message());
            }
        } else {
            test:assertFail(sheets.message());
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config {}
function testAppendRow() {
    string[] values = ["Appending", "Some", "Values"];
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        Sheet[] | error sheets = spreadsheetRes.getSheets();
        if (sheets is Sheet[]) {
            Sheet sheet = sheets[0];
            var appendRes = sheet->appendRow(values);
            test:assertEquals(appendRes, (), msg = "Appending a row failed");
        }
    } else {
        test:assertFail(spreadsheetRes.message());
    }
}

@test:Config { 
    dependsOn: [testCreateSpreadsheet]
}
function testGetAllSpreadSheet() {
    var response = spreadsheetClient->getAllSpreadsheets();
    if (response is stream<File>) {
        var file = response.next();
        test:assertNotEquals(file?.value, "", msg = "Found 0 records");
        
    } else {
        test:assertFail(response.message());
    }
}

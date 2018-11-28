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

import ballerina/config;
import ballerina/io;
import ballerina/test;

string accessToken = config:getAsString("ACCESS_TOKEN");
string clientId = config:getAsString("CLIENT_ID");
string clientSecret = config:getAsString("CLIENT_SECRET");
string refreshToken = config:getAsString("REFRESH_TOKEN");

endpoint Client spreadsheetClient {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: accessToken,
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        }
    }
};

Spreadsheet testSpreadsheet = new;
Sheet testSheet = {};
string testSpreadsheetName = "testBalFile";
string testSheetName = "testSheet";
int testSheetId;

@test:Config
function testCreateSpreadsheet() {
    io:println("-----------------Test case for createSpreadsheet method------------------");
    var spreadsheetRes = spreadsheetClient->createSpreadsheet(testSpreadsheetName);
    match spreadsheetRes {
        Spreadsheet s => testSpreadsheet = s;
        error e => test:assertFail(msg = e.message);
    }
    test:assertNotEquals(testSpreadsheet.spreadsheetId, null, msg = "Failed to create spreadsheet");
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"]
}
function testAddNewSheet() {
    io:println("-----------------Test case for addNewSheet method------------------");
    var spreadsheetRes = spreadsheetClient->addNewSheet(testSpreadsheet.spreadsheetId, testSheetName);
    match spreadsheetRes {
        Sheet s => testSheet = s;
        error e => io:println(e.message);
    }
    testSheetId = testSheet.properties.sheetId;
    test:assertNotEquals(testSheet.properties.sheetId, null, msg = "Failed to add sheet");
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddNewSheet"]
}
function testOpenSpreadsheetById() {
    io:println("-----------------Test case for openSpreadsheetById method------------------");
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(testSpreadsheet.spreadsheetId);
    match spreadsheetRes {
        Spreadsheet s => testSpreadsheet = s;
        error e => test:assertFail(msg = e.message);
    }
    test:assertNotEquals(testSpreadsheet.spreadsheetId, null, msg = "Failed to open the spreadsheet");

}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById"]
}
function testGetSpreadsheetName() {
    io:println("-----------------Test case for getSpreadsheetName method------------------");
    string name = "";
    var res = testSpreadsheet.getSpreadsheetName();
    match res {
        string s => name = s;
        error e => test:assertFail(msg = e.message);
    }
    test:assertEquals(name, testSpreadsheetName, msg = "getSpreadsheetName() method failed");
}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById"]
}
function testGetSpreadsheetId() {
    io:println("-----------------Test case for getSpreadsheetId method------------------");
    string spreadsheetId = "";
    var res = testSpreadsheet.getSpreadsheetId();
    match res {
        string s => spreadsheetId = s;
        error e => test:assertFail(msg = e.message);
    }
    test:assertEquals(spreadsheetId, testSpreadsheet.spreadsheetId,
        msg = "getSpreadsheetId() method failed");
}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById"]
}
function testGetSheets() {
    io:println("-----------------Test case for getSheets method------------------");
    Sheet[] sheets = [];
    var sheetRes = testSpreadsheet.getSheets();
    match sheetRes {
        Sheet[] s => sheets = s;
        error e => test:assertFail(msg = e.message);
    }
    test:assertEquals(lengthof sheets, 2, msg = "getSheets() method failed");
}

@test:Config {
    dependsOn: ["testGetSheets", "testAddNewSheet"]
}
function testGetSheetByName() {
    io:println("-----------------Test case for getSheetByName method------------------");
    Sheet sheet = {};
    var sheetRes = testSpreadsheet.getSheetByName(testSheetName);
    match sheetRes {
        Sheet s => sheet = s;
        error e => test:assertFail(msg = e.message);
    }
    test:assertEquals(sheet.properties.title, testSheetName, msg = "getSheetByName() method failed");
}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById", "testGetSheets"]
}
function testSetSheetValues() {
    io:println("-----------------Test case for setSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
    ["Nisha", "98"], ["Kana", "86"]];
    var spreadsheetRes = spreadsheetClient->setSheetValues(testSpreadsheet.spreadsheetId, testSheetName, "A1", "C5",
        values);
    match spreadsheetRes {
        boolean isUpdated => test:assertTrue(isUpdated, msg = "Failed to update the values!");
        error e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testSetSheetValues", "testGetSheets"]
}
function testGetSheetValues() {
    io:println("-----------------Test case for getSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
    ["Nisha", "98"], ["Kana", "86"]];
    var spreadsheetRes = spreadsheetClient->getSheetValues(testSpreadsheet.spreadsheetId, testSheetName, "A1", "C5");
    match spreadsheetRes {
        string[][] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        error e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testGetSheetValues", "testGetSheets"]
}
function testGetColumnData() {
    io:println("-----------------Test case for getColumnData method------------------");
    string[] values = ["Name", "Keetz", "Niro", "Nisha", "Kana"];
    var spreadsheetRes = spreadsheetClient->getColumnData(testSpreadsheet.spreadsheetId, testSheetName, "A");
    match spreadsheetRes {
        string[] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        error e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testGetSheetValues", "testGetSheets"]
}
function testGetRowData() {
    io:println("-----------------Test case for getRowData method------------------");
    string[] values = ["Name", "Score", "Performance"];
    var spreadsheetRes = spreadsheetClient->getRowData(testSpreadsheet.spreadsheetId, testSheetName, 1);
    match spreadsheetRes {
        string[] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        error e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testGetSheetValues", "testGetSheets"]
}
function testSetCellData() {
    io:println("-----------------Test case for setCellData method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient->setCellData(testSpreadsheet.spreadsheetId, testSheetName, "B", 5, "90");
    match spreadsheetRes {
        boolean isUpdated => test:assertTrue(isUpdated, msg = "Failed to update the value!");
        error e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testSetCellData", "testGetSheets"]
}
function testGetCellData() {
    io:println("-----------------Test case for getCellData method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient->getCellData(testSpreadsheet.spreadsheetId, testSheetName, "B", 5);
    match spreadsheetRes {
        string val => test:assertEquals(val, value, msg = "Failed to get the value!");
        error e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testGetCellData", "testGetRowData", "testGetColumnData"]
}
function testDeleteSheet() {
    io:println("-----------------Test case for deleteSheet method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient->deleteSheet(testSpreadsheet.spreadsheetId, testSheetId);
    match spreadsheetRes {
        boolean val => test:assertTrue(val, msg = "Failed to delete the sheet!");
        error e => test:assertFail(msg = e.message);
    }
}

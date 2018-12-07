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
import ballerina/log;
import ballerina/http;

SpreadsheetConfiguration spreadsheetConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("ACCESS_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshToken: config:getAsString("REFRESH_TOKEN")
        }
    }
};
Client spreadsheetClient = new(spreadsheetConfig);

Spreadsheet testSpreadsheet = new;
Sheet testSheet = {};
string testSpreadsheetName = "testBalFile";
string testSheetName = "testSheet";
int testSheetId = 0;

@test:Config
function testCreateSpreadsheet() {
    io:println("-----------------Test case for createSpreadsheet method------------------");
    var spreadsheetRes = spreadsheetClient->createSpreadsheet(testSpreadsheetName);
    if (spreadsheetRes is Spreadsheet) {
        testSpreadsheet = spreadsheetRes;
        test:assertNotEquals(spreadsheetRes.spreadsheetId, null, msg = "Failed to create spreadsheet");
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet"]
}
function testAddNewSheet() {
    io:println("-----------------Test case for addNewSheet method------------------");
    var spreadsheetRes = spreadsheetClient->addNewSheet(testSpreadsheet.spreadsheetId, testSheetName);
    if (spreadsheetRes is Sheet) {
        testSheetId = spreadsheetRes.properties.sheetId;
        test:assertNotEquals(spreadsheetRes.properties.sheetId, null, msg = "Failed to add sheet");
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateSpreadsheet", "testAddNewSheet"]
}
function testOpenSpreadsheetById() {
    io:println("-----------------Test case for openSpreadsheetById method------------------");
    var spreadsheetRes = spreadsheetClient->openSpreadsheetById(testSpreadsheet.spreadsheetId);
    if (spreadsheetRes is Spreadsheet) {
        testSpreadsheet = spreadsheetRes;
        test:assertNotEquals(spreadsheetRes.spreadsheetId, null, msg = "Failed to open the spreadsheet");
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    }
}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById"]
}
function testGetSpreadsheetName() {
    io:println("-----------------Test case for getSpreadsheetName method------------------");
    string name = "";
    var res = testSpreadsheet.getSpreadsheetName();
    if (res is string) {
        test:assertEquals(res, testSpreadsheetName, msg = "getSpreadsheetName() method failed");
    } else {
        test:assertFail(msg = <string>res.detail().message);
    }

}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById"]
}
function testGetSpreadsheetId() {
    io:println("-----------------Test case for getSpreadsheetId method------------------");
    string spreadsheetId = "";
    var res = testSpreadsheet.getSpreadsheetId();
    if (res is string) {
        test:assertEquals(res, testSpreadsheet.spreadsheetId, msg = "getSpreadsheetId() method failed");
    } else {
        test:assertFail(msg = <string>res.detail().message);
    }
}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById"]
}
function testGetSheets() {
    io:println("-----------------Test case for getSheets method------------------");
    Sheet[] sheets = [];
    var sheetRes = testSpreadsheet.getSheets();
    if (sheetRes is error) {
        test:assertFail(msg = <string>sheetRes.detail().message);
    } else {
        test:assertEquals(sheetRes.length(), 2, msg = "getSheets() method failed");
    }
}

@test:Config {
    dependsOn: ["testGetSheets", "testAddNewSheet"]
}
function testGetSheetByName() {
    io:println("-----------------Test case for getSheetByName method------------------");
    Sheet sheet = {};
    var sheetRes = testSpreadsheet.getSheetByName(testSheetName);
    if (sheetRes is Sheet) {
        test:assertEquals(sheetRes.properties.title, testSheetName, msg = "getSheetByName() method failed");
    } else {
        test:assertFail(msg = <string>sheetRes.detail().message);
    }

}

@test:Config {
    dependsOn: ["testOpenSpreadsheetById", "testGetSheets"]
}
function testSetSheetValues() {
    io:println("-----------------Test case for setSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
    ["Nisha", "98"], ["Kana", "86"]];
    var spreadsheetRes = spreadsheetClient->setSheetValues(testSpreadsheet.spreadsheetId, testSheetName,
                                            topLeftCell ="A1", bottomRightCell = "C5", values);
    if (spreadsheetRes is boolean) {
        test:assertTrue(spreadsheetRes, msg = "Failed to update the values!");
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    }
}

@test:Config {
    dependsOn: ["testSetSheetValues", "testGetSheets"]
}
function testGetSheetValues() {
    io:println("-----------------Test case for getSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
    ["Nisha", "98"], ["Kana", "86"]];
    var spreadsheetRes = spreadsheetClient->getSheetValues(testSpreadsheet.spreadsheetId, testSheetName,
                                            topLeftCell ="A1", bottomRightCell = "C5");
    if (spreadsheetRes is error) {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    } else {
        test:assertEquals(spreadsheetRes, values, msg = "Failed to get the values!");
    }
}

@test:Config {
    dependsOn: ["testGetSheetValues", "testGetSheets"]
}
function testGetColumnData() {
    io:println("-----------------Test case for getColumnData method------------------");
    string[] values = ["Name", "Keetz", "Niro", "Nisha", "Kana"];
    var spreadsheetRes = spreadsheetClient->getColumnData(testSpreadsheet.spreadsheetId, testSheetName, "A");
    if (spreadsheetRes is error) {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    } else {
        test:assertEquals(spreadsheetRes, values, msg = "Failed to get the values!");
    }
}

@test:Config {
    dependsOn: ["testGetSheetValues", "testGetSheets"]
}
function testGetRowData() {
    io:println("-----------------Test case for getRowData method------------------");
    string[] values = ["Name", "Score", "Performance"];
    var spreadsheetRes = spreadsheetClient->getRowData(testSpreadsheet.spreadsheetId, testSheetName, 1);
    if (spreadsheetRes is error) {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    } else {
        test:assertEquals(spreadsheetRes, values, msg = "Failed to get the values!");
    }
}

@test:Config {
    dependsOn: ["testGetSheetValues", "testGetSheets"]
}
function testSetCellData() {
    io:println("-----------------Test case for setCellData method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient->setCellData(testSpreadsheet.spreadsheetId, testSheetName, "B", 5, "90");
    if (spreadsheetRes is boolean) {
        test:assertTrue(spreadsheetRes, msg = "Failed to update the values!");
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    }
}

@test:Config {
    dependsOn: ["testSetCellData", "testGetSheets"]
}
function testGetCellData() {
    io:println("-----------------Test case for getCellData method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient->getCellData(testSpreadsheet.spreadsheetId, testSheetName, "B", 5);
    if (spreadsheetRes is string) {
       test:assertEquals(spreadsheetRes, value, msg = "Failed to get the value!");
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    }
}

@test:Config {
    dependsOn: ["testGetCellData", "testGetRowData", "testGetColumnData"]
}
function testDeleteSheet() {
    io:println("-----------------Test case for deleteSheet method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient->deleteSheet(testSpreadsheet.spreadsheetId, testSheetId);
    if (spreadsheetRes is boolean) {
       test:assertTrue(spreadsheetRes, msg = "Failed to delete the sheet!");
    } else {
        test:assertFail(msg = <string>spreadsheetRes.detail().message);
    }
}

import ballerina/io;
import ballerina/log;
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
import ballerinax/googleapis.gsheets;

gsheets:ConnectionConfig spreadsheetConfig = {
    auth: {
        refreshUrl: gsheets:REFRESH_URL,
        refreshToken: os:getEnv("REFRESH_TOKEN"),
        clientId: os:getEnv("CLIENT_ID"),
        clientSecret: os:getEnv("CLIENT_SECRET")
    }
};

// Connector configuration
gsheets:Client spreadsheetClient = check new (spreadsheetConfig);
string connecterVersion = "0.99.8";

// Constants
string COMMA = ",";
string SQUARE_BRACKET_LEFT = "[";
string SQUARE_BRACKET_RIGHT = "]";

// Sample values
string createSpreadsheetName = "Ballerina Connector New";
string spreadsheetId = "14sjpSLfNTmIdPzUhx4pY9d9SHqI4yG9MS3Jc6HAAOjk";
string testSheetName1 = "Test1";
string testSheetName2 = "Test2";
string testSheetName3 = "Test3";

// Configuration related to data generation
final string rootPath = "./data/";
final string fileExtension = "_data.json";

// Output files
string spreadSheetData = rootPath + "Spreadsheet" + fileExtension;
string sheetData = rootPath + "Sheet" + fileExtension;
string rangeData = rootPath + "Range" + fileExtension;
string fileData = rootPath + "File" + fileExtension;

public function main() returns error? {
    _ = check generateSpreadsheetData();
    _ = check generateSheetData();
    _ = check generateRangeData();
    _ = check generateFileData();
}

function generateSpreadsheetData() returns error? {
    log:printInfo("SampleDataGenerator -> SpreadsheetData");
    gsheets:Spreadsheet spreadsheetRes1 = check spreadsheetClient->openSpreadsheetById(spreadsheetId);
    gsheets:Spreadsheet spreadsheetRes2 = check spreadsheetClient->createSpreadsheet(createSpreadsheetName);
    gsheets:Spreadsheet spreadsheetRes3 = check spreadsheetClient->createSpreadsheet(createSpreadsheetName);

    string arrayOfSpreadsheets = SQUARE_BRACKET_LEFT + spreadsheetRes1.toJsonString() + COMMA
                                + spreadsheetRes2.toJsonString() + COMMA + spreadsheetRes3.toJsonString()
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{" + "\"ballerinax/googleapis.gsheets:" + connecterVersion + ":Spreadsheet\"" + ":" + arrayOfSpreadsheets + "}";
    check io:fileWriteJson(spreadSheetData, check preparedJson.cloneWithType(json));
}

function generateSheetData() returns error? {
    log:printInfo("SampleDataGenerator -> SheetData");
    gsheets:Sheet sheetRes1 = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName1);
    gsheets:Sheet sheetRes2 = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName2);
    gsheets:Sheet sheetRes3 = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName3);

    string arrayOfSheets = SQUARE_BRACKET_LEFT + sheetRes1.toJsonString() + COMMA
                                + sheetRes2.toJsonString() + COMMA + sheetRes3.toJsonString()
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{" + "\"ballerinax/googleapis.gsheets:" + connecterVersion + ":Sheet\"" + ":" + arrayOfSheets + "}";
    check io:fileWriteJson(sheetData, check preparedJson.cloneWithType(json));
}

function generateRangeData() returns error? {
    log:printInfo("SampleDataGenerator -> RangeData");
    gsheets:Range rangeRes1 = check spreadsheetClient->getRange(spreadsheetId, testSheetName1, "A1:D30");
    gsheets:Range rangeRes2 = check spreadsheetClient->getRange(spreadsheetId, testSheetName1, "A30:D50");
    gsheets:Range rangeRes3 = check spreadsheetClient->getRange(spreadsheetId, testSheetName1, "A50:D90");

    string arrayOfRanges = SQUARE_BRACKET_LEFT + rangeRes1.toJsonString() + COMMA
                                + rangeRes2.toJsonString() + COMMA + rangeRes3.toJsonString()
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{" + "\"ballerinax/googleapis.gsheets:" + connecterVersion + ":Range\"" + ":" + arrayOfRanges + "}";
    check io:fileWriteJson(rangeData, check preparedJson.cloneWithType(json));
}

function generateFileData() returns error? {
    log:printInfo("SampleDataGenerator -> FileData");
    stream<gsheets:File|error> response = check spreadsheetClient->getAllSpreadsheets();
    var file1 = response.next();
    var file2 = response.next();
    var file3 = response.next();
    gsheets:File? spreadsheet1 = file1?.value;
    gsheets:File? spreadsheet2 = file2?.value;
    gsheets:File? spreadsheet3 = file3?.value;
    string arrayOfFiles = SQUARE_BRACKET_LEFT + spreadsheet1.toJsonString() + COMMA
                                + spreadsheet2.toJsonString() + COMMA + spreadsheet3.toJsonString()
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{" + "\"ballerinax/googleapis.gsheets:" + connecterVersion + ":File\"" + ":" + arrayOfFiles + "}";
    check io:fileWriteJson(fileData, check preparedJson.cloneWithType(json));
}

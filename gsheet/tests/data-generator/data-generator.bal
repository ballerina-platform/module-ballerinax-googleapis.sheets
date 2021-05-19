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
import ballerina/io;
import ballerina/log;
import ballerinax/googleapis.sheets as sheets;

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: os:getEnv("REFRESH_TOKEN"),
        clientId: os:getEnv("CLIENT_ID"),
        clientSecret: os:getEnv("CLIENT_SECRET")
    }
};

// Connector configuration
sheets:Client spreadsheetClient = checkpanic new (spreadsheetConfig);
var randomString = sheets:createRandomUUIDWithoutHyphens();
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
string spreadSheetData = rootPath + "Spreadsheet"+fileExtension;
string sheetData = rootPath + "Sheet"+fileExtension;
string rangeData = rootPath + "Range"+fileExtension;
string fileData = rootPath + "File"+fileExtension;

public function main() returns error? {
    _ = check generateSpreadsheetData();
    _ = check generateSheetData();
    _ = check generateRangeData();
    _ = check generateFileData();
}

function generateSpreadsheetData() returns error? {
    log:printInfo("SampleDataGenerator -> SpreadsheetData");
    sheets:Spreadsheet spreadsheetRes1 = check spreadsheetClient->openSpreadsheetById(spreadsheetId);
    sheets:Spreadsheet spreadsheetRes2 = check spreadsheetClient->createSpreadsheet(createSpreadsheetName);
    sheets:Spreadsheet spreadsheetRes3 = check spreadsheetClient->createSpreadsheet(createSpreadsheetName);

    string arrayOfSpreadsheets = SQUARE_BRACKET_LEFT + spreadsheetRes1.toJsonString() + COMMA 
                                + spreadsheetRes2.toJsonString() + COMMA + spreadsheetRes3.toJsonString() 
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{"+"\"ballerinax/googleapis.sheets:"+connecterVersion+":Spreadsheet\""+":"+arrayOfSpreadsheets+"}";
    check io:fileWriteJson(spreadSheetData, check preparedJson.cloneWithType(json));                      
}

function generateSheetData() returns error? {
    log:printInfo("SampleDataGenerator -> SheetData");
    sheets:Sheet sheetRes1 = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName1);
    sheets:Sheet sheetRes2 = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName2);
    sheets:Sheet sheetRes3 = check spreadsheetClient->getSheetByName(spreadsheetId, testSheetName3);

    string arrayOfSheets = SQUARE_BRACKET_LEFT + sheetRes1.toJsonString() + COMMA 
                                + sheetRes2.toJsonString() + COMMA + sheetRes3.toJsonString() 
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{"+"\"ballerinax/googleapis.sheets:"+connecterVersion+":Sheet\""+":"+arrayOfSheets+"}";
    check io:fileWriteJson(sheetData, check preparedJson.cloneWithType(json));   
}

function generateRangeData() returns error? {
    log:printInfo("SampleDataGenerator -> RangeData");
    sheets:Range rangeRes1 = check spreadsheetClient->getRange(spreadsheetId, testSheetName1, "A1:D30");
    sheets:Range rangeRes2 = check spreadsheetClient->getRange(spreadsheetId, testSheetName1, "A30:D50");
    sheets:Range rangeRes3 = check spreadsheetClient->getRange(spreadsheetId, testSheetName1, "A50:D90");

    string arrayOfRanges = SQUARE_BRACKET_LEFT + rangeRes1.toJsonString() + COMMA 
                                + rangeRes2.toJsonString() + COMMA + rangeRes3.toJsonString() 
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{"+"\"ballerinax/googleapis.sheets:"+connecterVersion+":Range\""+":"+arrayOfRanges+"}";
    check io:fileWriteJson(rangeData, check preparedJson.cloneWithType(json));   
}

function generateFileData() returns error? {
    log:printInfo("SampleDataGenerator -> FileData");
    stream<sheets:File> response = check spreadsheetClient->getAllSpreadsheets();
    var file1 = response.next();
    var file2 = response.next();
    var file3 = response.next();
    sheets:File? spreadsheet1 = file1?.value;
    sheets:File? spreadsheet2 = file2?.value;
    sheets:File? spreadsheet3 = file3?.value;
    string arrayOfFiles = SQUARE_BRACKET_LEFT + spreadsheet1.toJsonString() + COMMA 
                                + spreadsheet2.toJsonString() + COMMA + spreadsheet3.toJsonString() 
                                + SQUARE_BRACKET_RIGHT;
    string preparedJson = "{"+"\"ballerinax/googleapis.sheets:"+connecterVersion+":File\""+":"+arrayOfFiles+"}";
    check io:fileWriteJson(fileData, check preparedJson.cloneWithType(json)); 
}

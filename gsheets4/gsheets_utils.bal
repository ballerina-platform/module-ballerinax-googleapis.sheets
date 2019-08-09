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

import ballerina/http;
import ballerina/io;

function setResponseError(json jsonResponse) returns error {
    return error(SPREADSHEET_ERROR_CODE, { message: jsonResponse["error"].message.toString() });
}

function setResError(error apiResponse) returns error {
    return error(SPREADSHEET_ERROR_CODE, { message: <string>apiResponse.detail().message });
}

function setJsonResponse(json jsonResponse, int statusCode) returns Spreadsheet|error {
    if (statusCode == http:OK_200) {
        return convertToSpreadsheet(jsonResponse);
    }
    return setResponseError(jsonResponse);
}

function setResponse(json jsonResponse, int statusCode) returns error? {
    if (statusCode == 200) {
        return;
    }
    return setResponseError(jsonResponse);
}

function validateSpreadSheetId(string spreadSheetId) returns error? {
    string regEx = "[a-zA-Z0-9-_]+";
    boolean isMatch = check spreadSheetId.matches(regEx);
    if (isMatch) {
        return;
    }
    error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred by a spreadsheet ID: "
    + spreadSheetId + ", that should be satisfy the regular expression format: [a-zA-Z0-9-_]+"});
    return err;
}

function validateSheetName(string spreadSheetName) returns boolean {
    return (spreadSheetName.indexOf("(") == 0 || spreadSheetName.contains(" "));
}

function setRowA1Notation(string sheetName, int row, boolean sheetNameValidationResult) returns string {
    string a1Notation;
    if (sheetNameValidationResult) {
        a1Notation = APOSTROPHE + sheetName.replace(WHITE_SPACE, ENCODED_VALUE_FOR_WHITE_SPACE) + APOSTROPHE
        + EXCLAMATION_MARK + row + COLON + row;
    } else {
        a1Notation = sheetName + EXCLAMATION_MARK +  row + COLON + row;
    }
    return a1Notation;
}

function setColumnA1Notation(string sheetName, string column, boolean sheetNameValidationResult) returns string {
    string a1Notation;
    if (sheetNameValidationResult) {
        a1Notation = APOSTROPHE + sheetName.replace(WHITE_SPACE, ENCODED_VALUE_FOR_WHITE_SPACE) + APOSTROPHE
        + EXCLAMATION_MARK + column + COLON + column;
    } else {
        a1Notation = sheetName + EXCLAMATION_MARK + column + COLON + column;
    }
    return a1Notation;
}

function setA1Notation(string sheetName, boolean sheetNameValidationResult) returns string {
    if (sheetNameValidationResult) {
        return APOSTROPHE + sheetName.replace(WHITE_SPACE, ENCODED_VALUE_FOR_WHITE_SPACE) + APOSTROPHE;
    }
    return sheetName;
}

function setRowColumnA1Notation(string sheetName, int row, string column, boolean sheetNameValidationResult)
returns string {
    if (sheetNameValidationResult) {
        return APOSTROPHE + sheetName.replace(WHITE_SPACE, ENCODED_VALUE_FOR_WHITE_SPACE) + APOSTROPHE
        + EXCLAMATION_MARK + column + row;
    }
    return sheetName;
}

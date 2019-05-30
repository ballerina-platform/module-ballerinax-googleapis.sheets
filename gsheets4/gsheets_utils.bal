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
    return error(SPREADSHEET_ERROR_CODE, { message: jsonResponse["error"].message.toString()});
}

function setResError(error apiResponse) returns error {
    return error(SPREADSHEET_ERROR_CODE, { message: <string>apiResponse.detail().message});
}

function setJsonResponse(json jsonResponse, int statusCode) returns Spreadsheet|error {
    if (statusCode == http:OK_200) {
        Spreadsheet spreadsheet = convertToSpreadsheet(jsonResponse);
        return spreadsheet;
    }
    return setResponseError(jsonResponse);
}

function setResponse(json jsonResponse, int statusCode) returns boolean|error{
    if (statusCode == http:OK_200) {
        return true;
    }
    return setResponseError(jsonResponse);
}

function validateSpreadSheetId(string spreadSheetId) returns error? {
    string regEx = "[a-zA-Z0-9-_]+";
    boolean isMatch = checkpanic spreadSheetId.matches(regEx);
    if (isMatch) {
        return;
    }
    error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred by a spreadsheet ID: "
                + spreadSheetId + ", that should be satisfy the regular expression format: [a-zA-Z0-9-_]+"});
    return err;
}

function validateSheetName(string spreadSheetName) returns boolean {
    int index = spreadSheetName.indexOf("(");
    boolean containsSpace = spreadSheetName.contains(" ");
    return (index == 0 || containsSpace);
}

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
    error err = error(SPREADSHEET_ERROR_CODE, { message: jsonResponse["error"].message.toString()});
    return err;
}

function setResError(error apiResponse) returns error {
    error err = error(SPREADSHEET_ERROR_CODE, { message: <string>apiResponse.detail().message});
    return err;
}

function validateSpreadSheetId(string spreadSheetId) returns error? {
    string regEx = "[a-zA-Z0-9-_]+";
    boolean isMatch = checkpanic spreadSheetId.matches(regEx);
    if (!isMatch) {
        error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred by a spreadsheet ID: "
            + spreadSheetId + ", which supports only letters, numbers and some special characters."});
        return err;
    }
}

function validateSheetName(string spreadSheetName) returns boolean {
    int index = spreadSheetName.indexOf("(");
    boolean isContain = spreadSheetName.contains(" ");
    if (index == 0 || isContain) {
        return true;
    } else {
        return false;
    }
}

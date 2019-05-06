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
    map<json> mapValue = <map<json>> map<json>.convert(jsonResponse);
    foreach var (i, errorDetails) in mapValue {
       error err = error(SPREADSHEET_ERROR_CODE, { message: errorDetails.message.toString()});
       return err;
    }
}

function validateSpreadSheetId(string spreadSheetId) returns boolean|error {
    string regEx = "[a-zA-Z0-9-_]+";
    boolean|error isMatch = spreadSheetId.matches(regEx);
    if (isMatch is error) {
        panic isMatch;
    } else {
        if (!isMatch) {
            error err = error(SPREADSHEET_ERROR_CODE, { message: "Error occurred by a spreadsheet ID: "
                + spreadSheetId + ", which supports only letters, numbers and some special characters."});
            return err;
        } else {
            return isMatch;
        }
    }
}

function validateSheetName(string spreadSheetName) returns boolean {
    int|error index = spreadSheetName.indexOf("(");
    boolean|error isContain = spreadSheetName.contains(" ");
    if (isContain is error) {
        panic isContain;
    } else if(index is error) {
        panic index;
    } else {
        if (index == 0 || isContain) {
            return true;
        } else {
            return false;
        }
    }
}

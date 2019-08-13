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

function setResponseError(json jsonResponse) returns error {
    error err = error(SPREADSHEET_ERROR_CODE, message = jsonResponse.message.toString());
    return err;
}

function setResError(error errorResponse) returns error {
    error err = error(SPREADSHEET_ERROR_CODE, message = <string> errorResponse.detail()?.message);
    return err;
}

function setJsonResponse(json jsonResponse, int statusCode) returns Spreadsheet|error {
    if (statusCode == http:STATUS_OK) {
        return convertToSpreadsheet(jsonResponse);
    }
    return setResponseError(jsonResponse);
}

function setResponse(json jsonResponse, int statusCode) returns boolean|error {
    if (statusCode == http:STATUS_OK) {
        return true;
    }
    return setResponseError(jsonResponse);
}

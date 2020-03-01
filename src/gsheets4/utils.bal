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
    error err = error(SPREADSHEET_ERROR_CODE, message = jsonResponse.toString());
    return err;
}

function setResError(error errorResponse) returns error {
    error err = error(SPREADSHEET_ERROR_CODE, message = <string>errorResponse.detail()?.message);
    return err;
}

function sendRequestWithPayload(http:Client httpClient, string path, json jsonPayload = ())
returns @tainted json | error {
    http:Request httpRequest = new;
    if (jsonPayload != ()) {
        httpRequest.setJsonPayload(<@untainted>jsonPayload);
    }
    var httpResponse = httpClient->post(<@untainted>path, httpRequest);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        json | http:ClientError jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
            if (validateStatusCodeRes is error) {
                return validateStatusCodeRes;
            }
            return jsonResponse;
        } else {
            return createConnectorError(jsonResponse);
        }
    } else {
        return createConnectorError(httpResponse);
    }
}

function sendRequest(http:Client httpClient, string path) returns @tainted json | error {
    var httpResponse = httpClient->get(<@untainted>path);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        json | http:ClientError jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
            if (validateStatusCodeRes is error) {
                return validateStatusCodeRes;
            }
            return jsonResponse;
        } else {
            return createConnectorError(jsonResponse);
        }
    } else {
        return createConnectorError(httpResponse);
    }
}

function createConnectorError(error errorResponse) returns error {
    error err = error(SPREADSHEET_ERROR_CODE, message = <string>errorResponse.detail()?.message);
    return err;
}

function getConvertedValue(json value) returns string | int | float {
    if (value is int) {
        return value;
    } else if (value is float) {
        return value;
    } else {
        return value.toString();
    }
}

function setJsonResponse(json jsonResponse, int statusCode, Client cli) returns Spreadsheet | error {
    if (statusCode == http:STATUS_OK) {
        return convertToSpreadsheet(jsonResponse, cli);
    }
    return setResponseError(jsonResponse);
}

function validateResponse(json jsonResponse, int statusCode, Client cli) returns Spreadsheet | error {
    if (statusCode == http:STATUS_OK) {
        return convertToSpreadsheet(jsonResponse, cli);
    }
    return setResponseError(jsonResponse);
}

function validateStatusCode(json response, int statusCode) returns error? {
    if (statusCode != http:STATUS_OK) {
        return setResponseError(response);
    }
    return ();
}
function setResponse(json jsonResponse, int statusCode) returns error? {
    if (statusCode == http:STATUS_OK) {
        return ();
    }
    return setResponseError(jsonResponse);
}

function equalsIgnoreCase(string stringOne, string stringTwo) returns boolean {
    if (stringOne.toLowerAscii() == stringTwo.toLowerAscii()) {
        return true;
    }
    return false;
}

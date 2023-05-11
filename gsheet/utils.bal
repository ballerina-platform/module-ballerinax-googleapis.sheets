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

import ballerina/http;
import ballerina/jballerina.java as java;
import ballerina/regex;

isolated function sendRequestWithPayload(http:Client httpClient, string path, json jsonPayload = ())
returns @tainted json | error {
    http:Request httpRequest = new;
    if (jsonPayload != ()) {
        httpRequest.setJsonPayload(<@untainted>jsonPayload);
    }
    http:Response|error httpResponse = httpClient->post(<@untainted>path, httpRequest);
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
            return getSpreadsheetError(jsonResponse);
        }
    } else {
        return getSpreadsheetError(<json|error>httpResponse);
    }
}

isolated function sendRequest(http:Client httpClient, string path) returns @tainted json | error {
    http:Response|error httpResponse = httpClient->get(<@untainted>path);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        json | error jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
            if (validateStatusCodeRes is error) {
                return validateStatusCodeRes;
            }
            return jsonResponse;
        } else {
            return getSpreadsheetError(jsonResponse);
        }
    } else {
        return getSpreadsheetError(<json|error>httpResponse);
    }
}

isolated function getConvertedValue(json value) returns string|int|decimal {
    if (value is int) {
        return value;
    } else if (value is decimal) {
        return value;
    } else {
        return value.toString();
    }
}

isolated function validateStatusCode(json response, int statusCode) returns error? {
    if (!(statusCode == http:STATUS_OK)) {
        return getSpreadsheetError(response);
    }
}

isolated function setResponse(json jsonResponse, int statusCode) returns error? {
    if (!(statusCode == http:STATUS_OK)) {
        return getSpreadsheetError(jsonResponse);
    }
}

isolated function equalsIgnoreCase(string stringOne, string stringTwo) returns boolean {
    if (stringOne.toLowerAscii() == stringTwo.toLowerAscii()) {
        return true;
    }
    return false;
}

isolated function getSpreadsheetError(json|error errorResponse) returns error {
  if (errorResponse is json) {
        return error(errorResponse.toString());
  } else {
        return errorResponse;
  }
}

isolated function getIdFromUrl(string url) returns string|error {
    if (!url.startsWith(URL_START)) {
        return error("Invalid url: " + url);
    } else {
        int? endIndex = url.indexOf(URL_END);
        if (endIndex is ()) {
            return error("Invalid url: " + url);
        } else {
            return url.substring(ID_START_INDEX, endIndex);
        }
    }
}

# Get the error message from the response.
#
# + response - Received response.
# + return - Returns module error with payload and response code.
isolated function getErrorMessage(http:Response response) returns @tainted error {
    json|error payload = response.getTextPayload();
    string payloadString = "";
    if (payload is json) {
        payloadString = payload.toString();
    }
    return error("Invalid response from Google Sheet API. statuscode: " + response.statusCode.toString() + 
        ", payload: " + payloadString, status = response.statusCode);
}

# Get the drive url path to get a list of files.
# 
# + pageToken - Token for retrieving next page (Optional)
# + return - drive url on success, else an error
isolated function prepareDriveUrl(string? pageToken = ()) returns string {
    string drivePath;
    if (pageToken is string) {
        drivePath = DRIVE_PATH + FILES + QUESTION_MARK + Q + EQUAL + MIME_TYPE + EQUAL + APPLICATION + 
            AND_SIGN + TRASH_FALSE + AND + PAGE_TOKEN + EQUAL + pageToken;
        return drivePath;
    }
    drivePath = DRIVE_PATH + FILES + QUESTION_MARK + Q + EQUAL + MIME_TYPE + EQUAL + APPLICATION + AND_SIGN + 
        TRASH_FALSE;
    return drivePath;
}

# Create a random UUID removing the unnecessary hyphens which will interrupt querying opearations.
# 
# + return - A string UUID without hyphens
public function createRandomUUIDWithoutHyphens() returns string {
    string? stringUUID = java:toString(createRandomUUID());
    if (stringUUID is string) {
        return regex:replaceAll(stringUUID, "-", "");
    } else {
        return "";
    }
}

# Get a string containing the A1 Annotation from A1Range.
# 
# + a1Range - A1Range filter.
# + return - A string with A1 Annotation. 
public isolated function getA1RangeString(A1Range a1Range) returns string|error {
    string filter = a1Range.sheetName;
    if a1Range.startIndex == () && a1Range.endIndex != () {
        return error("Error: The provided A1 range is not supported. ");
    }
    if a1Range.startIndex != () {
        filter = string `${filter}!${<string>a1Range.startIndex}`;
    }
    if a1Range.endIndex != () {
        filter = string `${filter}:${<string>a1Range.endIndex}`;
    }
    return filter;
}

function createRandomUUID() returns handle = @java:Method {
    name: "randomUUID",
    'class: "java.util.UUID"
} external;



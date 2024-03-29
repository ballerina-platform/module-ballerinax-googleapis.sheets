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

isolated function convertJSONToSheetArray(json|error sheetListJson) returns Sheet[]|error {
    Sheet[] sheets = [];
    if sheetListJson is json[] { // When there are multiple sheets, it will be a json[]
        foreach json sheetJsonObject in sheetListJson {
            Sheet sheet = check sheetJsonObject.fromJsonWithType();
            sheets.push(sheet);
        }
    } else if sheetListJson is json { // When there is only one sheet, it will be a json
        Sheet sheet = check sheetListJson.fromJsonWithType();
        sheets.push(sheet);
    }
    return sheets;
}

isolated function convertToInt(string stringVal) returns int {
    if stringVal != "" {
        int|error intVal = int:fromString(stringVal);
        if intVal is int {
            return intVal;
        }
        panic error("Error occurred when converting " + stringVal + " to int");
    }
    return 0;
}

isolated function convertToBoolean(string stringVal) returns boolean {
    return stringVal == "true";
}

isolated function convertToArray(json jsonResponse) returns (string|int|decimal)[][] {
    (string|int|decimal)[][] values = [];
    int i = 0;
    json|error jsonResponseValues = jsonResponse.values;
    json[] jsonValues = [];
    if jsonResponseValues is json[] {
        jsonValues = jsonResponseValues;
    }
    foreach json value in jsonValues {
        json[] jsonValArray = <json[]>value;
        int j = 0;
        (string|int|decimal)[] val = [];
        foreach json v in jsonValArray {
            val[j] = getConvertedValue(v);
            j = j + 1;
        }
        values[i] = val;
        i = i + 1;
    }
    return values;
}

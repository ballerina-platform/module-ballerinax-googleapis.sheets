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

package src.wso2.spreadsheet;

import ballerina.io;

public function findColumn (int columnNumber) returns (string) {
    string[] columnNames = ["A", "B","C","D","E","F","G", "H","I", "J","K","L","M","N","O",
                      "P","Q","R", "S","T","U","V","W","X","Y","Z"];
    string[] col = [];
    string columnName = "";
    int i = 0;
    while (columnNumber > 0) {
        // Find remainder
        int rem = columnNumber % 26;
        // If remainder is 0, then a 'Z' must be there in output
        if (rem == 0) {
            col[i] = "Z";
            columnNumber = (columnNumber / 26) - 1;
        } else {
            col[i] = columnNames[rem - 1];
            columnNumber = columnNumber / 26;
        }
        i = i + 1;
    }
    int j = lengthof col;
    while (j > 0) {
        columnName = columnName + col[j - 1];
        j = j -1;
    }
    return columnName;
}

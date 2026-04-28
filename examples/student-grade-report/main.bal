// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/log;
import ballerina/os;
import ballerinax/googleapis.sheets;

configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");
configurable string & readonly refreshUrl = sheets:REFRESH_URL;

sheets:Client spreadsheetClient = check new ({
    auth: {clientId, clientSecret, refreshUrl, refreshToken}
});

// Student scores: [name, math, science, english, history]
final string[][] studentScores = [
    ["Alice", "92", "88", "95", "90"],
    ["Bob", "75", "82", "70", "68"],
    ["Carol", "88", "91", "85", "93"],
    ["David", "60", "55", "72", "65"],
    ["Eve", "98", "95", "99", "97"],
    ["Frank", "45", "50", "60", "55"]
];

isolated function letterGrade(int avg) returns string {
    if avg >= 90 {
        return "A";
    }
    if avg >= 80 {
        return "B";
    }
    if avg >= 70 {
        return "C";
    }
    if avg >= 60 {
        return "D";
    }
    return "F";
}

public function main() returns error? {
    sheets:Spreadsheet spreadsheet = check spreadsheetClient->createSpreadsheet("Student Grade Report");
    string spreadsheetId = spreadsheet.spreadsheetId;
    string scoresSheetName = spreadsheet.sheets[0].properties.title;

    // Write raw scores with headers
    string[][] scoresData = [["Student", "Math", "Science", "English", "History"]];
    foreach string[] row in studentScores {
        scoresData.push(row);
    }
    _ = check spreadsheetClient->setRange(spreadsheetId, scoresSheetName, {
        a1Notation: string `A1:E${scoresData.length()}`,
        values: scoresData
    });
    log:printInfo(string `Wrote scores for ${studentScores.length()} students.`);

    // Create a grade report sheet
    sheets:Sheet reportSheet = check spreadsheetClient->addSheet(spreadsheetId, "Grade Report");
    string reportSheetName = reportSheet.properties.title;

    _ = check spreadsheetClient->setRange(spreadsheetId, reportSheetName, {
        a1Notation: "A1:E1",
        values: [["Student", "Average", "Grade", "Status", "Remarks"]]
    });

    // Compute and write grade for each student
    int reportRow = 2;
    foreach string[] student in studentScores {
        int math = check int:fromString(student[1]);
        int science = check int:fromString(student[2]);
        int english = check int:fromString(student[3]);
        int history = check int:fromString(student[4]);
        int avg = (math + science + english + history) / 4;
        string grade = letterGrade(avg);
        string status = avg >= 60 ? "Pass" : "Fail";
        string remarks = avg >= 90 ? "Excellent" : avg >= 75 ? "Good" : avg >= 60 ? "Satisfactory" : "Needs Improvement";

        _ = check spreadsheetClient->createOrUpdateRow(spreadsheetId, reportSheetName, reportRow,
            [student[0], avg, grade, status, remarks]);
        reportRow += 1;
    }

    log:printInfo(string `Grade report written to '${reportSheetName}'.`);
    log:printInfo(string `Spreadsheet: ${spreadsheet.spreadsheetUrl}`);
}

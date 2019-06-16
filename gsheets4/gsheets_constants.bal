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

//API urls
final string BASE_URL = "https://sheets.googleapis.com";
public const string REFRESH_URL = "https://www.googleapis.com/oauth2/v3/token";
final string SPREADSHEET_PATH = "/v4/spreadsheets";
final string VALUES_PATH = "/values/";
final string VALUE_INPUT_OPTION = "valueInputOption=RAW";
final string BATCH_UPDATE_REQUEST = ":batchUpdate";

//Secure client configs
final string SCHEME = "oauth";

//Symbols
final string QUESTION_MARK = "?";
final string PATH_SEPARATOR = "/";
final string EMPTY_STRING = "";
final string WHITE_SPACE = " ";
final string ENCODED_VALUE_FOR_WHITE_SPACE = "%20";
final string FORWARD_SLASH = "/";
final string DASH_WITH_WHITE_SPACES_SYMBOL = " - ";
final string COLON = ":";
final string EXCLAMATION_MARK = "!";
final string APOSTROPHE = "'";

// Error Codes
final string SPREADSHEET_ERROR_CODE = "(wso2/gsheets4)SpreadsheetError";
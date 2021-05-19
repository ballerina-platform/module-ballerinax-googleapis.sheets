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

//API URLs
const string BASE_URL = "https://sheets.googleapis.com";
public const string REFRESH_URL = "https://www.googleapis.com/oauth2/v3/token";
const string SPREADSHEET_PATH = "/v4/spreadsheets";
const string VALUES_PATH = "/values/";
const string VALUE_INPUT_OPTION = "valueInputOption=RAW";
const string BATCH_UPDATE_REQUEST = ":batchUpdate";
const string CLEAR_REQUEST = ":clear";
const string APPEND_REQUEST = ":append?valueInputOption=USER_ENTERED";
const string SHEETS_PATH = "/sheets/";
const string COPY_TO_REQUEST = ":copyTo";

//Secure client configs
const string SCHEME = "oauth";

//Symbols
const string QUESTION_MARK = "?";
const string PATH_SEPARATOR = "/";
const string EMPTY_STRING = "";
const string WHITE_SPACE = " ";
const string FORWARD_SLASH = "/";
const string DASH_WITH_WHITE_SPACES_SYMBOL = " - ";
const string COLON = ":";
const string EXCLAMATION_MARK = "!";
const string EQUAL = "=";

// URL constants
const string URL_START = "https://docs.google.com/spreadsheets/d/";
const string URL_END = "/edit";
const int ID_START_INDEX = 39;

//Drive
const string DRIVE_URL = "https://www.googleapis.com";
const string DRIVE_PATH = "/drive/v3";
const string FILES = "/files";
const string Q = "q";
const string MIME_TYPE = "mimeType";
const string APPLICATION = "'application/vnd.google-apps.spreadsheet'";
const string AND = "&";
const string AND_SIGN = "and";
const string TRASH_FALSE ="trashed=false";
const string PAGE_TOKEN = "pageToken";

// Error
const string ERR_FILE_RESPONSE =  "Error occurred while constructing FileResponse record.";


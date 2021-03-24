// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

// MimeTypes
const string FOLDER = "application/vnd.google-apps.folder";
const string FILE = "application/vnd.google-apps.file";
const string SPREADSHEET = "application/vnd.google-apps.spreadsheet";
const string DOCS = "application/vnd.google-apps.document";
const string GOOGLE_DRAWING = "application/vnd.google-apps.drawing";
const string FORM = "application/vnd.google-apps.form";
const string PHOTO = "application/vnd.google-apps.photo";
const string PRESENTATION = "application/vnd.google-apps.presentation";
const string VIDEO = "application/vnd.google-apps.video";
const string audio = "application/vnd.google-apps.audio";
const string LOG_FILE = "text/x-log";
const string TEXT_FILE = "text/plain";

// Sheet API URLs
const string BASE_URL = "https://sheets.googleapis.com";
const string REFRESH_URL = "https://www.googleapis.com/oauth2/v3/token";
const string SPREADSHEET_PATH = "/v4/spreadsheets";
const string PATH_SEPARATOR = "/";

// Change Types
public const string EDIT = "EDIT";
public const string INSERT_ROW = "INSERT_ROW";
public const string REMOVE_ROW = "REMOVE_ROW";
public const string INSERT_COLUMN = "INSERT_COLUMN";
public const string REMOVE_COLUMN = "REMOVE_COLUMN";
public const string INSERT_GRID = "INSERT_GRID";
public const string REMOVE_GRID = "REMOVE_GRID";
public const string OTHER = "OTHER";

// Event Types
public const string ON_EDIT = "onEdit";
public const string ON_CHANGE = "onChange";
public const string ON_MANAGE = "onManage";

// Trigger log
const string TRIGGER_LOG = ">>>>> INCOMING TRIGGER >>>>> ";

//Symbols
const string EMPTY_STRING = "";

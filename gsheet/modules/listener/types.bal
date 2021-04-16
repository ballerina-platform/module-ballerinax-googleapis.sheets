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

# Listener Configuration.
#
# + port - Port for the listener
# + spreadsheetId - Identifier of the specific spreadsheet
public type SheetListenerConfiguration record {
    int port;
    string spreadsheetId;
};

# Define event information.
#
# + editEventInfo - Edit event information
# + eventType - Type of the event  
public type EventInfo record {
    string eventType?;
    EditEventInfo editEventInfo?;
};

# Define edit event Information.
#
# + startingColumnPosition - Starting column position for the range edited  
# + lastColumnWithContent - Position of the last column that has content  
# + startingRowPosition - Starting row position for the range edited  
# + worksheetId - Identifier of the worksheet edited 
# + spreadsheetName - Name of the spreadsheet edited  
# + spreadsheetId - Identifier of the spreadsheet edited 
# + lastRowWithContent - Position of the last row that has content
# + newValues - Rectangular grid of updated values in the range  
# + worksheetName - Name of the worksheet edited 
# + rangeUpdated - String description of the edited range in A1 notation
# + endColumnPosition - End column position for the range edited 
# + endRowPosition - End row position for the range edited  
# + eventData - App Script Event Object
public type EditEventInfo record {
    string spreadsheetId?;
    string spreadsheetName?;
    int worksheetId?;
    string worksheetName?;
    string rangeUpdated?;
    int startingRowPosition?;
    int endRowPosition?;
    int startingColumnPosition?;
    int endColumnPosition?;
    (int|string|float)[][] newValues?;
    int lastRowWithContent?;
    int lastColumnWithContent?;
    json eventData?;
};

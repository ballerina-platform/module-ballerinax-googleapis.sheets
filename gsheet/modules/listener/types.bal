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
@display {label: "Connection Config"}
public type SheetListenerConfiguration record {
    @display {label: "Listener Port"}
    int port;
    @display {label: "Spreadsheet Id"}
    string spreadsheetId;
};

# Define event information.
#
# + eventInfo - Event information
# + eventType - Type of the event 
@display {label: "Google Sheet Event"}
public type GSheetEvent record {
    @display {label: "Event Type"}
    string eventType?;
    EventInfo eventInfo?;
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
@display {label: "Event Info"}
public type EventInfo record {
    @display {label: "Spreadsheet Id"}
    string spreadsheetId?;
    @display {label: "Spreadsheet Name"}
    string spreadsheetName?;
    @display {label: "Worksheet Id"}
    int worksheetId?;
    @display {label: "Worksheet Name"}
    string worksheetName?;
    @display {label: "Range Updated"}
    string rangeUpdated?;
    @display {label: "Starting Row Position"}
    int startingRowPosition?;
    @display {label: "End Row Position"}
    int endRowPosition?;
    @display {label: "Starting Column Position"}
    int startingColumnPosition?;
    @display {label: "End Column Position"}
    int endColumnPosition?;
    @display {label: "New Values"}
    (int|string|float)[][] newValues?;
    @display {label: "Last Row with Content"}
    int lastRowWithContent?;
    @display {label: "Last Column with Content"}
    int lastColumnWithContent?;
    @display {label: "Event Data"}
    json eventData?;
};

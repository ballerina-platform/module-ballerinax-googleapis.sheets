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

import ballerinax/googleapis_drive as drive;

# Listener Configuration.
#
# + port - Port for the listener
# + callbackURL - Callback URL registered
# + driveClientConfiguration - Drive client connecter configuration 
# + eventService - 'OnEventService' object with supported manage events 
# + specificGsheetId - Identifier of the specific spreadsheet
public type SheetListenerConfiguration record {
    int port;
    string callbackURL;
    drive:Configuration driveClientConfiguration;
    OnEventService eventService;
    string? specificGsheetId = ();
};

# Watch request properties
#
# + address - The address where notifications are delivered for this channel.  
# + payload - A Boolean value to indicate whether payload is wanted.  
# + kind - Identifies this as a notification channel used to watch for changes to a resource, which is "api#channel".  
# + expiration - Date and time of notification channel expiration, expressed as a Unix timestamp, in milliseconds.  
# + id - A UUID or similar unique string that identifies this channel.  
# + type - The type of delivery mechanism used for this channel. Valid values are "web_hook" (or "webhook"). 
#          Both values refer to a channel where Http requests are used to deliver messages  
# + token - An arbitrary string delivered to the target address with each notification delivered over this channel. 
public type WatchRequestproperties record {
    string kind = "api#channel";
    string id;
    string 'type = "web_hook";
    string address;
    string token?;
    int? expiration?;
    boolean payload?;
};

# Record type that matches Change response.
#
# + resourceId - An opaque ID that identifies the resource being watched on this channel. 
#                Stable across different API versions.  
# + kind - Identifies this as a notification channel used to watch for changes to a resource, which is "api#channel".  
# + expiration - Date and time of notification channel expiration, expressed as a Unix timestamp, in milliseconds.  
# + id - A UUID or similar unique string that identifies this channel.  
# + resourceUri - A version-specific identifier for the watched resource.
public type changeResponse record {
    string kind;
    string id;
    string resourceId;
    string resourceUri;
    int expiration;
};


# This type object 'OnEventService' with all Event funtions.
public type OnEventService object {
    public isolated function onNewSheetCreatedEvent(string folderId);
    public isolated function onSheetDeletedEvent(string fileId);
    public isolated function onFileUpdateEvent(string fileId);
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
};

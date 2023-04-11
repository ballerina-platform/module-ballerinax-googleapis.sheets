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
import ballerinax/'client.config;

# Client configuration details.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    # Configurations related to client authentication
    http:BearerTokenConfig|config:OAuth2RefreshTokenGrantConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_1_1;
|};

# Spreadsheet information.
# 
# + spreadsheetId - Id of the spreadsheet
# + properties - Properties of a spreadsheet
# + sheets - The sheets that are part of a spreadsheet
# + spreadsheetUrl - The Url of the spreadsheet
@display {label: "Spreadsheet"}
public type Spreadsheet record {
    @display {label: "Spreadsheet Id"}
    string spreadsheetId = "";
    SpreadsheetProperties properties = {};
    @display {label: "Array of Worksheets"}
    Sheet[] sheets = [];
    @display {label: "Spreadsheet Url"}
    string spreadsheetUrl = "";
};

# Worksheet information.
# 
# + properties - Properties of a worksheet
@display {label: "Worksheet"}
public type Sheet record {
    SheetProperties properties = {};
};

# Spreadsheet properties.
# 
# + title - The title of the spreadsheet
# + locale - The locale of the spreadsheet
# + autoRecalc - The amount of time to wait before volatile functions are recalculated
# + timeZone - The time zone of the spreadsheet
@display {label: "Spreadsheet Properties"}
public type SpreadsheetProperties record {
    @display {label: "Spreadsheet Title"}
    string title = "";
    @display {label: "Spreadsheet Locale"}
    string locale = "";
    @display {label: "Auto Recalculate Time"}
    string autoRecalc = "";
    @display {label: "Spreadsheet Timezone"}
    string timeZone = "";
};

# Worksheet properties.
# 
# + sheetId - The ID of the worksheet
# + title - The name of the worksheet
# + index - The index of the worksheet within the spreadsheet
# + sheetType - The type of worksheet
# + gridProperties - Additional properties of the worksheet if this worksheet is a grid
# + hidden - True if the worksheet is hidden in the UI, false if it is visible
# + rightToLeft - True if the worksheet is an RTL worksheet instead of an LTR worksheet
@display {label: "Worksheet Properties"}
public type SheetProperties record {
    @display {label: "Worksheet ID"}
    int sheetId = 0;
    @display {label: "Worksheet Title"}
    string title = "";
    @display {label: "Worksheet Index"}
    int index = 0;
    @display {label: "Worksheet Type"}
    string sheetType = "";
    GridProperties gridProperties = {};
    @display {label: "Hidden"}
    boolean hidden = false;
    @display {label: "Right To Left"}
    boolean rightToLeft = false;
};

# Grid properties.
# 
# + rowCount - The number of rows in the grid
# + columnCount - The number of columns in the grid
# + frozenRowCount - The number of rows that are frozen in the grid
# + frozenColumnCount - The number of columns that are frozen in the grid
# + hideGridlines - True if the grid is not showing gridlines in the UI
@display {label: "Grid Properties"}
public type GridProperties record {
    @display {label: "Row Count"}
    int rowCount = 0;
    @display {label: "Column Count"}
    int columnCount = 0;
    @display {label: "Frozen Row Count"}
    int frozenRowCount = 0;
    @display {label: "Frozen Column Count"}
    int frozenColumnCount = 0;
    @display {label: "Hide Grid Lines"}
    boolean hideGridlines = false;
};

# Single cell or a group of adjacent cells in a sheet.
#
# + a1Notation - The column letter followed by the row number.
#                For example for a single cell "A1" refers to the intersection of column "A" with row "1",
#                and for a range of cells "A1:D5" refers to the top left cell and the bottom right cell of a range
# + values - Values of the given range
@display {label: "Range"}
public type Range record {
    @display {label: "A1 Notation"}
    string a1Notation;
    @display {label: "Values"}
    (int|string|decimal)[][] values;
};

# Single column in a sheet.
#
# + columnPosition - The column letter
# + values - Values of the given column
@display {label: "Column"}
public type Column record {
    @display {label: "Column Letter"}
    string columnPosition;
    @display {label: "Values"}
    (int|string|decimal)[] values;
};

# Single row in a sheet.
#
# + rowPosition - The row number
# + values - Values of the given row
@display {label: "Row"}
public type Row record {
    @display {label: "Row Number"}
    int rowPosition;
    @display {label: "Values"}
    (int|string|decimal)[] values;
};

# Single cell in a sheet.
#
# + a1Notation - The column letter followed by the row number.
#                For example for a single cell "A1" refers to the intersection of column "A" with row "1"
# + value - Value of the given cell
@display {label: "Cell"}
public type Cell record {
    @display {label: "A1 Notation"}
    string a1Notation;
    @display {label: "Value"}
    (int|string|decimal) value;
};

# Response from File search 
#
# + kind - Identifies what kind of resource is this. Value: the fixed string "drive#fileList".
# + nextPageToken - The page token for the next page of files. 
#                   This will be absent if the end of the files list has been reached.
#                   If the token is rejected for any reason, it should be discarded, 
#                   and pagination should be restarted from the first page of results.
# + files - The list of files. 
#           If nextPageToken is populated, 
#           then this list may be incomplete and an additional page of results should be fetched. 
# + incompleteSearch - Whether the search process was incomplete. If true, then some search results may be missing, 
#                      Since all documents were not searched. This may occur when searching multiple drives with the 
#                      "allDrives" corpora, but all corpora could not be searched. When this happens, it is suggested 
#                      that clients narrow their query by choosing a different corpus such as "user" or "drive".  
@display {label: "Files Response"}
public type FilesResponse record {
    @display {label: "Kind"}
    string kind;
    @display {label: "Next Page Token"}
    string nextPageToken?;
    @display {label: "Incomplete Search"}
    boolean incompleteSearch;
    @display {label: "Array of Files"}
    File[] files;
};

# File information
#
# + kind - Identifies what kind of resource is this. Value: the fixed string "drive#file".   
# + id - The Id of the file
# + name - The name of the file
# + mimeType - The MIME type of the file
@display {label: "File"}
public type File record {
    @display {label: "Kind"}
    string kind;
    @display {label: "Id"}
    string id;
    @display {label: "Name"}
    string name;
    @display {label: "Mime Type"}
    string mimeType;
};

# The metadata visibility
# 
@display {label: "Metadata visibility"}
public enum Visibility {
    UNSPECIFIED_VISIBILITY = "DEVELOPER_METADATA_VISIBILITY_UNSPECIFIED",
    DOCUMENT = "DOCUMENT",
    PROJECT = "PROJECT"
};

# The location type for filters
# 
@display {label: "Location Type"}
public enum LocationType {
    UNSPECIFIED_LOCATION = "DEVELOPER_METADATA_LOCATION_TYPE_UNSPECIFIED",
    COLUMN = "COLUMN",
    SPREADSHEET = "SPREADSHEET",
    SHEET = "SHEET",
    ROW = "ROW"
};

# Dimension
#
@display {label: "Dimension"}
public enum Dimension {
    UNSPECIFIED_DIMENSION = "DIMENSION_UNSPECIFIED",
    COLUMNS = "COLUMNS",
    ROWS = "ROWS"
};

# The location matching strategy for filters
#
# + kind - Indicates location matching strategy used in filter.  
@display {label: "Location Matching Strategy"}
public enum LocationMatchingStrategy {
    UNSPECIFIED_STRATEGY = "DEVELOPER_METADATA_LOCATION_MATCHING_STRATEGY_UNSPECIFIED",
    EXACT_LOCATION = "EXACT_LOCATION",
    INTERSECTING_LOCATION = "INTERSECTING_LOCATION"
};

# The developerMetadataLookup filter
#  
@display {label: "DeveloperMetadataLookup Filter"}
public type DeveloperMetadataLookupFilter record {
    @display {label: "Location Type"}
    LocationType locationType;
    @display {label: "Location matching strategy"}
    LocationMatchingStrategy locationMatchingStrategy?;
    @display {label: "metadataId"}
    int metadataId?;
    @display {label: "metadataKey"}
    string metadataKey?;
    @display {label: "metadataValue"}
    string metadataValue;
    @display {label: "Metadata Visibility"}
    Visibility visibility?;
    @display {label: "Metadata Location"}
    MetadataLocation metadataLocation?;

};

# The Metadata Location
#
@display {label: "Metadata Location"}
public type MetadataLocation record {
    @display {label: "Location Type"}
    LocationType locationType;
    @display {label: "spreadsheet"}
    boolean spreadsheet;
    @display {label: "sheetId"}
    int sheetId;
    @display {label: "Dimension Range"}
    DimensionRange dimensionRange;
};

# The Dimension Range
#
@display {label: "Dimension Range"}
public type DimensionRange record {
    @display {label: "sheetId"}
    int sheetId;
    @display {label: "Dimension"}
    Dimension dimension;
    @display {label: "Start Index"}
    int startIndex;
    @display {label: "End Index"}
    int endIndex;
};


# The gridrange filters
#
@display {label: "Gridrange filter"}
public type GridRangeFilter record {
    int sheetId;
    int startRowIndex?;
    int endRowIndex?;
    int startColumnIndex?;
    int endColumnIndex?;
};


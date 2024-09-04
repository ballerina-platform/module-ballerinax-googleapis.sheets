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

// Update the config fields with default values due to lang issue https://github.com/ballerina-platform/ballerina-lang/issues/43359
# Provides a set of configurations for controlling the behaviours when communicating with a remote HTTP endpoint.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # Configurations related to client authentication
    http:BearerTokenConfig|OAuth2RefreshTokenGrantConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_2_0;
    # Configurations related to HTTP/1.x protocol
    ClientHttp1Settings http1Settings = {};
    # Configurations related to HTTP/2 protocol
    http:ClientHttp2Settings http2Settings = {};
    # The maximum time to wait (in seconds) for a response before closing the connection
    decimal timeout = 60;
    # The choice of setting `forwarded`/`x-forwarded` header
    string forwarded = "disable";
    # Configurations associated with request pooling
    http:PoolConfiguration? poolConfig = ();
    # HTTP caching related configurations
    http:CacheConfig cache = {};
    # Specifies the way of handling compression (`accept-encoding`) header
    http:Compression compression = http:COMPRESSION_AUTO;
    # Configurations associated with the behaviour of the Circuit Breaker
    http:CircuitBreakerConfig? circuitBreaker = ();
    # Configurations associated with retrying
    http:RetryConfig? retryConfig = ();
    # Configurations associated with inbound response size limits
    http:ResponseLimitConfigs responseLimits = {};
    # SSL/TLS-related options
    http:ClientSecureSocket secureSocket = {};
    # Proxy server related options
    http:ProxyConfig? proxy = ();
    # Enables the inbound payload validation functionality which provided by the constraint package. Enabled by default
    boolean validation = true;
|};

# Provides settings related to HTTP/1.x protocol.
public type ClientHttp1Settings record {|
    # Specifies whether to reuse a connection for multiple requests
    http:KeepAlive keepAlive = http:KEEPALIVE_AUTO;
    # The chunking behaviour of the request
    http:Chunking chunking = http:CHUNKING_AUTO;
    # Proxy server related options
    ProxyConfig? proxy = ();
|};

# Proxy server configurations to be used with the HTTP client endpoint.
public type ProxyConfig record {|
    # Host name of the proxy server
    string host = "";
    # Proxy server port
    int port = 0;
    # Proxy server username
    string userName = "";
    # Proxy server password
    @display {label: "", kind: "password"}
    string password = "";
|};

# OAuth2 Refresh Token Grant Configs
public type OAuth2RefreshTokenGrantConfig record {|
    *http:OAuth2RefreshTokenGrantConfig;
    # Refresh URL
    string refreshUrl = "https://accounts.google.com/o/oauth2/token";
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
# For example for a single cell "A1" refers to the intersection of column "A" with row "1",
# and for a range of cells "A1:D5" refers to the top left cell and the bottom right cell of a range
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

# A1 Notation of a ValueRange
#
# + sheetName - Sheet name in A1 notation
# + startIndex - Starting cell of the range
# + endIndex - Ending cell of the range
@display {label: "A1Range"}
public type A1Range record {
    @display {label: "Sheet Name"}
    string sheetName;
    @display {label: "Start Index"}
    string startIndex?;
    @display {label: "End Index"}
    string endIndex?;
};

# Values related to a single row.
#
# + rowPosition - The row number
# + values - Values of the given row
# + a1Range - A1Notation of the range
@display {label: "ValueRange"}
public type ValueRange record {
    @display {label: "Row Number"}
    int rowPosition;
    @display {label: "Values"}
    (int|string|decimal|boolean|float)[] values;
    @display {label: "A1 Range"}
    A1Range a1Range;
};

# Values related to a multiple rows.
#
# + rowStartPosition - The row number
# + values - Values of the given rows
# + a1Range - A1Notation of the range
@display {label: "ValuesRange"}
public type ValuesRange record {|
    @display {label: "Starting Row Number"}
    int rowStartPosition;
    @display {label: "Values"}
    (int|string|decimal|boolean|float)[][] values;
    @display {label: "A1 Range"}
    A1Range a1Range;
|};

# Single cell in a sheet.
#
# + a1Notation - The column letter followed by the row number.
# For example for a single cell "A1" refers to the intersection of column "A" with row "1"
# + value - Value of the given cell
@display {label: "Cell"}
public type Cell record {
    @display {label: "A1 Notation"}
    string a1Notation;
    @display {label: "Value"}
    (int|string|decimal) value;
};

# The metadata visibility
#
@display {label: "Metadata Visibility"}
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
@display {label: "Location Matching Strategy"}
public enum LocationMatchingStrategy {
    UNSPECIFIED_STRATEGY = "DEVELOPER_METADATA_LOCATION_MATCHING_STRATEGY_UNSPECIFIED",
    EXACT_LOCATION = "EXACT_LOCATION",
    INTERSECTING_LOCATION = "INTERSECTING_LOCATION"
};

# The DeveloperMetadataLookup filter
#
# + locationType - Specified type which the metadata ara associated.
# For more information, see [LocationType](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.developerMetadata#DeveloperMetadata.DeveloperMetadataLocationType)
# + locationMatchingStrategy - An enumeration of strategies for matching developer metadata locations.
# For more information, see [locationMatchingStrategy](https://developers.google.com/sheets/api/reference/rest/v4/DataFilter#DeveloperMetadataLocationMatchingStrategy).
# + metadataId - The spreadsheet-scoped unique ID that identifies the metadata.
# + metadataKey - Key used to identify metadata.
# + metadataValue - Data associated with the metadata's key.
# + visibility - Visibility scope of the associated metadata
# For more information, see [Visibility](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.developerMetadata#DeveloperMetadata.DeveloperMetadataVisibility).
# + metadataLocation - Location of association for metadata
#
@display {label: "DeveloperMetadataLookup Filter"}
public type DeveloperMetadataLookupFilter record {
    @display {label: "Location Type"}
    LocationType locationType;
    @display {label: "Location matching strategy"}
    LocationMatchingStrategy locationMatchingStrategy?;
    @display {label: "Metadata Id"}
    int metadataId?;
    @display {label: "Metadata Key"}
    string metadataKey?;
    @display {label: "Metadata Value"}
    string metadataValue;
    @display {label: "Metadata Visibility"}
    Visibility visibility?;
    @display {label: "Metadata Location"}
    MetadataLocation metadataLocation?;
};

# The Metadata Location
#
# + locationType - Specified type which the metadata ara associated.
# For more information, see [LocationType](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.developerMetadata#DeveloperMetadata.DeveloperMetadataLocationType)
# + spreadsheet - Whether metadata is associated with an entire spreadsheet.
# + sheetId - The ID of the worksheet
# + dimensionRange - Dimension when the metadata is associated with them
#
@display {label: "Metadata Location"}
public type MetadataLocation record {
    @display {label: "Location Type"}
    LocationType locationType;
    @display {label: "Spreadsheet"}
    boolean spreadsheet;
    @display {label: "Worksheet ID"}
    int sheetId;
    @display {label: "Dimension Range"}
    DimensionRange dimensionRange;
};

# The Dimension Range
#
# + sheetId - The ID of the worksheet
# + dimension - The dimension of the span
# + startIndex - The start (inclusive) of the span, or not set if unbounded
# + endIndex - The end (exclusive) of the span, or not set if unbounded.
#
@display {label: "Dimension Range"}
public type DimensionRange record {
    @display {label: "Worksheet ID"}
    int sheetId;
    @display {label: "Dimension"}
    Dimension dimension;
    @display {label: "Start Index"}
    int startIndex;
    @display {label: "End Index"}
    int endIndex;
};

# The GridRange filters
#
# + sheetId - The ID of the worksheet
# + startRowIndex - The start row (inclusive) of the range, or not set if unbounded.
# + endRowIndex - The end row (exclusive) of the range, or not set if unbounded.
# + startColumnIndex - The start column (inclusive) of the range, or not set if unbounded.
# + endColumnIndex - The end column (exclusive) of the range, or not set if unbounded.
#
@display {label: "Gridrange Filter"}
public type GridRangeFilter record {
    @display {label: "Worksheet ID"}
    int sheetId;
    @display {label: "Starting Row Index"}
    int startRowIndex?;
    @display {label: "Ending Row Index"}
    int endRowIndex?;
    @display {label: "Starting Column Index"}
    int startColumnIndex?;
    @display {label: "Ending Column Index"}
    int endColumnIndex?;
};

# Type of filter used to match data.
#
@display {label: "Filter"}
public type Filter A1Range|DeveloperMetadataLookupFilter|GridRangeFilter;

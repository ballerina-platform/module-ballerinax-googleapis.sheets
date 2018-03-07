package src.wso2.googlespreadsheet;

@Description {value: "Struct to define the spreadsheet."}
public struct Spreadsheet {
    string spreadsheetId;
    SpreadsheetProperties properties;
    Sheet[] sheets;
    NamedRange[] namedRanges;
    string spreadsheetUrl;
}

@Description {value: "Struct to define the named range."}
struct NamedRange {
    string namedRangeId;
    string name;
    GridRange range;
}

@Description {value: "Struct to define the spreadsheet properties."}
struct SpreadsheetProperties {
    string title;
    string locale;
    string autoRecalc;
    string timeZone;
}

@Description {value: "Struct to define the cell format."}
struct CellFormat {
    Color backgroundColor;
    Padding padding;
    string horizontalAlignment;
    string verticalAlignment;
    string wrapStrategy;
    string textDirection;
    TextFormat textFormat;
    string hyperlinkDisplayType;
}

@Description {value: "Struct to define the color."}
struct Color {
    int red;
    int green;
    int blue;
    float alpha;
}

@Description {value: "Struct to define the padding."}
struct Padding {
    int top;
    int bottom;
    int left;
    int right;
}

@Description {value: "Struct to define the text format."}
struct TextFormat {
    Color foregroundColor;
    string fontFamily;
    int fontSize;
    boolean bold;
    boolean italic;
    boolean strikethrough;
    boolean underline;
}

@Description {value: "Struct to define the sheet."}
public struct Sheet {
    string spreadsheetId;
    SheetProperties properties;
    GridData[] data;
    GridRange[] merges;
}

@Description {value: "Struct to define the sheet properties."}
struct SheetProperties {
    int sheetId;
    string title;
    int index;
    string sheetType;
    GridProperties gridProperties;
    boolean hidden;
    boolean rightToLeft;
}

@Description {value: "Struct to define the grid properties."}
struct GridProperties {
    int rowCount;
    int columnCount;
    int frozenRowCount;
    int frozenColumnCount;
    boolean hideGridlines;
}

@Description {value: "Struct to define the grid data."}
struct GridData {
    int startRow;
    int startColumn;
    RowData[] rowData;
    DimensionProperties[] rowMetadata;
    DimensionProperties[] columnMetadata;
}

@Description {value: "Struct to define the row data."}
struct RowData {
    CellData[] values;
}

@Description {value: "Struct to define the dimension properties."}
struct DimensionProperties {
    boolean hiddenByFilter;
    boolean hiddenByUser;
    int pixelSize;
}

@Description {value: "Struct to define the cell data."}
struct CellData {
    ExtendedValue userEnteredValue;
    ExtendedValue effectiveValue;
    string formattedValue;
    CellFormat userEnteredFormat;
    CellFormat effectiveFormat;
    string hyperlink;
    string note;
    TextFormatRun[] textFormatRuns;
}

@Description {value: "Struct to define the extended value."}
struct ExtendedValue {
    int numberValue;
    string stringValue;
    boolean boolValue;
    string formulaValue;
    ErrorValue errorValue;
}

@Description {value: "Struct to define the error value."}
struct ErrorValue {
    string errorType;
    string errorMessage;
}

@Description {value: "Struct to define the text format run."}
struct TextFormatRun {
    int startIndex;
    TextFormat format;
}

@Description {value: "Struct to define the grid range."}
struct GridRange {
    int sheetId;
    int startRowIndex;
    int endRowIndex;
    int startColumnIndex;
    int endColumnIndex;
}

@Description {value: "Struct to define the range."}
public struct Range {
    Sheet sheet;
    string spreadsheetId;
    string a1Notation;
    int sheetId;
}

@Description {value: "Struct to define the error."}
public struct SpreadsheetError {
    int statusCode;
    string errorMessage;
}

//Functions binded to Speadsheet struct

@Description {value : "Get the name of the spreadsheet"}
@Param {value : "spreadsheet: Spreadsheet object"}
@Return {value : "Name of the spreadsheet"}
public function <Spreadsheet spreadsheet> getSpreadsheetName() (string, SpreadsheetError) {
    SpreadsheetError spreadsheetError = {};
    string title = "";
    if (spreadsheet.properties == null) {
        spreadsheetError.errorMessage = "Spreadsheet properties cannot be null";
    } else {
        title = spreadsheet.properties.title;
    }
    return title, spreadsheetError;
}

@Description {value : "Get the name of the spreadsheet"}
@Param {value : "spreadsheet: Spreadsheet object"}
@Return {value : "Id of the spreadsheet"}
public function <Spreadsheet spreadsheet> getSpreadsheetId() (string) {
    return spreadsheet.spreadsheetId;
}

@Description {value : "Get sheet by name"}
@Param {value : "sheetName: Name of the sheet"}
@Return {value : "sheet: Sheet object"}
public function <Spreadsheet spreadsheet> getSheetByName(string sheetName) (Sheet, SpreadsheetError){
    Sheet[] sheets = spreadsheet.sheets;
    int sheetId;
    Sheet sheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    if (sheets == null) {
        spreadsheetError.errorMessage = "No sheets found";
    } else {
        foreach sheet in sheets {
            if (sheet.properties != null) {
                if (sheet.properties.title.equalsIgnoreCase(sheetName)) {
                    sheetId = sheet.properties.sheetId;
                    sheetResponse = sheet;
                    break;
                }
            }
        }
        sheetResponse.spreadsheetId = spreadsheet.spreadsheetId;
    }
    return sheetResponse, spreadsheetError;
}

//Functions binded to Sheet struct

@Description {value : "Get data range of a sheet"}
@Return {value : "range: Range object"}
public function <Sheet sheet> getDataRange() (Range) {
    Range range = {};
    range.sheet = sheet;
    range.a1Notation = sheet.properties.title;
    range.spreadsheetId = sheet.spreadsheetId;
    return range;
}

@Description {value : "Get range of a sheet"}
@Param {value: "a1Notation: The A1 notation of the range"}
@Return {value : "range: Range object"}
public function <Sheet sheet> getRange(string a1Notation) (Range){
    Range range = {};
    range.sheet = sheet;
    range.a1Notation = a1Notation;
    range.spreadsheetId = sheet.spreadsheetId;
    return range;
}

@Description {value : "Get column data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "column: The column to retrieve the values"}
@Return {value : "Column data"}
public function <Sheet sheet> getColumnData(GoogleSpreadsheetClientConnector googleSpreadsheetClientConnector,
                                            string column) (string[], SpreadsheetError){
    endpoint<GoogleSpreadsheetClientConnector> googleSpreadsheetEP {
        googleSpreadsheetClientConnector;
    }
    string a1Notation = sheet.properties.title + "!" + column + ":" + column;
    return googleSpreadsheetEP.getColumnData(sheet.spreadsheetId, a1Notation);
}

@Description {value : "Get row data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "row: The row to retrieve the values"}
@Return {value : "Row data"}
public function <Sheet sheet> getRowData(GoogleSpreadsheetClientConnector googleSpreadsheetClientConnector,
                                         string row) (string[], SpreadsheetError){
    endpoint<GoogleSpreadsheetClientConnector> googleSpreadsheetEP {
        googleSpreadsheetClientConnector;
    }
    string a1Notation = sheet.properties.title + "!" + row + ":" + row;
    return googleSpreadsheetEP.getRowData(sheet.spreadsheetId, a1Notation);
}

@Description {value : "Get cell data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "row: The row of the cell to retrieve the value"}
@Param {value: "column: The column of the cell to retrieve the value"}
@Return {value : "Cell data"}
public function <Sheet sheet> getCellData(GoogleSpreadsheetClientConnector googleSpreadsheetClientConnector,
                                         string row, string column) (string, SpreadsheetError){
    endpoint<GoogleSpreadsheetClientConnector> googleSpreadsheetEP {
        googleSpreadsheetClientConnector;
    }
    string a1Notation = sheet.properties.title + "!" + column + row;
    return googleSpreadsheetEP.getCellData(sheet.spreadsheetId, a1Notation);
}

//Functions binded to Range struct
@Description {value : "Get sheet values"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Return {value : "Sheet values"}
public function <Range range> getSheetValues(GoogleSpreadsheetClientConnector googleSpreadsheetClientConnector)
(string[][], SpreadsheetError) {
    endpoint<GoogleSpreadsheetClientConnector> googleSpreadsheetEP {
        googleSpreadsheetClientConnector;
    }
    return googleSpreadsheetEP.getSheetValues(range.spreadsheetId, range.a1Notation);
}

@Description {value : "Set cell data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "value: The value to set"}
@Return {value : "Updated range"}
public function <Range range> setValue(GoogleSpreadsheetClientConnector googleSpreadsheetClientConnector,
                                       string value) (Range, SpreadsheetError) {
    endpoint<GoogleSpreadsheetClientConnector> googleSpreadsheetEP {
        googleSpreadsheetClientConnector;
    }
    return googleSpreadsheetEP.setValue(range.spreadsheetId, range.a1Notation, value);
}
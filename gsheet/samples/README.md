# Ballerina Google Sheets Connector Samples:

## Spreadsheet Management Operations
The Google Spreadsheet Ballerina Connector allows you to access the Google Spreadsheet API Version v4 through Ballerina to handle spreadsheet management operations like creating a spreadsheet, opening a spreadsheet, listing all the spreadsheets available in a user account, renaming a spreadsheet.

### Create Spreadsheet
This section shows how to use the Google Spreadsheet ballerina connector to create a new spreadsheet. We must specify the spreadsheet name as a string parameter to the createSpreadsheet remote operation. This is the basic scenario of creating a new spreadsheet with the name “NewSpreadsheet”. It returns a Spreadsheet record type with all the information related to the spreadsheet created on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/createSpreadsheet.bal

### Open Spreadsheet by Spreadsheet ID
This section shows how to use the Google Spreadsheet ballerina connector to open a spreadsheet by spreadsheet ID. We must specify the spreadsheet ID as a string parameter to the openSpreadsheetById remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=0". This is the basic scenario of opening a spreadsheet with the spreadsheet ID obtained when creating a new spreadsheet. It returns a Spreadsheet record type with all the information related to the spreadsheet opened on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/openSpreadsheetById.bal

### Open Spreadsheet by Spreadsheet URL
This section shows how to use the Google Spreadsheet ballerina connector to open a spreadsheet by spreadsheet URL. We must specify the spreadsheet ID as a string parameter to the openSpreadsheetByUrl remote operation. Spreadsheet URL is in the following format "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of opening a spreadsheet with the spreadsheet URL obtained when creating a new spreadsheet. It returns a Spreadsheet record type with all the information related to the spreadsheet opened on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/openSpreadsheetByUrl.bal

### Rename Spreadsheet
This section shows how to use the Google Spreadsheet ballerina connector to rename a spreadsheet with a given name by spreadsheet ID. We must specify the spreadsheet ID and the new name for the spreadsheet as string parameters to the renameSpreadsheet remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=0". This is the basic scenario of renaming a spreadsheet  with the name “RenamedSpreadsheet” by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/renameSpreadsheet.bal

### Get All Spreadsheets
This section shows how to use the Google Spreadsheet ballerina connector to get all the spreadsheets associated with the user account. This is the basic scenario of getting all the  spreadsheets in the user account. It returns a Stream of File record type with all the information related to the spreadsheets on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/getAllSpreadsheets.bal

## Worksheet Management Operations
The Google Spreadsheet Ballerina Connector allows you to access the Google Spreadsheet API Version v4 through Ballerina to handle worksheet management operations like getting all the worksheets available in a spreadsheet, opening a worksheet, adding a new worksheet, removing a worksheet and renaming a worksheet.

### Add Worksheet
This section shows how to use the Google Spreadsheet ballerina connector to add a new worksheet with given name to the spreadsheet with the given spreadsheet ID. We must specify the spreadsheet ID and the name for the new worksheet as string parameters to the addSheet remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of adding a new worksheet  with the name “NewWorksheet” by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns a Sheet record type with all the information related to the worksheet added on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/addSheet.bal

### Get Worksheet by Name
This section shows how to use the Google Spreadsheet ballerina connector to Get Worksheet with given name from the Spreadsheet with the given Spreadsheet ID. We must specify the spreadsheet ID and the name of the required worksheet as string parameters to the getSheetByName remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of getting a worksheet  with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns a Sheet record type with all the information related to the worksheet opened on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/getSheetByName.bal

### Rename Worksheet 
This section shows how to use the Google Spreadsheet ballerina connector to Rename Worksheet with given name from the Spreadsheet with the given Spreadsheet ID and Worksheet Name. We must specify the spreadsheet ID, the name of the required worksheet and the new name of the worksheet as string parameters to the renameSheet remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of renaming a worksheet with the name “RenamedWorksheet” from the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/renameSheet.bal

### Remove Worksheet by Worksheet ID
This section shows how to use the Google Spreadsheet ballerina connector to Remove Worksheet with given ID from the Spreadsheet with the given Spreadsheet ID. We must specify the spreadsheet ID as a string parameter and the ID of the required worksheet to be removed as an integer parameter to the removeSheet remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of removing a worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/removeSheetById.bal

### Remove Worksheet by Worksheet Name
This section shows how to use the Google Spreadsheet ballerina connector to Remove Worksheet with given name from the Spreadsheet with the given Spreadsheet ID. We must specify the spreadsheet ID as a string parameter and the name of the required worksheet to be removed as string parameter to the removeSheetByName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of removing a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/removeSheetByName.bal

### Get All Worksheets
This section shows how to use the Google Spreadsheet ballerina connector to Get All Worksheets in the Spreadsheet with the given Spreadsheet ID . We must specify the spreadsheet ID as a string parameter to the getSheets remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of getting all the worksheets of a spreadsheet by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns an array of Sheet record type with all the information related to the worksheets on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/getSheets.bal

## Worksheet Service Operations
The Google Spreadsheet Ballerina Connector allows you to access the Google Spreadsheet API Version v4 through Ballerina to handle data level operations like setting, getting and clearing a range of data, inserting columns/rows before and after a given position, creating or updating, getting and deleting columns/rows, setting, getting and clearing cell data, appending a row to a sheet, appending a row to a range of data, appending a cell to a range of data, copying a worksheet to a destination spreadsheet, and clearing worksheets.

### Get, Set and Clear Range
This section shows how to use the Google Spreadsheet ballerina connector to handle data level operations at a given range. We can set, get and clear the values of the given range of cells of the Worksheet with given Name from the Spreadsheet with the given Spreadsheet ID. 

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/range.bal

#### Get Range
To set the values of the given range of cells of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the range specified as a Range Record type that includes the A1 notation and values in the range, to the setRange remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of setting the values of the given range of cells of a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Set Range
To get the values of the given range of cells of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the range specified in A1 notation, to the getRange remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of getting the values of the given range of cells of a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns a Range Record type that includes the A1 notation and values in the range, on success and a ballerina error if the operation is unsuccessful.

#### Clear Range
To clear the values of the given range of cells of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the range specified in A1 notation, to the clearRange remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of clearing the values of the given range of cells of a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.


### Column Operations
This section shows how to use the Google Spreadsheet ballerina connector to handle data level operations column wise. We can insert columns before and after a given position, create or update, get column values of the given column position, delete columns starting at the given column position of the Worksheet with given ID/Name from the Spreadsheet with the given Spreadsheet ID. 

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/column.bal

#### Add Columns Before by Worksheet ID
To Insert the given number of columns before the given column position in a Worksheet with given ID, we must specify the spreadsheet ID as a string parameter, the ID of the required worksheet, position of the column before which the new columns should be added, number of columns to be added as integer parameters, to the addColumnsBefore remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of columns before the given column position of a worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Add Column Before by Worksheet Name
To Insert the given number of columns before the given column position in a Worksheet with given Name, we must specify the spreadsheet ID as a string parameter, the Name of the required worksheet as a string parameter, position of the column before which the new columns should be added, number of columns to be added as integer parameters, to the addColumnsBeforeBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of columns before the given column position of a worksheet with the Name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Add Column After by Worksheet ID
To Insert the given number of columns after the given column position in a Worksheet with given ID, we must specify the spreadsheet ID as a string parameter, the ID of the required worksheet, position of the column after which the new columns should be added, number of columns to be added as integer parameters, to the addColumnsAfter remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of columns after the given column position of a worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Add Column After by Worksheet Name
To Insert the given number of columns after the given column position in a Worksheet with given Name, we must specify the spreadsheet ID as a string parameter, the Name of the required worksheet as a string parameter, position of the column after which the new columns should be added, number of columns to be added as integer parameters, to the addColumnsAfterBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of columns after the given column position of a worksheet with the Name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Create or Update Column
To create or update the given column position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter, the column position as a string in A1 notation and values as an array of (int|string|float), to the createOrUpdateColumn remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of creating or updating the given column position of the Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Get Column
To get values of the given column position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the column position as a string in A1 notation, to the getColumn remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of getting the values of the given column position of the Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns values as an array of (int|string|float), on success and a ballerina error if the operation is unsuccessful.

#### Delete Columns by Worksheet ID
To delete columns starting at the given column position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the ID of the required worksheet as a string parameter and the column position as a string in A1 notation, to the deleteColumns remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of deleting columns starting at the given column position of the Worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Delete Columns by Worksheet Name
To delete columns starting at the given column position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the column position as a string in A1 notation, to the deleteColumnsBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of deleting columns starting at the given column position of the Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.


### Row Operations
This section shows how to use the Google Spreadsheet ballerina connector to handle data level operations row wise. We can insert rows before and after a given position, create or update, get row values of the given row position, delete rows starting at the given row position of the Worksheet with given ID/Name from the Spreadsheet with the given Spreadsheet ID. 

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/rows.bal

#### Add Rows Before by Worksheet ID
To Insert the given number of rows before the given row position in a Worksheet with given ID, we must specify the spreadsheet ID as a string parameter, the ID of the required worksheet, position of the row before which the new rows should be added, number of rows to be added as integer parameters, to the addRowsBefore remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of rows before the given row position of a worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Add Rows Before by Worksheet Name
To Insert the given number of rows before the given row position in a Worksheet with given Name, we must specify the spreadsheet ID as a string parameter, the Name of the required worksheet as a string parameter, position of the row before which the new rows should be added, number of rows to be added as integer parameters, to the addRowsBeforeBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of rows before the given row position of a worksheet with the Name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Add Rows After by Worksheet ID
To Insert the given number of rows after the given row position in a Worksheet with given ID, we must specify the spreadsheet ID as a string parameter, the ID of the required worksheet, position of the row after which the new rows should be added, number of rows to be added as integer parameters, to the addRowsAfter remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of rows after the given row position of a worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Add Rows After by Worksheet Name
To Insert the given number of rows after the given row position in a Worksheet with given Name, we must specify the spreadsheet ID as a string parameter, the Name of the required worksheet as a string parameter, position of the row after which the new rows should be added, number of rows to be added as integer parameters, to the addRowsAfterBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of inserting the given number of rows after the given row position of a worksheet with the Name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Create or Update Row
To create or update the given row position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter, the row position as a string in A1 notation and values as an array of (int|string|float), to the createOrUpdateRow remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of creating or updating the given row position of the Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Get Row
To get values of the given row position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the row position as a string in A1 notation, to the getRow remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of getting the values of the given row position of the Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns values as an array of (int|string|float), on success and a ballerina error if the operation is unsuccessful.

#### Delete Rows by Worksheet ID
To delete rows starting at the given row position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the ID of the required worksheet as a string parameter and the row position as a string in A1 notation, to the deleteRows remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of deleting rows starting at the given row position of the Worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Delete Rows by Worksheet Name
To delete rows starting at the given row position of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the row position as a string in A1 notation, to the deleteRowsBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of deleting rows starting at the given column position of the Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

### Get, Set and Clear Cell
This section shows how to use the Google Spreadsheet ballerina connector to handle data level operations at a given cell. We can set, get and clear the value of the given cell of the Worksheet with given Name from the Spreadsheet with the given Spreadsheet ID. 

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/cell.bal

#### Set Cell
To set the value of the given cell of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the range specified as a string in A1 notation and value of the cell to be set, to the setCell remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of setting the value of the given cell with “ModifiedValue” of a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

#### Get Cell
To get the value of the given cell of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the range as a string in A1 notation, to the getCell remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of getting the value of the given cell of a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns a (int|string|float) value, on success and a ballerina error if the operation is unsuccessful.

#### Clear Cell
To clear the value of the given cell of the Worksheet, we must specify the spreadsheet ID as a string parameter, the name of the required worksheet as a string parameter and the range specified as a string in A1 notation, to the clearCell remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of clearing the value of the given cell of a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.


### Append Row to Sheet
This section shows how to use the Google Spreadsheet ballerina connector Append a new row with the given values to the bottom in a Worksheet with given name to the spreadsheet with the given spreadsheet ID. We must specify the spreadsheet ID and the name for the new worksheet as string parameters and row values as an array of (int|string|decimal), to the appendRowToSheet remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of appending a new row with the given values to the bottom in a Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful. 

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/appendRowToSheet.bal

### Append Row to Range
This section shows how to use the Google Spreadsheet ballerina connector Append a new row with the given values to the bottom of the range in a Worksheet with given name to the spreadsheet with the given spreadsheet ID. The input range is used to search for existing data and find a "table" within that range. Values are appended to the next row of the table, starting with the first column of the table. More information can be found here. We must specify the spreadsheet ID and the name for the new worksheet as string parameters, range as a string in A1 notation and row values as an array of (int|string|float), to the appendRow remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of appending a new row with the given values to the bottom of the range in a Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/appendRowToRange.bal

### Append Cell to Range
This section shows how to use the Google Spreadsheet ballerina connector Append a new cell with the given value to the bottom of the range in a Worksheet with given name to the spreadsheet with the given spreadsheet ID. The input range is used to search for existing data and find a "table" within that range. Cell value is appended to the next row of the table, starting with the first column of the table. More information can be found here. We must specify the spreadsheet ID and the name for the new worksheet as string parameters, range as a string in A1 notation and cell value as (int|string|float), to the appendCell remote operation. Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of appending a new cell with the given value to the bottom of the range in a Worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/appendCellToRange.bal

### Copy Worksheet by Worksheet ID
This section shows how to use the Google Spreadsheet ballerina connector to Copy the Worksheet with a given ID from a source Spreadsheet with a given Spreadsheet ID to a destination Spreadsheet with a given Spreadsheet ID. We must specify the source spreadsheet ID as a string parameter, the ID of the required worksheet to be copied as an integer parameter and destination spreadsheet ID as a string parameter, to the copyTo remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of copying a worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/copyToById.bal

### Copy Worksheet by Worksheet Name
This section shows how to use the Google Spreadsheet ballerina connector to Copy the Worksheet with a given name from a source Spreadsheet with a given Spreadsheet ID to a destination Spreadsheet with a given Spreadsheet ID. We must specify the source spreadsheet ID as a string parameter, the Name of the required worksheet to be copied as a string parameter and destination spreadsheet ID as a string parameter, to the copyToBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of copying a worksheet with the name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/copyToByName.bal

### Clear All by Worksheet ID
This section shows how to use the Google Spreadsheet ballerina connector to clear the Worksheet with a given ID from a Spreadsheet with a given Spreadsheet ID. We must specify the spreadsheet ID as a string parameter, the ID of the required worksheet to be cleared as an integer parameter, to the clearAll remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of clearing a worksheet with the ID obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/clearAllById.bal

### Clear All by Worksheet Name
This section shows how to use the Google Spreadsheet ballerina connector to clear the Worksheet with a given name from a Spreadsheet with a given Spreadsheet ID. We must specify the spreadsheet ID as a string parameter, the name of the required worksheet to be cleared as a string parameter, to the clearAllBySheetName remote operation. Spreadsheet ID and Worksheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <spreadsheetId> + "/edit#gid=" + <sheetId>. This is the basic scenario of clearing a worksheet with the Name obtained when creating a new worksheet and by the spreadsheet ID which is obtained when creating a new spreadsheet. It returns Nil on success and a ballerina error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/blob/master/gsheet/samples/clearAllByName.bal

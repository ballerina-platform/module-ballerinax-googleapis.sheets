// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

# Defines the generic error type for the `googleapis.sheets` module.
public type Error distinct error;

# Error that occurs when a spreadsheet or sheet operation fails. This could be due to the resource not being found,
# insufficient permissions, or an API-level rejection.
public type SpreadsheetError distinct Error;

# Error that occurs when an invalid cell range is provided. This could be due to malformed A1 notation or a range
# that falls outside the bounds of the sheet.
public type InvalidRangeError distinct Error;

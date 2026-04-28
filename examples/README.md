# Examples

The `Google Sheets` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples), covering real-world use cases like expense tracking, grade reporting, sales aggregation, and inventory management.

1. [Expense Tracker](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples/expense-tracker) - Append monthly expense records to a sheet, aggregate totals by category, and write a summary report.

2. [Student Grade Report](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples/student-grade-report) - Read student scores, compute averages and letter grades, and generate a formatted grade report sheet.

3. [Sales Data Aggregation](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples/sales-data-aggregation) - Write regional sales data across multiple sheets, aggregate totals by product, and produce a consolidated summary.

4. [Inventory Stock Update](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples/inventory-stock-update) - Load current inventory levels, apply stock changes in place, and flag items that fall below their reorder threshold.

## Prerequisites

1. Follow the [instructions](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets#setup-guide) to set up the Sheets API.

2. For each example, create a `Config.toml` file in the example directory with your OAuth2 credentials:

    ```toml
    refreshToken="<Refresh Token>"
    clientId="<Client Id>"
    clientSecret="<Client Secret>"
    ```

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the Examples with the Local Module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```

# Examples

The `Google Sheets` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples), covering use cases like creating, reading, and appending rows.

1. [Cell Operations](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples/cell-operations) - Operations associated with a cell, such as clearing, setting, and deleting cell values.

2. [Grid Filtering](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples/grid-filtering) - Demonstrate filtering sheet values using a grid range.

3. [Sheet Modifying](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples/sheet-modifying) - Basic operations associated with sheets such as creating, reading, and appending rows.

## Prerequisites

1. Follow the [instructions](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets#setup-guide) to set up the Sheets API.

2. For each example, create a `config.toml` file with your OAuth2 tokens, client ID, and client secret. Here's an example of how your `config.toml` file should look:

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

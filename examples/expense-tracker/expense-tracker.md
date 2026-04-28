# Expense tracker

This example demonstrates how to use the Google Sheets connector to track monthly expenses. It appends expense records to a sheet, aggregates totals by category, and writes a summary report to a separate sheet.

## Prerequisites

### 1. Setup Sheets API

Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/googleapis.sheets/latest#setup-guide) for necessary credentials (client ID, secret, tokens).

### 2. Configuration

Configure Google Sheets API credentials in `Config.toml` in the example directory:

```toml
refreshToken="<Refresh Token>"
clientId="<Client Id>"
clientSecret="<Client Secret>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```

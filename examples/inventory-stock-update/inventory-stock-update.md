# Inventory stock update

This example demonstrates how to use the Google Sheets connector to manage inventory. It loads the current stock levels into a sheet, applies incoming quantity changes, updates each item's count in place, and flags items that fall below their reorder threshold.

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

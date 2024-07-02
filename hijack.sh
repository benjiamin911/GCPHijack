#!/bin/bash

read -p "credentials.db path:" CREDENTIALS_DB_PATH

if ! command -v gcloud &> /dev/null; then
    echo "Did not found gcloud, please install gcloud。"
    exit 1
fi

if [ ! -f "$CREDENTIALS_DB_PATH" ]; then
    echo "Cannot find credentials.db file，Please check：$CREDENTIALS_DB_PATH"
    exit 1
fi

GCLOUD_CONFIG_DIR="$HOME/.config/gcloud"

# Backup currently identity
if [ -d "$GCLOUD_CONFIG_DIR" ]; then
    mv "$GCLOUD_CONFIG_DIR" "${GCLOUD_CONFIG_DIR}_backup_$(date +%Y%m%d%H%M%S)"
fi

mkdir -p "$GCLOUD_CONFIG_DIR"

cp "$CREDENTIALS_DB_PATH" "$GCLOUD_CONFIG_DIR/credentials.db"

ACCOUNT=$(sqlite3 "$GCLOUD_CONFIG_DIR/credentials.db" "SELECT account_id FROM credentials;")

# Update the .boto
GCLOUD_LEGACY_DIR="$GCLOUD_CONFIG_DIR/legacy_credentials/$ACCOUNT/"
mkdir -p "$GCLOUD_LEGACY_DIR"
BOTO_CONTENT=$(sqlite3 "$GCLOUD_CONFIG_DIR/credentials.db" "SELECT value FROM credentials;" | jq -r '.| "[OAuth2]\r\nclient_id=\(.client_id)\r\nclient_secret=\(.client_secret)\r\n\r\n[Credentials]\r\ngs_oauth2_refresh_token=\(.refresh_token)"')
echo $BOTO_CONTENT > $GCLOUD_LEGACY_DIR/.boto

# Update adc.json
ADC_CONTENT=$(sqlite3 "$GCLOUD_CONFIG_DIR/credentials.db" "SELECT value FROM credentials;" | jq -r '.| del(.scopes) | del(.revoke_uri) | del(.token_uri) |. += {"account": ""}')
echo $ADC_CONTENT > $GCLOUD_LEGACY_DIR/ADC.json

mkdir -p "$GCLOUD_CONFIG_DIR/configurations"

read -p "default project:" PROJECT

gcloud config set account "$ACCOUNT"
gcloud config set project "$PROJECT"

echo "Successfully replace as new identity, can check with <gcloud config list/gcloud projects list> command"
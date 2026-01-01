#!/bin/bash

# Git Push Helper Script
# Dieses Script liest die Credentials aus git_credentials.txt und führt den Push durch

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_FILE="$SCRIPT_DIR/git_credentials.txt"

# Check if credentials file exists
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "❌ Fehler: git_credentials.txt nicht gefunden!"
    echo "Bitte erstellen Sie die Datei mit Ihren GitHub-Zugangsdaten."
    exit 1
fi

# Read credentials
echo "📖 Lese Zugangsdaten aus git_credentials.txt..."

# Extract username and token
GITHUB_USERNAME=$(grep "^GITHUB_USERNAME=" "$CREDENTIALS_FILE" | cut -d'=' -f2)
GITHUB_TOKEN=$(grep "^GITHUB_TOKEN=" "$CREDENTIALS_FILE" | cut -d'=' -f2)

# Validate credentials
if [ -z "$GITHUB_USERNAME" ] || [ "$GITHUB_USERNAME" = "Kujoh1" ]; then
    echo "✅ Username: $GITHUB_USERNAME"
else
    echo "❌ Fehler: GITHUB_USERNAME nicht konfiguriert!"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "YOUR_TOKEN_HERE" ]; then
    echo "❌ Fehler: GITHUB_TOKEN nicht konfiguriert!"
    echo "Bitte tragen Sie Ihr Personal Access Token in git_credentials.txt ein."
    exit 1
fi

echo "✅ Token gefunden (${#GITHUB_TOKEN} Zeichen)"

# Perform git push with credentials
echo "🚀 Führe git push durch..."

# Use git credential helper to avoid password prompt
git config --local credential.helper store

# Create temporary credentials
echo "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com" > ~/.git-credentials

# Push to remote
git push origin main || git push origin master

# Clean up credentials
rm -f ~/.git-credentials
git config --local --unset credential.helper

echo "✅ Git push erfolgreich abgeschlossen!"
echo "🎉 Alle Änderungen wurden zu GitHub hochgeladen!"

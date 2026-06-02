#!/usr/bin/env bash
# "All Boats Rise" - AI Guidelines Installer

REPO_URL="https://raw.githubusercontent.com/roberthamiltoncoach/ai-development-manifesto/main"
TARGET_FILE="AI_PROJECT_GUIDELINES.md"

echo "⛵ 'All Boats Rise' Setup"
echo "Fetching latest AI Development Guidelines..."

# Download the latest manifesto
curl -fsSL "$REPO_URL/AI_GUIDELINES.md" -o "$TARGET_FILE"

if [ $? -eq 0 ]; then
  echo "✅ Successfully synced guidelines to ./$TARGET_FILE"
  echo "👉 Commit this file to your repository so your AI agents have the correct instructions!"
else
  echo "❌ Failed to download guidelines. Please check your internet connection."
  exit 1
fi

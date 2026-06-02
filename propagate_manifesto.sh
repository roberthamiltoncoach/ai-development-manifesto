#!/usr/bin/env bash
# ==============================================================================
# ⛵ AI Development Manifesto Propagation & Synchronization Automation
# ==============================================================================
# Scans your project directory, copies the latest guidelines as AI_PROJECT_GUIDELINES.md,
# and automatically commits the update in every active Git repository.
# ==============================================================================

MANIFESTO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTER_FILE="$MANIFESTO_DIR/AI_GUIDELINES.md"
DEV_DIR="/Users/roberthamilton/AntiGravityDev"

echo "⛵ Starting propagation of AI Manifesto..."
echo "Master Source: $MASTER_FILE"
echo "Target Parent: $DEV_DIR"
echo "--------------------------------------------------"

if [ ! -f "$MASTER_FILE" ]; then
    echo "❌ Error: Master file not found at $MASTER_FILE"
    exit 1
fi

# Find all subdirectories in the active development folder
find "$DEV_DIR" -maxdepth 1 -mindepth 1 -type d | while read -r project_path; do
    project_name=$(basename "$project_path")
    
    # Check if the subdirectory is a Git repository
    if [ -d "$project_path/.git" ]; then
        echo "📁 Syncing repository: $project_name"
        target_path="$project_path/AI_PROJECT_GUIDELINES.md"
        
        # Copy the master guidelines file
        cp "$MASTER_FILE" "$target_path"
        
        # Navigate to the project directory and handle Git staging/committing
        cd "$project_path" || continue
        
        # Check if there are changes to stage
        if [ -n "$(git status --porcelain AI_PROJECT_GUIDELINES.md)" ]; then
            echo "   📝 Changes detected. Auto-committing in $project_name..."
            git add AI_PROJECT_GUIDELINES.md
            git commit -m "chore: sync latest AI guidelines from centralized manifesto"
            echo "   ✅ Sync committed successfully!"
        else
            echo "   ⏭️ Already up-to-date. Skipping commit."
        fi
        
        # Return to manifesto dir
        cd "$MANIFESTO_DIR" || exit
    fi
done

echo "--------------------------------------------------"
echo "🎉 Propagation completed successfully across all repositories!"

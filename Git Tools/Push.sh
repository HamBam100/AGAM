#!/bin/bash
echo "Running sync (pushing to GitHub)..."

# Change to the directory this script is in
cd "$(dirname "$0")/.."


# Ensure this is a git repo
if [ ! -d ".git" ]; then
    echo
    echo "Error: Not a git repository."
    exit 1
fi

# Prompt for a commit message
read -rp "Enter commit message (default: Auto push from Git Push script): " commitmsg

# Use default if empty
if [ -z "$commitmsg" ]; then
    commitmsg="Auto push from Push.sh"
fi

echo "Commit message: \"$commitmsg\""


echo
echo "=== Staging, committing, and pushing ==="
echo

# Add all changes, commit, and push
git add --all
git status
git commit -m "$commitmsg"
git branch -M main
git push origin main

echo
echo "Push complete!
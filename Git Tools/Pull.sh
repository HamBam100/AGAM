#!/bin/bash
echo "Running sync (pulling from GitHub)..."

cd "$(dirname "$0")/.."

# Ensure this is a git repo
if [ ! -d ".git" ]; then
    echo
    echo "Error: Not a git repository."
    exit 1

fi

git fetch origin
git pull origin main

echo
echo "Pull complete!"

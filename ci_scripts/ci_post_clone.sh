#!/bin/bash
#
# ci_post_clone.sh — Xcode Cloud post-clone hook
#
# Xcode Cloud runs this after cloning the repo but before resolving
# dependencies or building. Since .xcodeproj is gitignored (XcodeGen
# generates it from project.yml), we install XcodeGen and generate
# the project here so Xcode Cloud can find it.
#

set -euo pipefail

echo "=== Xcode Cloud: ci_post_clone.sh ==="
echo "Repository path: ${CI_PRIMARY_REPOSITORY_PATH}"

# Install XcodeGen via Homebrew (pre-installed on Xcode Cloud images)
echo "Installing XcodeGen..."
brew install xcodegen

# Generate the Xcode project from project.yml
cd "${CI_PRIMARY_REPOSITORY_PATH}"
echo "Generating Xcode project..."
xcodegen generate

# Verify the project was created
if [ -d "MLBValueBets.xcodeproj" ]; then
    echo "MLBValueBets.xcodeproj generated successfully"
    ls -la MLBValueBets.xcodeproj/
else
    echo "ERROR: Failed to generate MLBValueBets.xcodeproj"
    exit 1
fi

echo "=== ci_post_clone.sh complete ==="

#!/usr/bin/env bash

# Authenticate GitHub CLI
gh auth login --with-token <<< $GH_PAT

# Get the GitHub username
username=$(gh api user --jq '.login')
echo "Current GitHub user: $username"

# Get a list of forked repositories
repos=$(gh repo list "$username" --json nameWithOwner,isFork -q '.[] | select(.isFork) | .nameWithOwner')

# Process each repository correctly
echo "$repos" | while IFS= read -r repo; do
    repo=$(echo "$repo" | xargs) # Trim spaces

    # Skip empty lines
    if [[ -z "$repo" ]]; then 
        continue; 
    fi 

    echo "Checking repository: $repo"

    # Get the upstream repository name and owner
    upstream_repo=$(gh api "repos/$repo" --jq '.parent.full_name' 2>/dev/null || echo "")
    upstream_repo_owner=$(echo "$upstream_repo" | cut -d'/' -f1)

    if [ -z "$upstream_repo" ]; then
        echo "Skipping: $repo - No upstream found"
        continue
    fi

    # Get the default branch for the forked repository
    fork_default_branch=$(gh api "repos/$repo" --jq '.default_branch' 2>/dev/null || echo "")

    # Get the default branch for the upstream repository
    upstream_default_branch=$(gh api "repos/$upstream_repo" --jq '.default_branch' 2>/dev/null || echo "")

    if [ -z "$fork_default_branch" ] || [ -z "$upstream_default_branch" ]; then
        echo "Skipping: $repo - Could not determine default branch"
        continue
    fi

    # Compare the fork and upstream repository using the default branches
    fork_ahead_count=$(gh api "repos/$repo/compare/$upstream_repo_owner:$upstream_default_branch...$username:$fork_default_branch" --jq '.ahead_by' 2>/dev/null || echo "0")

    # Skip if the fork has additional commits
    if [ "$fork_ahead_count" -gt 0 ]; then
        echo "Skipping: $repo - Has additional commits ($fork_ahead_count ahead of upstream)"
        continue
    fi

    # Sync the fork
    echo "Syncing: $repo"
    gh repo sync "$repo"
done

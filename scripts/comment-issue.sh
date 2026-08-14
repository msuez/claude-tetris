#!/usr/bin/env bash
#
# Posts a comment on a GitHub issue from a markdown file.
# Usage: ./scripts/comment-issue.sh <path-to-markdown-file>
#
# The issue number is read from the workflow event payload, not from an argument,
# so this script can never be pointed at an issue other than the one that triggered the run.
#

set -euo pipefail

BODY_FILE="${1:?usage: comment-issue.sh <file>}"
if [[ ! -f "$BODY_FILE" ]]; then
  echo "Error: file not found: $BODY_FILE" >&2
  exit 1
fi

ISSUE=$(jq -r '.issue.number // empty' "${GITHUB_EVENT_PATH:?GITHUB_EVENT_PATH not set}")
if ! [[ "$ISSUE" =~ ^[0-9]+$ ]]; then
  echo "Error: no issue number in event payload" >&2
  exit 1
fi

REPO="${GH_REPO:-${GITHUB_REPOSITORY:?GH_REPO or GITHUB_REPOSITORY must be set}}"
export GH_REPO="$REPO"

gh issue comment "$ISSUE" --body-file "$BODY_FILE"

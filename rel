#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Minimal rel script for your flow
# Implements:
#   MASTER=main ./rel version pre
#
# Behavior:
# - Reads base version from ./VERSION (e.g., 0.6.0)
# - Creates/bumps pre-release tag:   0.6.0-pre.N
# - Creates matching branch name:    0.6.0-pre.N    (per your notes)
# - Pushes tag and branch to origin
#
# Notes:
# - MASTER defaults to 'main' (override via env)
# - Origin defaults to 'origin' (override via ORIGIN)
# - No publish/build here; just Git ops
# ------------------------------------------------------------

MASTER="${MASTER:-main}"
ORIGIN="${ORIGIN:-origin}"

die() { echo "ERROR: $*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage:
  MASTER=main ./rel version pre

Optional env:
  MASTER=main            # branch considered mainline (default: main)
  ORIGIN=origin          # remote (default: origin)
EOF
}

# --- helpers ---
require_git_clean() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    die "Working tree not clean. Commit or stash changes before running rel."
  fi
}

require_branch() {
  local b="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$b" != "$MASTER" ]; then
    echo "INFO: switching to $MASTER"
    git checkout "$MASTER"
  fi
  git pull --ff-only "$ORIGIN" "$MASTER"
}

read_version_file() {
  [ -f VERSION ] || die "VERSION file not found at repo root."
  local v
  v="$(tr -d ' \t\r\n' < VERSION)"
  [ -n "$v" ] || die "VERSION file is empty."
  echo "$v"
}

next_pre_tag() {
  local base="$1"            # e.g., 0.6.0
  local last
  last="$(git tag --list "${base}-pre.*" | sort -V | tail -n1 || true)"
  if [ -n "$last" ]; then
    # extract N from ...-pre.N
    local n; n="$(sed -n 's/^.*-pre\.\([0-9]\+\)$/\1/p' <<<"$last")"
    [ -n "$n" ] || n="0"
    echo "${base}-pre.$((n+1))"
  else
    echo "${base}-pre.0"
  fi
}

cmd_version_pre() {
  require_git_clean
  require_branch

  local base ver
  ver="$(read_version_file)"       # may contain suffix; we only want base
  base="${ver%%-pre.*}"            # strip any -pre.* if present
  base="${base%%-rc.*}"            # strip any -rc.* if present

  local tag branch
  tag="$(next_pre_tag "$base")"    # e.g., 0.6.0-pre.0
  branch="$tag"                    # per your instruction: branch name equals tag

  # If tag already exists, just exit gracefully
  if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
    echo "Tag ${tag} already exists. Nothing to do."
    exit 0
  fi

  echo "Creating pre-release tag:   $tag"
  echo "Creating pre-release branch: $branch"

  # create annotated tag at current HEAD of $MASTER
  git tag -a "$tag" -m "pre-release $tag"

  # create branch if it doesn't already exist
  if ! git rev-parse -q --verify "refs/heads/${branch}" >/dev/null; then
    git branch "$branch"
  else
    echo "Branch ${branch} already exists."
  fi

  # push both
  git push "$ORIGIN" "refs/tags/${tag}"
  git push "$ORIGIN" "$branch"

  echo "Done. Pushed tag ${tag} and branch ${branch}."
}

# --- main ---
[ $# -ge 2 ] || { usage; die "Insufficient arguments"; }

case "$1 $2" in
  "version pre") cmd_version_pre ;;
  *)
    usage
    die "Unsupported command '$1 $2'. Implemented: 'version pre'"
    ;;
esac
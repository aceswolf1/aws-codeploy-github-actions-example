#!/usr/bin/env bash

THIS_ABSPATH="$(cd "$(dirname "$0")"; pwd)"

TYPES=${TYPES:-nodejs}

REF=${REF:-master}
get() {
  curl -s -o $1 https://raw.githubusercontent.com/frontedgedigital/release-management/$REF/$1 && chmod +x $1
}

get release
for it in $TYPES; do
    get release-$it
done
get tag-nodejs

export HUSKY_SKIP_HOOKS=1
export GIT_COMMIT_OPTS=--no-verify
export GIT_PUSH_OPTS=--no-verify

./release $(echo -n "$TYPES" | tr ' ' '+') $@

#!/usr/bin/env bash

set -euo pipefail

log() {
    printf '%s\n' "$*" >&2
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
KIT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
REPO_ROOT=${BACKEND_AGENT_KIT_REPO_ROOT:-$(CDPATH= cd -- "$KIT_ROOT/../.." && pwd)}
REPO_ROOT=$(CDPATH= cd -- "$REPO_ROOT" && pwd)

SYNC_SCRIPT="$KIT_ROOT/scripts/sync-to-github.sh"
SUBMODULE_PATH="tools/backend-agent-kit"

if [ ! -f "$SYNC_SCRIPT" ]; then
    log "skip auto-sync: sync script not found at $SYNC_SCRIPT"
    exit 0
fi

if ! git -C "$REPO_ROOT" rev-parse --show-toplevel >/dev/null 2>&1; then
    log "skip auto-sync: consumer repo not found at $REPO_ROOT"
    exit 0
fi

if [ ! -e "$REPO_ROOT/$SUBMODULE_PATH" ]; then
    log "skip auto-sync: expected submodule path $SUBMODULE_PATH not found in consumer repo"
    exit 0
fi

if [ "$(CDPATH= cd -- "$REPO_ROOT/$SUBMODULE_PATH" && pwd)" != "$KIT_ROOT" ]; then
    log "skip auto-sync: current backend-agent-kit path does not match $SUBMODULE_PATH in consumer repo"
    exit 0
fi

if [ -n "$(git -C "$REPO_ROOT" diff --cached --name-only)" ]; then
    log "skip auto-sync: consumer index already contains staged changes"
    exit 0
fi

if [ -n "$(git -C "$REPO_ROOT" status --porcelain -- .github)" ]; then
    log "skip auto-sync: .github already has local changes, sync commit must be created manually"
    exit 0
fi

"$SYNC_SCRIPT" --repo-root "$REPO_ROOT"

git -C "$REPO_ROOT" add .github "$SUBMODULE_PATH"

if git -C "$REPO_ROOT" diff --cached --quiet -- .github "$SUBMODULE_PATH"; then
    log "auto-sync: no consumer changes detected after sync"
    exit 0
fi

source_commit_sha=$(git -C "$KIT_ROOT" rev-parse --short HEAD)
source_commit_subject=$(git -C "$KIT_ROOT" log -1 --format=%s)

BACKEND_AGENT_KIT_SKIP_POST_COMMIT_SYNC=1 git -C "$REPO_ROOT" commit \
    -m "chore(copilot): синхронизировать .github после обновления backend-agent-kit" \
    -m "- выполнить sync shared-артефактов из tools/backend-agent-kit
- обновить managed .github paths и manifest
- обновить указатель submodule tools/backend-agent-kit
- source commit: $source_commit_sha $source_commit_subject"

log "auto-sync: created consumer commit for backend-agent-kit commit $source_commit_sha"
#!/usr/bin/env bash

set -euo pipefail

print_usage() {
    cat <<'EOF'
Usage:
  sync-to-github.sh [--repo-root PATH] [--dry-run] [--validate-only]
  sync-to-github.sh [--repo-root PATH] --clean-managed [--dry-run]

Options:
  --repo-root PATH   Path to the consumer repository root. Defaults to current directory.
  --dry-run          Print planned actions without writing changes.
  --validate-only    Exit with code 1 when drift is detected. Implies --dry-run.
  --clean-managed    Remove previously synced managed paths using the manifest.
  -h, --help         Show this help.
EOF
}

fail() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

log() {
    printf '%s\n' "$*"
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
KIT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

REPO_ROOT=${PWD}
DRY_RUN=0
VALIDATE_ONLY=0
CLEAN_MANAGED=0
CHANGE_COUNT=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --repo-root)
            shift
            [ "$#" -gt 0 ] || fail "missing value for --repo-root"
            REPO_ROOT=$1
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
        --validate-only)
            DRY_RUN=1
            VALIDATE_ONLY=1
            ;;
        --clean-managed)
            CLEAN_MANAGED=1
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            fail "unknown argument: $1"
            ;;
    esac

    shift
done

REPO_ROOT=$(CDPATH= cd -- "$REPO_ROOT" && pwd)
GITHUB_DIR="$REPO_ROOT/.github"
MANIFEST_PATH="$GITHUB_DIR/.backend-agent-kit-manifest"
TMP_MANIFEST=$(mktemp "${TMPDIR:-/tmp}/backend-agent-kit-manifest.XXXXXX")

cleanup_tmp() {
    rm -f "$TMP_MANIFEST"
}

trap cleanup_tmp EXIT

mark_change() {
    CHANGE_COUNT=$((CHANGE_COUNT + 1))
    log "$1"
}

ensure_dir() {
    local dir_path=$1

    if [ ! -d "$dir_path" ]; then
        mark_change "mkdir $dir_path"

        if [ "$DRY_RUN" -eq 0 ]; then
            mkdir -p "$dir_path"
        fi
    fi
}

record_manifest_entry() {
    printf '%s\n' "$1" >> "$TMP_MANIFEST"
}

sync_file() {
    local source_file=$1
    local target_file=$2
    local manifest_entry=$3
    local parent_dir

    record_manifest_entry "$manifest_entry"
    parent_dir=$(dirname "$target_file")
    ensure_dir "$parent_dir"

    if [ ! -f "$target_file" ] || ! cmp -s "$source_file" "$target_file"; then
        mark_change "sync file $manifest_entry"

        if [ "$DRY_RUN" -eq 0 ]; then
            cp "$source_file" "$target_file"
        fi
    fi
}

sync_directory() {
    local source_dir=$1
    local target_dir=$2
    local manifest_entry=$3
    local rsync_preview

    record_manifest_entry "$manifest_entry"
    ensure_dir "$target_dir"

    rsync_preview=$(rsync -ani --delete --exclude '.DS_Store' --exclude '.gitkeep' "$source_dir/" "$target_dir/" | cat)

    if [ -n "$rsync_preview" ]; then
        mark_change "sync dir $manifest_entry"

        if [ "$DRY_RUN" -eq 0 ]; then
            rsync -a --delete --exclude '.DS_Store' --exclude '.gitkeep' "$source_dir/" "$target_dir/"
        fi
    fi
}

sync_layer() {
    local layer_name=$1
    local target_subdir=$2
    local source_root="$KIT_ROOT/$layer_name"
    local target_root="$GITHUB_DIR/$target_subdir"
    local item_path
    local item_name
    local target_path
    local manifest_entry

    [ -d "$source_root" ] || return 0

    ensure_dir "$target_root"

    while IFS= read -r item_path; do
        item_name=$(basename "$item_path")

        case "$item_name" in
            .gitkeep|.DS_Store)
                continue
                ;;
        esac

        target_path="$target_root/$item_name"
        manifest_entry=".github/$target_subdir/$item_name"

        if [ -d "$item_path" ]; then
            sync_directory "$item_path" "$target_path" "$manifest_entry"
        elif [ -f "$item_path" ]; then
            sync_file "$item_path" "$target_path" "$manifest_entry"
        fi
    done < <(find "$source_root" -mindepth 1 -maxdepth 1 | LC_ALL=C sort)
}

remove_path() {
    local target_path=$1
    local manifest_entry=$2

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        mark_change "remove $manifest_entry"

        if [ "$DRY_RUN" -eq 0 ]; then
            rm -rf "$target_path"
        fi
    fi
}

cleanup_stale_manifest_entries() {
    local old_entry
    local target_path

    [ -f "$MANIFEST_PATH" ] || return 0

    while IFS= read -r old_entry; do
        case "$old_entry" in
            ''|\#*)
                continue
                ;;
        esac

        if ! grep -Fxq "$old_entry" "$TMP_MANIFEST"; then
            target_path="$REPO_ROOT/$old_entry"
            remove_path "$target_path" "$old_entry"
        fi
    done < "$MANIFEST_PATH"
}

write_manifest() {
    ensure_dir "$GITHUB_DIR"

    if [ "$DRY_RUN" -eq 0 ]; then
        {
            printf '# Managed by backend-agent-kit sync script\n'
            printf '# Shared paths listed below are safe to replace or remove via sync-to-github.sh\n'
            cat "$TMP_MANIFEST"
        } > "$MANIFEST_PATH"
    fi
}

clean_managed_paths() {
    local old_entry
    local target_path

    if [ ! -f "$MANIFEST_PATH" ]; then
        log "No manifest found at $MANIFEST_PATH"
        exit 0
    fi

    while IFS= read -r old_entry; do
        case "$old_entry" in
            ''|\#*)
                continue
                ;;
        esac

        target_path="$REPO_ROOT/$old_entry"
        remove_path "$target_path" "$old_entry"
    done < "$MANIFEST_PATH"

    if [ "$DRY_RUN" -eq 0 ]; then
        rm -f "$MANIFEST_PATH"
    fi
}

[ -d "$KIT_ROOT/skills" ] || fail "backend-agent-kit root must contain skills/"
[ -d "$REPO_ROOT" ] || fail "repo root does not exist: $REPO_ROOT"

if [ "$CLEAN_MANAGED" -eq 1 ]; then
    clean_managed_paths

    if [ "$VALIDATE_ONLY" -eq 1 ]; then
        if [ "$CHANGE_COUNT" -gt 0 ]; then
            log "validate-only: managed paths exist"
            exit 1
        fi

        log "validate-only: no managed paths found"
        exit 0
    fi

    if [ "$CHANGE_COUNT" -eq 0 ]; then
        log "No managed paths removed"
    else
        log "Managed paths cleanup complete"
    fi

    exit 0
fi

sync_layer instructions instructions
sync_layer skills skills
sync_layer agents agents
sync_layer hooks hooks
sync_layer prompts prompts

cleanup_stale_manifest_entries

if [ "$VALIDATE_ONLY" -eq 1 ]; then
    if [ "$CHANGE_COUNT" -gt 0 ]; then
        log "validate-only: drift detected"
        exit 1
    fi

    log "validate-only: no drift detected"
    exit 0
fi

write_manifest

if [ "$CHANGE_COUNT" -eq 0 ]; then
    log "No changes detected"
else
    log "Sync complete"
fi
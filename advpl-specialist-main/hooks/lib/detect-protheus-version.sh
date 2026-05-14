#!/usr/bin/env bash
# advpl-specialist - Detect Protheus release version in the current project
#
# Usage:
#   source "${CLAUDE_PLUGIN_ROOT}/hooks/lib/detect-protheus-version.sh"
#   VERSION=$(detect_protheus_version)
#   version_gte "$VERSION" "12.1.2410" && echo "supports TLPP+MVC"
#
# Detection:
#   Reads `.protheus-version` file in the project root (explicit user convention).
#   The file must contain a release string like "12.1.2410" — one value per line.
#
# TDS-VSCode's `.totvsls/servers.json` was evaluated but its `buildVersion` field
# is the AppServer LIB build (e.g. "7.00.210324P"), not the Protheus release
# (e.g. "12.1.2410"), so automatic detection from it would require a brittle
# build-to-release mapping table. Explicit `.protheus-version` is the simpler
# and reliable contract.
#
# Returns the detected version string on stdout, or empty string if unknown.

detect_protheus_version() {
    if [ -f ".protheus-version" ]; then
        cat .protheus-version | tr -d '[:space:]'
        return 0
    fi

    echo ""
}

# Compare two semver-like version strings.
# Returns 0 (true) if $1 >= $2, 1 (false) otherwise.
# Uses `sort -V` for natural version ordering.
version_gte() {
    [ "$1" = "$(printf '%s\n%s' "$1" "$2" | sort -V | tail -n1)" ]
}

#!/usr/bin/env bash
# Append well-formed rows to a show-me-your-work decision log (TSV).
# Usage: log.sh <logfile> <phase> <decision> <why> <evidence> <result>
#        log.sh <logfile> < rows
# The second form reads several rows from stdin, one per line, each with the
# five cells (phase, decision, why, evidence, result) separated by tabs.
set -euo pipefail

usage() {
	printf 'usage: log.sh <logfile> <phase> <decision> <why> <evidence> <result>\n' >&2
	printf '       log.sh <logfile> < rows   (one row per line: phase, decision, why, evidence, result, tab-separated)\n' >&2
	exit 1
}

if [ "$#" -ne 6 ] && { [ "$#" -ne 1 ] || [ -t 0 ]; }; then
	usage
fi

logfile="$1"
shift

# Read and check every stdin row before writing, so one malformed line
# leaves the log untouched.
tab=$'\t'
rows=()
if [ "$#" -eq 0 ]; then
	line_number=0
	while IFS= read -r line || [ -n "$line" ]; do
		line_number=$((line_number + 1))
		line="${line%$'\r'}"
		if [ -z "${line//[[:space:]]/}" ]; then
			continue
		fi
		tabs="${line//[!$tab]/}"
		if [ "${#tabs}" -ne 4 ]; then
			printf 'log.sh: line %d has %d cells, not 5 tab-separated cells (phase, decision, why, evidence, result). Nothing was written.\n' \
				"$line_number" "$((${#tabs} + 1))" >&2
			exit 1
		fi
		rows+=("$line")
	done
	if [ "${#rows[@]}" -eq 0 ]; then
		printf 'log.sh: no rows on stdin. Nothing was written.\n' >&2
		exit 1
	fi
fi

logdir="$(dirname "$logfile")"
if [ -n "$logdir" ] && [ "$logdir" != "." ] && [ ! -d "$logdir" ]; then
	mkdir -p "$logdir"
fi

# Use `>>` here, never `>`. A network mount can fail this test for a log
# that exists. Then the cost is one stray header line, not the rows.
if [ ! -s "$logfile" ]; then
	printf 'ts\tphase\tdecision\twhy\tevidence\tresult\n' >> "$logfile"
fi

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
# Strip tabs/newlines/CR so cells stay on one line, and prefix any cell
# whose first char a spreadsheet would parse as a formula (=, +, -, @)
# with a single quote. The skill expects this log to be read in
# spreadsheets, so attacker-controlled evidence (PR titles, filenames,
# generated text) must not become formula execution when a reviewer
# opens the file.
clean() {
	local v
	v=$(printf '%s' "$1" | tr '\t\n\r' '   ')
	case "$v" in
		=*|+*|-*|@*) printf "'%s" "$v" ;;
		*) printf '%s' "$v" ;;
	esac
}
append_row() {
	printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
		"$ts" "$(clean "$1")" "$(clean "$2")" "$(clean "$3")" "$(clean "$4")" "$(clean "$5")" \
		>> "$logfile"
	warn_evidence "$4"
}

repo_root="$(git -C "$logdir" rev-parse --show-toplevel 2>/dev/null || true)"
git_revision() {
	git -C "$logdir" rev-parse --verify --quiet "$1" >/dev/null 2>&1 ||
		git -C "$logdir" rev-parse --verify --quiet "${1%%..*}" >/dev/null 2>&1
}
warn_evidence() {
	local token found candidate tokens
	read -r -a tokens <<< "$(printf '%s' "$1" | tr ',;()<>[]`"'"'"'\n\r' ' ')"
	for token in "${tokens[@]}"; do
		token="${token%.}"
		token="${token%%:[0-9]*}"
		case "$token" in *://*) continue ;; "~/"*) token="$HOME/${token#\~/}" ;; esac
		[[ "$token" =~ \.[A-Za-z][A-Za-z0-9]{0,7}$ ]] || continue
		found=""
		if [[ "$token" == /* ]]; then
			[ -e "$token" ] && found="$token"
		else
			for candidate in "$logdir/$token" ${repo_root:+"$repo_root/$token"}; do
				if [ -e "$candidate" ]; then
					found="$candidate"
					break
				fi
			done
		fi
		if [ -z "$found" ]; then
			git_revision "$token" ||
				printf 'log.sh: warning: evidence %s does not exist beside the log or at the repo root.\n' "$token" >&2
		elif git -C "$logdir" check-ignore -q -- "$found" 2>/dev/null; then
			printf 'log.sh: warning: evidence %s is gitignored, so the repo will not hold it.\n' "$token" >&2
		fi
	done
}

if [ "${#rows[@]}" -eq 0 ]; then
	append_row "$@"
fi
for row in "${rows[@]}"; do
	cells=()
	rest="$row"
	while [[ "$rest" == *"$tab"* ]]; do
		cells+=("${rest%%"$tab"*}")
		rest="${rest#*"$tab"}"
	done
	append_row "${cells[@]}" "$rest"
done

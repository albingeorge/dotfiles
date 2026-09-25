#!/usr/bin/env bash
#
# Install the personal config: fetch the nvim sub-repo and symlink
# tmux + neovim config into place.
#
# The personal config directory is resolved in this order:
#   1. --dir <path>
#   2. $PERSONAL_CONFIG_DIR
#   3. the directory holding this script   <-- default, so the repo works
#                                              from wherever it is cloned
#
# Written for both GNU and BSD/macOS userland: no readlink -f, ln -T,
# chmod --reference or date -r.

set -euo pipefail

TPM_URL=https://github.com/tmux-plugins/tpm

FORCE=
DRY_RUN=
CONFIG_DIR=${PERSONAL_CONFIG_DIR:-}

usage() {
	cat <<'USAGE'
Usage: install.sh [options]

Fetches the nvim sub-repo and symlinks the personal configs into place:

  ~/.tmux.conf              -> <personal-config-dir>/.tmux.conf
  ${XDG_CONFIG_HOME:-~/.config}/nvim -> <personal-config-dir>/nvim

Options:
  -f, --force       Move anything blocking a symlink aside to
                    <path>.backup.<timestamp>, then link over it. Without
                    this, blockers are reported and nothing is changed.
  -n, --dry-run     Print what would happen; change nothing.
      --dir <path>  Personal config directory. Defaults to
                    $PERSONAL_CONFIG_DIR, else this script's own directory.
  -h, --help        Show this help.
USAGE
}

while [ $# -gt 0 ]; do
	case $1 in
		-f|--force)   FORCE=yes ;;
		-n|--dry-run) DRY_RUN=yes ;;
		--dir)
			if [ $# -lt 2 ]; then
				echo "install: --dir needs a path" >&2
				exit 2
			fi
			CONFIG_DIR=$2
			shift
			;;
		--dir=*)      CONFIG_DIR=${1#--dir=} ;;
		-h|--help)    usage; exit 0 ;;
		*)
			echo "install: unknown option: $1" >&2
			usage >&2
			exit 2
			;;
	esac
	shift
done

# ---------------------------------------------------------------- resolve paths

script_dir=$(cd -- "$(dirname -- "$0")" && pwd -P)
config_dir_given=${CONFIG_DIR:-$script_dir}
CONFIG_DIR=$(cd -- "$config_dir_given" 2>/dev/null && pwd -P) || {
	echo "install: not a directory: $config_dir_given" >&2
	exit 1
}

# guard against a wrong --dir quietly linking nonsense into $HOME
if [ ! -f "$CONFIG_DIR/.tmux.conf" ]; then
	echo "install: $CONFIG_DIR does not look like the personal config repo" >&2
	echo "install: expected to find .tmux.conf there" >&2
	exit 1
fi

XDG=${XDG_CONFIG_HOME:-$HOME/.config}
STAMP=$(date +%Y%m%d-%H%M%S)
blockers=()

# ---------------------------------------------------------------------- helpers

info() { printf '%s\n' "$*"; }

# run a command, or just describe it under --dry-run
run() {
	if [ -n "$DRY_RUN" ]; then
		printf '            would run: %s\n' "$*"
	else
		"$@"
	fi
}

# human description of whatever is sitting at $1 (symlink before dir: a
# symlink to a directory satisfies both tests)
describe() {
	if [ -L "$1" ]; then
		printf 'symlink to %s' "$(readlink "$1")"
	elif [ -d "$1" ]; then
		printf 'real directory'
	else
		printf 'real file'
	fi
}

# symlink $2 -> $1
link_path() {
	local src=$1 dst=$2 what backup

	if [ ! -e "$src" ]; then
		echo "install: missing source: $src" >&2
		exit 1
	fi

	# -ef compares device+inode through symlinks, so this is true for an
	# equivalent link however it was spelled (absolute, relative, or via
	# another symlinked parent)
	if [ -L "$dst" ] && [ "$dst" -ef "$src" ]; then
		info "  ok        $dst (already linked)"
		return 0
	fi

	if [ -e "$dst" ] || [ -L "$dst" ]; then
		what=$(describe "$dst")
		if [ -z "$FORCE" ]; then
			blockers+=("$dst ($what)")
			info "  BLOCKED   $dst is a $what"
			return 0
		fi
		backup=$dst.backup.$STAMP
		info "  backup    $dst ($what)"
		info "            -> $backup"
		run mv "$dst" "$backup"
	fi

	run mkdir -p "$(dirname -- "$dst")"
	run ln -s "$src" "$dst"
	info "  linked    $dst -> $src"
}

# ------------------------------------------------------------- nvim sub-repo

fetch_nvim() {
	local nvim_dir=$CONFIG_DIR/nvim url branch

	if [ -e "$nvim_dir/init.lua" ]; then
		info "  ok        already present at $nvim_dir"
		return 0
	fi

	if [ ! -f "$CONFIG_DIR/.gitmodules" ]; then
		echo "install: no .gitmodules in $CONFIG_DIR; cannot fetch nvim config" >&2
		exit 1
	fi

	# .gitmodules is the single source of truth for url and branch
	url=$(git config -f "$CONFIG_DIR/.gitmodules" --get submodule.nvim.url) || {
		echo "install: submodule.nvim.url missing from .gitmodules" >&2
		exit 1
	}
	branch=$(git config -f "$CONFIG_DIR/.gitmodules" --get submodule.nvim.branch || true)

	if git -C "$CONFIG_DIR" rev-parse --git-dir >/dev/null 2>&1; then
		info "  clone     submodule nvim from $url"
		run git -C "$CONFIG_DIR" submodule update --init --recursive nvim
	else
		# the directory was copied rather than cloned, so there is no
		# submodule metadata to work from - clone it directly
		info "  clone     $url -> $nvim_dir"
		if [ -n "$branch" ]; then
			run git clone --branch "$branch" "$url" "$nvim_dir"
		else
			run git clone "$url" "$nvim_dir"
		fi
		return 0
	fi

	# submodule update leaves a detached HEAD; land on the tracking branch so
	# the nvim config can be edited and pushed without bumping a pointer here
	if [ -n "$branch" ]; then
		info "  checkout  nvim -> $branch"
		run git -C "$nvim_dir" checkout "$branch"
	fi
}

# --------------------------------------------------------- tmux plugin manager

install_tpm() {
	# .tmux.conf ends with `run '~/.config/tmux/plugins/tpm/tpm'`, so without
	# tpm the tmux config does nothing on a fresh machine
	local tpm_dir=$XDG/tmux/plugins/tpm

	if [ -e "$tpm_dir" ]; then
		info "  ok        already present at $tpm_dir"
		return 0
	fi

	info "  clone     $TPM_URL -> $tpm_dir"
	run mkdir -p "$(dirname -- "$tpm_dir")"
	run git clone "$TPM_URL" "$tpm_dir"
}

# ------------------------------------------------------------------------- main

info "personal config : $CONFIG_DIR"
info "home            : $HOME"
if [ -n "$DRY_RUN" ]; then
	info "dry run         : nothing will be changed"
fi

info ""
info "nvim sub-repo:"
fetch_nvim

info ""
info "symlinks:"
link_path "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_path "$CONFIG_DIR/nvim"       "$XDG/nvim"

info ""
info "tmux plugin manager:"
install_tpm

if [ ${#blockers[@]} -gt 0 ]; then
	info ""
	echo "install: ${#blockers[@]} path(s) are in the way and were left untouched:" >&2
	for b in "${blockers[@]}"; do
		echo "  - $b" >&2
	done
	echo >&2
	echo "Re-run with --force to move them to <path>.backup.<timestamp> and link over them." >&2
	echo "Nothing is ever deleted; a backup can be moved back to undo this." >&2
	exit 1
fi

info ""
info "done."

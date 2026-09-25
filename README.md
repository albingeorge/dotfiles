# Dotfiles

Personal dotfiles collection.

| what | lives here | linked to |
| --- | --- | --- |
| tmux | `.tmux.conf` | `~/.tmux.conf` |
| neovim | `nvim/` (sub-repo) | `${XDG_CONFIG_HOME:-~/.config}/nvim` |

`nvim/` is a git submodule of
[albingeorge/kickstart-modular.nvim](https://github.com/albingeorge/kickstart-modular.nvim)
tracking the `albin` branch.

## Setting up a new machine

```sh
git clone --recurse-submodules <this-repo-url> ~/dotfiles.personal
~/dotfiles.personal/install.sh
```

`install.sh` fetches the nvim sub-repo, creates both symlinks, and clones
[tpm](https://github.com/tmux-plugins/tpm) into
`${XDG_CONFIG_HOME:-~/.config}/tmux/plugins/tpm` if it isn't there yet — without
tpm the plugin lines in `.tmux.conf` do nothing.

It is safe to re-run: anything already correct is reported as `ok` and skipped.

### It doesn't have to live at `~/dotfiles.personal`

The script always uses **its own directory** as the personal config directory,
so clone the repo wherever you like and it just works. The paths in this README
assume `~/dotfiles.personal`; substitute your own.

### Files already in the way

If something real already sits where a symlink belongs, `install.sh` reports it
and changes nothing:

```
  BLOCKED   /Users/you/.config/nvim is a real directory
```

Preview everything first with `--dry-run`, then re-run with `--force` to move
each blocker to `<path>.backup.<timestamp>` and link over it. Nothing is ever
deleted — to undo, move the backup back:

```sh
rm ~/.config/nvim                                  # the symlink
mv ~/.config/nvim.backup.20260925-201500 ~/.config/nvim
```

## Working on the nvim config

`install.sh` leaves the submodule on the `albin` branch rather than a detached
HEAD, so edit, commit and push it directly:

```sh
cd ~/.config/nvim        # the symlink is fine
git add -A && git commit && git push
```

Then record the new commit in this repo:

```sh
cd ~/dotfiles.personal
git add nvim && git commit -m "chore: bump nvim config"
```

To pull the latest `albin` into an existing checkout:

```sh
git -C ~/dotfiles.personal submodule update --remote --merge nvim
```

## Adding another config

Add a line to the symlink list near the bottom of `install.sh`:

```sh
link_path "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_path "$CONFIG_DIR/nvim"       "$XDG/nvim"
```

## Coding agents

Instructions for AI coding agents live in [`AGENTS.md`](AGENTS.md).
`CLAUDE.md` just imports it, so Claude Code picks up the same rules.

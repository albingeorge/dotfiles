# The directory this file lives in, so the files next to it can be found
# no matter which directory the shell starts in (a plain "./work_log.sh"
# would be looked up in the current directory instead). Step by step:
#   %x                     the path of the file being sourced right now,
#                          i.e. this .zshrc (a prompt escape, like %~ in PS1)
#   ${(%):-%x}             expands that escape outside of a prompt
#   ${...:A}               makes it absolute and resolves symlinks
#   ${...:h}               drops the file name, keeping its directory ("head")
personal_dotfiles_dir=${${(%):-%x}:A:h}

source "${personal_dotfiles_dir}/work_log.sh"

# Git Integration
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '(%b)'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true

# Prompt (aka PS1)
PROMPT="%B%F{014}%n%f%b %F{015}in%f %B%F{011}%2~%f%b \$vcs_info_msg_0_ $ "

# read:generate_bash_functions

# read:generate_paths

export ANSIBLE_NOCOWS="1";
export AUTO_REMOVE_SLASH="0";
export ENABLE_COPILOT="yes";
export FZF_DEFAULT_COMMAND="fd --type f";
export FZF_DEFAULT_OPTS="--height 10 --reverse";
export HISTSIZE="10000";
export LANG="en_US.UTF-8";
export LESS="XFR";
export LS_COLORS="";
export SSLMAKER_HOME="$HOMEBREW_PREFIX/etc/sslmaker";
export TT_HOURS_PER_MONTH="150";

# inline
command -v tmac >/dev/null && export NVIM_TERMINAL_SHELL="tmac";
command -v nvim >/dev/null 2>&1 && export EDITOR="nvim";

# inline
[ -e "/etc/profile.d/bash_completion.sh" ] && source "/etc/profile.d/bash_completion.sh";
[ -e "/opt/homebrew/etc/profile.d/bash_completion.sh" ] && source "/opt/homebrew/etc/profile.d/bash_completion.sh";

# read:generate_gpg_config

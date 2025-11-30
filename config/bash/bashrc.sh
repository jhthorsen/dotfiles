# read:generate_paths
# read:generate_bash_functions

export ANSIBLE_NOCOWS="1";
export AUTO_REMOVE_SLASH="0";
export ENABLE_COPILOT="yes";
export FZF_DEFAULT_COMMAND="fd --type f";
export FZF_DEFAULT_OPTS="--height 10 --reverse";
export GPG_TTY="$(tty)";
export HISTCONTROL="ignoredups:erasedups:ignorespace";
export HISTSIZE="10000";
export LANG="en_US.UTF-8";
export LESS="XFR";
export LS_COLORS="";
export TT_HOURS_PER_MONTH="150";

command -v nvim >/dev/null 2>&1 && export EDITOR="nvim"; # INLINE

[ -e "/etc/profile.d/bash_completion.sh" ] && source "/etc/profile.d/bash_completion.sh"; # INLINE
[ -e "/opt/homebrew/etc/profile.d/bash_completion.sh" ] && source "/opt/homebrew/etc/profile.d/bash_completion.sh"; # INLINE

# read:generate_gpg_config

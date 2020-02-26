# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

# ============================================================================
# Source external files
# ----------------------------------------------------------------------------
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh
source /usr/local/etc/profile.d/z.sh
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

fpath=(/usr/local/share/zsh-completions $fpath)

for SOURCE_LINK in $(find ~/.config/dot-files -depth 1 -type l | sort); do
  SOURCE_FILE=$(readlink $SOURCE_LINK);
  [ -f $SOURCE_FILE ] && source $SOURCE_FILE;
done
unset SOURCE_FILE;

# ============================================================================
# Misc settings
# ----------------------------------------------------------------------------
bindkey -v # vim bindings
umask 0002
setopt notify
unsetopt extendedglob # Allow "git show HEAD^"

setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
unsetopt always_to_end
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion
zstyle ':completion:*' special-dirs true

# rm -f ~/.zcompdump; compinit

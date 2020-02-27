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
source /usr/local/etc/profile.d/z.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

fpath=(/usr/local/share/zsh-completions $fpath)

for SOURCE_LINK in $(find $HOME/.config/dot-files -maxdepth 1 -type l | sort); do
  SOURCE_FILE=$(readlink $SOURCE_LINK);
  [ -f $SOURCE_FILE ] && source $SOURCE_FILE;
done
unset SOURCE_FILE;

# ============================================================================
# Misc settings
# ----------------------------------------------------------------------------
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

# Autocomplete caching
# zstyle ':completion:*' use-cache on
# zstyle ':completion:*' cache-path ~/.zsh/cache

# rm -f ~/.zcompdump; compinit

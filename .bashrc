# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
   *i*) ;;
     *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
   debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
   xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
   if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
   else
	color_prompt=
   fi
fi

if [ "$color_prompt" = yes ]; then
   PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
else
   PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
   PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
   ;;
*)
   ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
   test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
   alias ls='ls --color=auto'
   #alias dir='dir --color=auto'
   #alias vdir='vdir --color=auto'

   alias grep='grep --color=auto'
   alias fgrep='fgrep --color=auto'
   alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ls aliases
alias ll='exa -l'
alias ls='exa'

alias cat='bat'
alias man='batman'

# nnn: detailed, cp & mv progress, fortune
alias nnn='nnn -drF'

alias hexedit='hexedit --color'
alias df='df -h'
alias du='du -h'
alias dud='du -hd 1'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

eval "$(thefuck --alias)"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
   if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
   elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
   fi
fi

export LC_COLLATE="C"
export LC_CTYPE="en_US.UTF-8"
export LC_TIME="en_GB.UTF-8"
export LLC_PAPER="en_GB.UTF-8"
export LLC_MEASUREMENT="en_GB.UTF-8"
unset LC_ALL

export EDITOR=/usr/bin/vi
export VISUAL=ewrap
export NNN_TRASH=2
export GPG_TTY=$(tty)

# required because of the crappy version (<530) of less in raspi os
export BAT_PAGER="less -R"

export RCLONE_PASSWORD_COMMAND="pass rclone/config"
export $(gnome-keyring-daemon --daemonize --start)
source "$HOME/.cargo/env"

# nnn cd on quit stuff
n ()
{
   # Block nesting of nnn in subshells
   if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
       echo "nnn is already running"
       return
   fi

   # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
   # To cd on quit only on ^G, remove the "export" as in:
   #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
   # NOTE: NNN_TMPFILE is fixed, should not be modified
   NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

   # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
   # stty start undef
   # stty stop undef
   # stty lwrap undef
   # stty lnext undef

   nnn "$@"

   if [ -f "$NNN_TMPFILE" ]; then
       . "$NNN_TMPFILE"
       rm -f "$NNN_TMPFILE" > /dev/null
   fi
}

eval "$(starship init bash)"
colorscript random

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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
#force_color_prompt=yes

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

# removed other things about displaying to PS1 from here and put
# them into own function

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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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

##-ANSI-COLOR-CODES-##
Color_Off="\033[0m"
###-Regular-###
Red="\033[0;31m"
Green="\033[0;32m"
Purple="\033[0;35m"
Cyan="\033[0;34m"
Yellow="\033[0;33m"
####-Bold-####
BRed="\033[1;31m"
BPurple="\033[1;35m"

# oh crap, need to make sure it knows where to find the virtualenv stuff!
# else it will say, workon isn't a command it knows
# but DON'T need to export to $VIRTUAL_ENV

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then 
  source /usr/local/bin/virtualenvwrapper.sh
fi


# This is the scary bit: wrap everything that does prompt display
# into a single function that I determine
function my_prompt_command()
{
    # reset value of prompt command to blank at start
    PS1=""

    if [ "$color_prompt" = yes ]; then
        PS1="${debian_chroot:+($debian_chroot)}\[$Green\]\u@\h\[$Color_Off\]:\[$Cyan\]\w\[$Color_Off\]$ "
    else
        PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "
    fi

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
    esac

    # Addition to display which Python virtual env you are in (if any)
    if [[ $VIRTUAL_ENV != "" ]]; then
        # Strip out the path of the venv and just leave the env name
        venv="\[$Cyan\](${VIRTUAL_ENV##*/})\[$Color_Off\]"
    else
        # In case you don't have one activated
        venv=""
    fi
    
    #now add this result to the prompt
    PS1=$venv$PS1

    # check if inside git repo
    local git_status="`git status -unormal 2>&1`"

    if ! [[ "$git_status" =~ (N|n)ot\ a\ git\ repo ]] && [ -s ~/Code/posh-git-sh/git-prompt.sh ]; then
        # Use posh-git-sh function written by @lyze to display git status nicely
        # I should really write a custom version at some point
        # https://github.com/lyze/posh-git-sh

        source ~/Code/posh-git-sh/git-prompt.sh
        local git_whats_up=""

        git_whats_up=$(__posh_git_echo)

        # now add this result to the prompt
        PS1+="$git_whats_up $ ";
    fi

}

PROMPT_COMMAND=my_prompt_command

# Get rid of annoying 'Bash isn't the default shell on Mac' message
export BASH_SILENCE_DEPRECATION_WARNING=1

# This is required by Docker-compose of ccg_pipelines to run locally at the moment
export CCG_PIPELINES_WORKING_DIR=~/bioinformatics_data
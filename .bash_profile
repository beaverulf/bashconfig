# Always -list with ls
alias ls="ls -l"

# Git branch in prompt.
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\033[96m\]\t\[\033[00m\] \[\033[36m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] "

#Color the ls output.
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad

export GOPATH=$HOME/go
export PATH=$PATH:$(go env GOPATH)/bin

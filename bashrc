PS1='\u \W $ '
set -o vi
shopt -s globstar

# Key bindings.
bind -m vi-command '\c-l: clear-screen'
bind -m vi-insert '\c-l: clear-screen'

# Aliases.
alias ls='ls --color=auto'
alias hib='systemctl hibernate'
alias tmux='tmux -2'
alias ms='apropos'  # Man (pages) search.
alias cgdb='env TERM=screen-256color sudo cgdb'
alias svim='vim --servername vim'
alias ctags-init='echo . > .ctags-src-files'

# Offload rest of configuration to local script for machine-dependent
# configuration.
if [ -f ~/.bashrc.local ]; then
	source ~/.bashrc.local
fi

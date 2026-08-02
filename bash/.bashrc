# Standard Bash Prompt
# Format: user@host:~/current/dir$
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enable color support for common commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'

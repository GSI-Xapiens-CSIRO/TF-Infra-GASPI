export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PNPM_HOME="/home/atlantis/.local/share/pnpm"
export PATH="${PNPM_HOME}:${PATH}"

export BIN_HOME="/home/atlantis/bin"
export PATH="${BIN_HOME}:${PATH}"
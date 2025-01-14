# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew paths
eval "$(/opt/homebrew/bin/brew shellenv)"

# Direnv integration for Zsh
eval "$(direnv hook zsh)"

### Zinit Installation
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load important Zinit annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### Plugin Management with Zinit

# Powerlevel10k prompt
zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Syntax highlighting
zinit wait lucid for zsh-users/zsh-syntax-highlighting

# Autosuggestions
zinit wait lucid for zsh-users/zsh-autosuggestions

# Fast completion
zinit wait lucid for mattmc3/zsh-safe-rm

# Fuzzy Finder (fzf) integration
zinit wait lucid for \
    junegunn/fzf \
    peterhurford/up.zsh

# Add custom settings for fzf (optional)
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

### Conda Initialization
__conda_setup="$('/Users/jeremy/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/jeremy/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/jeremy/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/jeremy/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/Users/jeremy/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/Users/jeremy/miniforge3/etc/profile.d/mamba.sh"
fi

# iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# LM Studio CLI
export PATH="$PATH:/Users/jeremy/.cache/lm-studio/bin"

################################################################################
# Custom Powerlevel10k Segments
################################################################################

# Conda environment segment
# This function displays the active Conda environment in the prompt.
function prompt_conda() {
  if [[ -n $CONDA_DEFAULT_ENV ]]; then
    # Display the current Conda environment with specified colors and icon.
    p10k segment -f '#ABB2BF' -b '#272C36' -t "($CONDA_DEFAULT_ENV)" -i "🌱"
  fi
}

# GPU information segment adapted for Apple Silicon
# This function displays GPU information tailored for Apple Silicon Macs.
function prompt_gpu() {
  local arch=$(uname -m)
  local os=$(uname)
  
  if [[ "$os" == "Darwin" && "$arch" == "arm64" ]]; then
    # On Apple Silicon, retrieve GPU info once and cache it for performance.
    if [[ -z $APPLE_GPU_INFO ]]; then
      APPLE_GPU_INFO=$(system_profiler SPDisplaysDataType 2>/dev/null \
        | awk -F': ' '/Chipset Model/ {gsub(/^ +/, "", $2); print $2; exit}')
    fi
    # Display the cached GPU model information.
    p10k segment -f '#98C379' -b '#272C36' -t "GPU: ${APPLE_GPU_INFO:-Apple Silicon GPU}" -i "🎮"
  
  elif command -v nvidia-smi &>/dev/null; then
    # For non-Apple Silicon systems with NVIDIA GPUs, retrieve GPU info.
    local gpu_info
    gpu_info=$(nvidia-smi --query-gpu=name,memory.used --format=csv,noheader,nounits | head -n1)
    p10k segment -f '#98C379' -b '#272C36' -t "GPU: $gpu_info" -i "🎮"
  fi
}
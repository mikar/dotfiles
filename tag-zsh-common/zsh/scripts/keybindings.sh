# Based on what has already been entered at the prompt, do a history search when pressing Alt+Up/Down
bindkey "^[[1;3A" history-beginning-search-backward
bindkey "^[[1;3B" history-beginning-search-forward
# Use Alt+j/k for vim-style history search
bindkey "^[k" history-beginning-search-backward
bindkey "^[j" history-beginning-search-forward
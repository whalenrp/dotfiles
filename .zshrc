[ -r $HOME/.profile_lda ] && . $HOME/.profile_lda

autoload -Uz compinit && compinit

source ~/.config/zsh/fzf-tab.plugin.zsh
source ~/.config/zsh/git-checkout-completion.zsh
source ~/.config/zsh/arh/arh.sh

unsetopt BEEP
export DEVPOD_ENVIRONMENT=production
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# ZSH general configuration
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE=$HOME/.zsh_history
export PS1="%F{magenta}%2~%f %(?.%F{green}%#%f.%F{red}%#%f) "
export RPS1='%D{%k:%M}'
export TERM=xterm-256color
export EDITOR=/usr/bin/nvim
alias vim=nvim
[ -n "$TMUX" ] && export TERM=screen-256color # TMUX wants this to be set to a different string to pick up 256 colors

jira()
{
	JIRA_API_TOKEN=$(usso -ussh t3 -print) command jira "$@"
}

export CLICOLOR=1
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
dotfiles_init () {
	git clone --bare https://github.com/whalenrp/dotfiles.git $HOME/.dotfiles
	dotfiles checkout
	dotfiles config --local status.showUntrackedFiles no
	# Auth not needed for the initial clone, but pushes are configured over ssh
	dotfiles remote set-url origin git@github-personal:whalenrp/dotfiles.git
}
set -o vi

alias bell="echo -e '\a'"
alias gs="git status -uno ." # only check down the current dir to make this fast for the monorepo
alias gsu="git status -u ."
alias gd="git diff ." # only check down the current dir to make this fast for the monorepo
alias gl="git log ."
alias ad="arc diff HEAD^"
alias gp="git pull --rebase origin"

#source .config/zsh.d/*

#############
# UBER STUFF
#############
alias schemaless-client="schemaless-cli"
export PATH=$HOME/.fzf/bin:$PATH:$HOME/bin:/usr/local/sbin:$HOME/.local/bin

export UBER_HOME=$HOME/Uber
export USER_UUID="a3ca2506-4e4d-457a-97b4-800d29a825e0"
export UBER_OWNER_UUID="a3ca2506-4e4d-457a-97b4-800d29a825e0"
export UBER_LDAP_UID=rwhalen
export UBER_OWNER=rwhalen@uber.com
export LDFLAGS="-L/usr/local/opt/readline/lib -L/usr/local/opt/openssl@1.1/lib -L/usr/local/opt/icu4c/lib"
export CPPFLAGS="-I/usr/local/opt/readline/include -I/usr/local/opt/openssl@1.1/include -I/usr/local/opt/icu4c/include"
export PKG_CONFIG_PATH="/usr/local/opt/readline/lib/pkgconfig:/usr/local/opt/openssl@1.1/lib/pkgconfig:/usr/local/opt/icu4c/lib/pkgconfig"

#Enable uLSP in devpods
export GOPACKAGESDRIVER_ULSP_MODE=true

if $(which direnv &> /dev/null); then
	eval "$(direnv hook zsh)";
fi

uid () {
	echo -n $UBER_OWNER_UUID | pbcopy
	echo $UBER_OWNER_UUID
}

alias gomo="cd $HOME/go-code/src/code.uber.internal/"
alias mpath="git rev-parse --show-prefix | sed 's/\/$//'"
alias lint="arc lint --apply-patches"

docker_mysql () {
	containerid=$(docker ps | grep mysql | head -n 1 | cut -f 1 -d ' ')
	docker exec -it $containerid mysql -u root -h 127.0.0.1
}

racecheck() {
	bazel test --test_timeout=500 --keep_going --@io_bazel_rules_go//go/config:race --cache_test_results=no $@ --runs_per_test=10
}

dev() {
	location="$1"
	ssh rwhalen-tmux.devpod-$location
}

oc-build () {
	echo "follow directions to install if oc doesn't exist"
	echo "cd ~/go-code/src/code.uber.internal/config/object-config/tools && make bins"
	echo "alias oc='~/go-code/src/code.uber.internal/config/object-config/tools/object-config-client'"
}

ap () {
	cr=$(echo $1 |  sed 's/.*code\.uberinternal.com\///')
	arc patch $cr
}

stop_ulsp () {
	rm -f /tmp/ulsp.lock
	pkill -f ulsp-daemon
}

start_ulsp () {
	touch /tmp/ulsp.lock
	while [ -f /tmp/ulsp.lock ]; do
		if ! pgrep ulsp
		then
			ulsp
		fi
		sleep 10
	done
}

ulsp () {
	ULSP_ENVIRONMENT=local \
	UBER_CONFIG_DIR=~/go-code/src/code.uber.internal/devexp/ide/ulsp-daemon/config \
	nohup uexec ~/go-code/tools/ide/ulsp/ulsp-daemon > /tmp/ulsp.log
}

# Created by `pipx` on 2024-08-02 16:57:16
export PATH="$PATH:/Users/rwhalen/.local/bin"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.config/zsh/fzf-git/fzf-git.sh ] && source ~/.config/zsh/fzf-git/fzf-git.sh
if $(which fzf &> /dev/null); then
	export FZF_DEFAULT_OPTS='--tmux'

	fzf-dir-widget() {
		local dir=$(find . -type d 2>/dev/null | sed 's/^\.\///' | fzf)
		if [[ -n $dir ]]; then
			LBUFFER="${LBUFFER}${dir}"
		fi
		zle reset-prompt
	}
	zle -N fzf-dir-widget
	bindkey '^G' fzf-dir-widget

	bazel_test_fzf() {
		local target=$(bazel query 'tests(...)' 2>/dev/null | fzf --preview 'echo {}' --preview-window down:3:wrap)
		if [[ -n $target ]]; then
			LBUFFER="${LBUFFER}${target}"
		fi
		zle reset-prompt
	}
	zle -N bazel_test_fzf
	bindkey '^P' bazel_test_fzf
fi

if command -v pyenv 1>/dev/null 2>&1; then
 eval "$()"
fi

eval "$(zoxide init zsh)"


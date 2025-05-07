[ -r $HOME/.profile_lda ] && . $HOME/.profile_lda

autoload -Uz compinit && compinit

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
[ -n "$TMUX" ] && export TERM=screen-256color # TMUX wants this to be set to a different string to pick up 256 colors

alias schemaless-client="schemaless-cli"
export CLICOLOR=1
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
set -o vi

source .config/zsh.d/*
export ANDROID_HOME=$HOME/android-sdk
export ANDROID_NDK=$HOME/android-ndk
export ANDROID_NDK_HOME=$ANDROID_NDK
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin:$PATH:$HOME/bin:/usr/local/sbin

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
# Universal go search --  theoretically refreshes the db weekly, but manual updates will likely
# be necessary if you don't leave the laptop on 24/7
# Init must be run first. After the initial library build, `gocd bar` and gocd emobility_rider`
# should work. As directories change, you will need to run gocd_update to rebuild the index and 
# pick up any changes
alias ucd_init="sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist"
alias ucd_update="/usr/libexec/locate.updatedb"
ucd () {
	# These overrides are samples that can be modified to add in shortcuts for projects you access regularly.
    # They will obviously not work on your machine without tweaking them :)
	overrides="
	api $HOME/go-code/src/code.uber.internal/eats/presentation
	rider $HOME/go-code/src/code.uber.internal/rider/product/micromobility/rider
	presentation $HOME/go-code/src/code.uber.internal/rider/presentation/micromobility/rider-presentation
	bar $HOME/gocode/src/code.uber.internal/growth/bar
	messaging $HOME/go-code/src/code.uber.internal/rider/product/consumer-messaging
	feeder $HOME/gocode/src/code.uber.internal/rex/feeder
	jukebox $HOME/gocode/src/code.uber.internal/performance/jukebox
	rankingengine $HOME/gocode/src/code.uber.internal/growth/rankingengine
	eats-api $HOME/go-code/src/code.uber.internal/eats/presentation
	web-proto $HOME/go-code/src/code.uber.internal/everything/eats-web-prototype
	"
    # Find exact matches and grab the filepath from the second position
	override_matches=$(echo $overrides | grep -w "$@" | awk '{print $2}')
	matches=$override_matches
	if [[ -z $override_matches ]]
	then
		# for everything else, locate all dirs with cerberus (proxy for runnable services)
		locations=$(locate "*$@*.cerberus/cerberus.yaml" | sed 's/.cerberus\/cerberus.yaml//')
		matches=$(echo $override_matches ; echo $locations)
	fi

    # remove empty lines and take the first match (using the overrides first if there were any matches
	first_match=$(echo $matches | sed '/^$/d' | head -n 1)
	cd $first_match
}

alias gocd="ucd"
alias gomo="cd $HOME/go-code/src/code.uber.internal/"
alias mpath="git rev-parse --show-prefix | sed 's/\/$//'"
alias lint="arc lint --apply-patches"

docker_mysql () {
	containerid=$(docker ps | grep mysql | head -n 1 | cut -f 1 -d ' ')
	docker exec -it $containerid mysql -u root -h 127.0.0.1
}

alias prod='DOMAIN=system.uberinternal.com; PROD=https://ignored:$(usso -ussh $DOMAIN -print)@$DOMAIN'
alias cerberuslogs="tail -f $HOME/Library/Logs/cerberus.log"
alias gs="git status -uno ." # only check down the current dir to make this fast for the monorepo
alias gsu="git status -u ."
alias gd="git diff ." # only check down the current dir to make this fast for the monorepo
alias gl="git log ."
alias ad="arc diff HEAD^"
alias gp="git pull --rebase origin"

nvm_init() {
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

racecheck() {
	bazel test --test_timeout=500 --keep_going --@io_bazel_rules_go//go/config:race --cache_test_results=no $@ --runs_per_test=10
}

ruby_init() {
	if command -v rbenv > /dev/null; then eval "$(rbenv init -)"; fi
}
alias pixel="emulator -avd Pixel_6_API_33"

dev() {
	location="$1"
	rsync -avzr --files-from=/Users/rwhalen/.devpod-synced-files ~ rwhalen.devpod-$location:/home/user/
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

setup_aider () {
	mkdir -p ~/bin
	tb-cli get /prod/progsys/aider/aider ~/bin/aider
	chmod +x ~/bin/aider
}

# Created by `pipx` on 2024-08-02 16:57:16
export PATH="$PATH:/Users/rwhalen/.local/bin"

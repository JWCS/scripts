#!/bin/bash
# Installing a python development environment
# User should read up on the following to know how to use it.
# DOCS: See each section:
# AUTHOR: Jude Sauve <sauve031@umn.edu>
# VERSION 1.0 : LAST_CHANGED 2019-09-05
# LICENSE: MIT

# How to develop with python once this is all installed
# In your new project directory, make a .envrc file
# In your ~/.direnvrc file, at the bottom is some commented-out code, for a .envrc file
# Place the code in the .envrc file. The double commented out lines should still be commented out. 
# I usually copy-paste another .envrc file when I make a new project
# You need to change two things: the `pyversion=X.Y.Z` needs the version of python you want to use.
# The `pvenv=PROJECT-NAME` needs the project name.
# Upon exiting, it will ask you to run `direnv allow` once
# Afterwards, whenever you cd into this directory, you're in a special python environment, separate
# from every other environment. If you cd out, you will leave the environment.
# Try to only install with pip, BUT: do not use --user/-H and do not use sudo.
# If you have not used this before, your version of python you want to use will not be installed. 
# To install a python version, use `pyenv install X.Y.Z` (this will auto-complete).
# For example, to install the last 3.5 version, run `pyenv install 3.5.7` - or use more recent version.
# There should be words on the left of the terminal interface, with possibly your python environment
# or git branch. These were also done in here; it's called the PS1. To change this, change it in your
# ~/.bashrc file. If it doesn't work, make an issue. 

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  RC_FILE=~/.bashrc
  echo "Installing for linux, installing configuration to: $RC_FILE"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  RC_FILE=~/.profile
  echo "Installing for osx, installing configuration to: $RC_FILE"
else
  echo "Only GNU Linux is guarenteed to work. If not,
  do this yourself, and know what you're doing"
  exit 1
fi

# Python Flush (except base software executables)
# Clean up yo mess, and never pip install outside of a virtualenv again!
# TODO (Mine is actually clean rn...)
echo "You should delete ALL python stuff under ~/.local/ and delete all 'site_packages' folders from /usr/lib/"
# https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
read -p "Would you like to continue? (have you deleted stuff?) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# virtualenv
  # DOCS: https://virtualenv.pypa.io/en/latest/
  # This and pip are the only things installed globally! Keep clean!
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  sudo apt-get install python-pip
elif [[ "$OSTYPE" == "darwin"* ]]; then
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python get-pip.py
  rm get-pip.py
fi
pip install --user virtualenv

cat <<EXCL >> $RC_FILE

# Custom Additions

EXCL

# pyenv + pyenv-virtualenv plugin
  # DOCS: https://objectpartners.com/2018/11/27/managing-multiple-python-instances/
  # DOCS: https://github.com/pyenv/pyenv/blob/master/COMMANDS.md
  # Usage: Read up ^^^
  # DOCS: https://github.com/pyenv/pyenv-virtualenv#usage
  # Usage: pyenv virtualenv PY_VERSION_I_WANT (MY-PROJ-NAME-OPTIONAL-)PY_VERSION_I_WANT
  # Ex: pyenv virtualenv 3.5.2 test-proj-3.5.2
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
  xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libffi-dev \
  liblzma-dev python-openssl git
  curl https://pyenv.run | bash
  echo 'export PYENV_ROOT="$HOME/.pyenv"'>> $RC_FILE
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> $RC_FILE
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew update
  brew install curl git
  brew install pyenv pyenv-virtualenv
fi
cat <<EXCL >> $RC_FILE
# pyenv setup
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

EXCL
  
source $RC_FILE
pyenv update

# direnv: see github wiki for below configs; do last
  # DOCS: https://github.com/direnv/direnv/wiki
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  sudo apt-get install direnv
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew install direnv
fi
cat <<EXCL >> $RC_FILE
# direnv config
eval "\$(direnv hook bash)"

EXCL
# direnv - python
  # DOCS: https://github.com/direnv/direnv/wiki/Python
  # Can get .envrc sample from .direnvrc file
cat <<EXCL >> ~/.direnvrc
use_python() {
    if [ -n "\$(which pyenv)" ]; then
        local pyversion=\$1
        pyenv local \${pyversion}
    fi
}

layout_virtualenv() {
    local pyversion=\$1
    local pvenv=\$2
    if [ -n "\$(which pyenv virtualenv)" ]; then
        pyenv virtualenv --force --quiet \${pyversion} \${pvenv}-\${pyversion}
    fi
    pyenv local --unset
}

layout_activate() {
    if [ -n "\$(which pyenv)" ]; then
        source \$(pyenv root)/versions/\$1/bin/activate
    fi
}

# Example .envrc

## -*- mode: sh; -*-
## (rootdir)/.envrc : direnv configuration file
## see https://direnv.net/
## pyversion=\$(head .python-version)
## pvenv=\$(head     .python-virtualenv)
#
#pyversion=3.5.7
#pvenv=myproject
#
#use python \${pyversion}
## Create the virtualenv if not yet done
#layout virtualenv \${pyversion} \${pvenv}
## activate it
#layout activate \${pvenv}-\${pyversion}

EXCL
# direnv - sudo:
  # DOCS: https://github.com/direnv/direnv/wiki/Sudo
# direnv - OSX
  # DOCS: https://github.com/direnv/direnv/wiki/Docker-Machine
# direnv - git:
  # DOCS: https://github.com/direnv/direnv/wiki/Git
git config --global core.excludesfile "~/.gitignore_global"
cat <<EXCL >> ~/.gitignore_global
# Direnv stuff
.direnv
.envrc

EXCL
  # Can add more obvious stuff to git, or not trust ppl and add
  # All generated file exclusions to project .gitignore
# direnv - tmux
  # DOCS: https://github.com/direnv/direnv/wiki/Tmux
cat <<EXCL >> $RC_FILE
alias tmux='direnv exec / tmux'

EXCL
# direnv - PS1
  # DOCS: https://github.com/direnv/direnv/wiki/PS1
  # DOCS: https://github.com/direnv/direnv/wiki/Python
  # direnv needs to come last in bashrc, but ps1 can have more mods (git!)
cat <<EXCL >> $RC_FILE
# Custom solution to disp git branch, from webs
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='\$(parse_git_branch)\[\033[00m\]'\$PS1

# PS1 Mod
show_virtual_env() {
  if [[ -n "\$VIRTUAL_ENV" && -n "\$DIRENV_DIR" ]]; then
    echo "(\$(basename \$VIRTUAL_ENV))"
  fi
}
export -f show_virtual_env
PS1='\$(show_virtual_env)'\$PS1

EXCL

source $RC_FILE
echo "You should clean up / order your .bashrc, don't let it get messy"
echo "To install python, look up 'pyenv', or enter it in the terminal, 'pyenv versions'"
echo "Install a python version using 'pyenv install VERSION' Or use -l to list options"
echo "The default in the bash script is 3.5.7, because it should be compatible with all other users"
echo "But if you want to develop on the best, change it to 3.7+ or whatever it is these days."
echo " To ACTUALLY use this, copy the 'Example .envrc' from your ~/.direnv file, into your project directory"
echo "The file should be named .envrc, and you need to uncomment everything."
echo "Also, change pyversion=[The version you want, you have to install it with pyenv install!]"
echo "And change pvenv=[The name of your project]"
echo "Now just cd into that directory, and run (as instructed) 'direnv allow'"
echo "You will never need to bother with setup again. Just pip install everything! No conflicts!"

#!/usr/bin/env bash
# ssh_key_setup.sh
# VERSION 1.0 : LAST_CHANGED 2019-09-18
# AUTHOR Jude Sauve <sauve031@umn.edu>
# To automate the creation of ssh keys, installing to the proper place,
# and call up github.

# Adding an SSH key to your computer
# If ~/.ssh exists, it won't mkdir, that's ok
if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh
fi
cd ~/.ssh
echo "Note: This script is self-documenting on how to make an ssh key."
echo "  If you need multiple keys, follow this manually, and look-up how to have multiple"
echo "  ssh keys in git, using the ~/.ssh/config file."
echo ""
echo "If this is your first or default key, hit enter for 'Enter file in which to save key'"
ssh-keygen -b 2048 -t ed25519
# Then for "Enter file in which to save key", hit [Enter]
# Give it a password you'll remember
cp ~/.ssh/id_ed25519.pub ~/.ssh/authorized_keys # All ssh public keys can be placed here, 1 per line, to ssh in
ln -s ~/.ssh/id_ed25519 ~/.ssh/identity # Your default (ssh) <identity> file is now your private-key
ssh-add
echo To test ssh capability
echo If UMN student, or CSELabs student see
echo https://cseit.umn.edu/computer-classrooms/cse-labs-unix-machine-listings
echo 
echo Can ssh into UMN computer like so:
echo "ssh x500@<computer_name> # Then enter UMN password"
echo "ssh surnm001@atlas.cselabs.umn.edu"
echo "Are you sure you want to continue connecting (yes/no)? yes "
echo "surnm001@atlas.cselabs.umn.edu's password:"
echo
if [ -z "$(command -v xclip)" ]; then
  sudo apt-get install xclip
fi
if [ -z "$(command -v git)" ]; then
  sudo apt-get install git
fi
echo Adding an SSH key to your github
echo Go to github, login, and your settings
echo There is an SSH keys tab
echo Click add new ssh key
echo "Give it a good descriptive title, as if you will end up having 6-7 of them (you may)"
echo ~/.ssh/id_ed25519.pub file should be copied
cat ~/.ssh/id_ed25519.pub | xclip
echo "(Copy-) Paste entire contents of file to 'Add key' box"
echo Close window to finish program
sensible-browser https://github.com/settings/keys
echo
echo When you clone a repo, clone using the ssh address instead of the http. 
echo Then when you push/pull, you only need to enter in your ssh key once. 
echo If you use http, you have to re-login on the commandline everytime. 
echo If you accidentally did that, you can run the following code:
echo 
echo "git remote set-url <remote-name (origin?)> <ssh-address>"
echo "git remote set-url --push <remote-name> <ssh-address>"
echo "You can view the configured remotes with `git-remote -v` and branches with `git branch -a`"

#!/usr/bin/env bash
set -euo pipefail

# install packages one by one and exit on first failure

# brews
# echo "### installing brews.."
# while read -r brew; do
#   echo "$brew"
#   brew install "$brew"
# done < brews
#
echo

echo "### installing casks.."
while read -r cask; do
  echo "$cask"
  brew install --cask "$cask"
done < casks

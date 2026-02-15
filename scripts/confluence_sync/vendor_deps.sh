#!/bin/bash
set -e

# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install dependencies into the vendor directory
pip install -r "$DIR/requirements.txt" --target "$DIR/vendor" --upgrade

echo "Dependencies installed to $DIR/vendor"

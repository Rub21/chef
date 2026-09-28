#!/usr/bin/env bash
# Deploy this repo to a server and run Chef in local mode.
# curl -L https://omnitruck.cinc.sh/install.sh | bash -s -- -v 18
# cinc-client --version

# Usage:
#   ./deploy.sh <host> [role]
#
# Example:
#   ./deploy.sh root@1.2.3.4
#   ./deploy.sh root@1.2.3.4 gps-tile-dev
#
# Requirements on the server:
#   - Ubuntu 24.04
#   - cinc installed:  curl -L https://omnitruck.cinc.sh/install.sh | bash -s -- -v 18

set -euo pipefail

HOST="${1:?usage: $0 <user@host> [role]}"
ROLE="${2:-gps-tile-dev}"
REMOTE_DIR="/srv/chef"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Syncing $REPO_DIR to $HOST:$REMOTE_DIR"
rsync -az --delete \
  --exclude ".git" \
  --exclude ".kitchen" \
  --exclude ".bundle" \
  "$REPO_DIR/" "$HOST:$REMOTE_DIR/"

echo "==> Running cinc-client with role[$ROLE]"
ssh "$HOST" "cd $REMOTE_DIR && /usr/bin/cinc-client -z \
  -o 'role[$ROLE]' \
  --config-option data_bag_path=$REMOTE_DIR/test/data_bags"

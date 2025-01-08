#!/bin/sh
# Made by: KorG

# Clone command:
## CLONE='GIT_SSH_COMMAND="/usr/bin/ssh -o ControlMaster=no -i /usr/SHARE/gitsync/_gitsync" git clone --bare'
## eval $CLONE git@github.com:zhmylove/NAME.git github_zhmylove_NAME

die(){ echo "$*" >&2 ;exit 2 ;}

ID="gitsync"
LOG="_$ID.log"
CONF="_$ID.conf"

# read the config file
## SSH_KEY -- path

test "./$ID.sh" = "$0" || die "$0 should be run as ./$ID.sh"

. "$CONF"

test -e "$SSH_KEY" && _KEY="$SSH_KEY"

test -z "$_KEY" && die "Specify SSH_KEY for sync"

export GIT_SSH_COMMAND="/usr/bin/ssh -o ControlMaster=no -i $_KEY"

FAILED=""
DONE=""

# fetch all the bare git repos in cwd
for REPODIR in */refs/ ;do
   REPO="${REPODIR%/refs/}"
   (
      cd "$REPO/"
      git fetch --quiet --all --tags
   ) >/dev/null 2>&1 && DONE="$DONE $REPO" || FAILED="$FAILED $REPO"
done

echo "`LC_ALL=C /bin/date +%F` FAILED:$FAILED DONE:$DONE" >> "$LOG"
tail -20 "$LOG" > "$LOG.new" && mv "$LOG.new" "$LOG"

test -z "$FAILED" && exit 0

/usr/local/bin/MyTelegramSend "FAILED gitsync:$FAILED"
echo "FAILED gitsync:$FAILED" >&2
exit 2

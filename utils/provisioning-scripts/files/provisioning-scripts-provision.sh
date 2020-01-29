#!/bin/sh
#
# Provision a device
#

set -e

log() {
	tag=/sbin/provision.sh
	echo "$tag: $*" >> /tmp/provisioning-scripts.log
	echo "$tag: $*" > /dev/console
	logger -t "$tag" -s "$*"
}

die() {
        local _err=$1
        shift
	log "$@"
        exit $_err
}

if [ "$#" -ne 1 ]; then
	cat <<-EOF
	Usage:

	  provision directory | <provisiningfile>.prov

	This command will read a provisioning file (*.prov) at the informed directory.
	It will try to use <MAC>.prov where <MAC> is any of the device MAC addresses.
	If none is found, it will try to use default.prov.

	MAC uses format xx:xx:xx:xx:xx:xx, with leading zero, all low case, with collon
	as delimiter.
	
	EOF
	exit
fi

INPUT=
if [ -d "$1" ]; then
	board_id=$(ubus call system board | jsonfilter -e @.board_name) || :
	for id in $(cat /sys/class/net/*/address | sort -u) "$board_id" default; do
		[ "$id" ] || continue
		input=$(find "$1" -iname "$id.prov" | head -1)
		if [ -r "$input" ]; then
			INPUT="$input"
			break
		fi
	done
	[ "$INPUT" ] ||
		die 1 "Could not find '<mac>.prov', '<board_id>.prov' or 'default.prov' at '$1'"
else
	[ -r "$1" ] || die 1 "'$1' does not exist or cannot be read!"	
	INPUT="$1"
fi

# Get absolute path
input="$(readlink -f "$INPUT")" ||
	die 1 "Failed to get absolute path of '$INPUT'"
[ -r "$input" ] || die 1 "'$input', obtained from '$INPUT', does not exist or cannot be read!"
INPUT="$input"

log "Using provisioning file '$INPUT'..."

tmpdir="$(mktemp -d -t provision.XXXXXXX)"
trap "rm -rf '$tmpdir'" EXIT

DEVICE_PRIVKEY=/etc/provisioning-scripts/device.privkey
PUBLISHER_PUBKEY=/etc/provisioning-scripts/publisher.pubkey
PROVISIONED_FLAG=/etc/provisioning-scripts/provisioned

GPG=gpg

PUBLISHER_KEY="$PUBLISHER_PUBKEY"
DEVICE_KEY="$DEVICE_PRIVKEY"

out=$(GNUPGHOME="$tmpdir" "$GPG" --quiet --status-fd=1 --armor --import < "$PUBLISHER_KEY") ||
	die 1 "Failed to import '$PUBLISHER_KEY'"
PUBLISHER_KEYID=$(echo "$out" | grep -xE "^\[GNUPG:\] IMPORT_OK 1 .*" | head -1 | cut -d' ' -f 4)
[ "$PUBLISHER_KEYID" ] || die 1 "Failed to get imported fingerprint of '$PUBLISHER_KEY'"

out=$(GNUPGHOME="$tmpdir" "$GPG" --quiet --status-fd=1 --armor --import < "$DEVICE_KEY") ||
	die 1 "Failed to import '$DEVICE_KEY'"
DEVICE_KEYID=$(echo "$out" | grep -xE "^\[GNUPG:\] IMPORT_OK 1 .*" | head -1 | cut -d' ' -f 4)
[ "$DEVICE_KEYID" ] || die 1 "Failed to get imported fingerprint of '$DEVICE_KEY'"

echo "$PUBLISHER_KEYID:6" > "$tmpdir/trust.txt"
GNUPGHOME="$tmpdir" "$GPG" --quiet --import-ownertrust "$tmpdir/trust.txt" ||
	die 1 "Failed to trust $PUBLISHER_KEYID"
echo "$DEVICE_KEYID:6" > "$tmpdir/trust.txt"
GNUPGHOME="$tmpdir" "$GPG" --quiet --import-ownertrust "$tmpdir/trust.txt" ||
	die 1 "Failed to trust $DEVICE_KEYID"

OUTPUT="$tmpdir/backup.tgz"
PRERUN="prerun.sh"

if GNUPGHOME="$tmpdir" "$GPG" --quiet --armor --output "$OUTPUT" --decrypt "$INPUT"; then
	true
else
	err=$?
	if [ -e "$OUTPUT" ]; then
		die "$err" "File was deciphered but something else failed. Probably because signature was not accepted as publisher key did not match."
	else
		die "$err" "File was not deciphered. Probably file was ciphered not with this device pubkey."
	fi
fi

if [ -e "$PROVISIONED_FLAG" ]; then
	die 1 "System already provisioned! Aborting..."
fi

( 
	if tar -C "$tmpdir" xzf "$OUTPUT" "$PRERUN" 2>/dev/null; then
		log "Executing script '$tmpdir/$PRERUN'..." >&2
		chmod +x "$tmpdir/$PRERUN"
		if "$tmpdir/$PRERUN"; then
			true
		else
			err=$?
			die $err "'$tmpdir/$PRERUN' failed. Error code '$err'. Aborting"
		fi
	fi
)

log "Applying backup "$OUTPUT"..."
# Restoring backup file (does not reboot)
sysupgrade --restore-backup "$OUTPUT"

rm -f "/$PRERUN"

OVERLAY_STATE=$(! [ -h /overlay/.fs_state ] || readlink /overlay/.fs_state)
OVERLAY_MOUNTED=$(grep -q ' /overlay ' /proc/mounts && echo 1 || :)

if [ -z "$OVERLAY_MOUNTED" ] || [ "$OVERLAY_STATE" != 2 ]; then
	if [ -z "$OVERLAY_MOUNTED" ]; then
		log "/overlay is not mounted."
	elif [ -z "$OVERLAY_STATE" ]; then
		log "/overlay is mounted but /overlay/.fs_state is missing."
	else
		log "/overlay is mounted but /overlay/.fs_state=$OVERLAY_STATE (!=2)."
	fi
	log "Mark for reboot after it is done (/etc/init.d/done) and overlay is ready."
	echo "reboot" > "$PROVISIONED_FLAG"
else
	true > "$PROVISIONED_FLAG"
	sync
	log "Rebooting system..."
	reboot
fi 

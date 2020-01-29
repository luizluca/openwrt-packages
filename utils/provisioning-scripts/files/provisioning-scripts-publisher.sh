#!/bin/sh
#
# Manage provisioning key and .prov generation
#
#

APPFILE=$(readlink -f "$(which -- "$0")")
APPNAME=$(basename "$APPFILE")

echo_err() {
	echo "$@" >&2
}

die() {
        local _err=$1
        shift
	echo_err "$@"
        exit $_err
}

help() {
	# TODO
	cat <<-EOF
	Usage: $APPNAME [OPTION]... ( generate-device-keys | generate-publish-keys )
	Manage device/publisher key generation and create new .prov files.
	Usage: $APPNAME [OPTION]... ( generate-package | open-package )

	Mandatory arguments to long options are mandatory for short options too.
	  General options:
	  -h, --help                    Show this message


	Device options:
	  -d, --device-pubkey           Specify the device public key used to encrypt
	                                .prov file (written by generate-device-keys used
	                                by generate-device-keys 
	  -D, --device-privkey          Specify the device private key to be stored in
	                                the device (written by generate-device-keys, used by
	                                open-package)
	  -i, --device-id		Specify a device ID for GPG keypair (used by
	                                generate-device-keys).
	  -w, --device-password		Specify a password for device private key (used by
	                                generate-device-keys and open-package). The default
	                                is to not protect the private key.

	
	Publisher options:
	  -I, --publisher-id            Specify a device ID for GPG keypair (used by
	                                generate-publish-keys).
	  -W, --publisher-password      Specify a password for publisher private key (used by
	                                generate-publisher-keys and generate-package). The
	                                default is to not protect the private key.
	  -p, --publisher-pubkey        Specify the publisher public key to be stored in device
	                                used by the device to check .prov signature (written by
	                                generate-publish-keys and used by open-package)
	  -P, --publisher-privkey       Specify the publisher private key to be stored in a
	                                safe place (written by generate-publish-keys and
	                                used by generate-package)


	Examples:	  
  
	  $APPNAME --publisher-pubkey pub.pub --publisher-privkey pub.priv generate-publisher-keys
	  $APPNAME --device-pubkey dev.pub --device-privkey dev.priv generate-device-keys
	  $APPNAME --device-pubkey dev.pub --publisher-privkey pub.priv generate-package config.tgz

	  $APPNAME --device-privkey dev.priv --publisher-pubkey pub.pub open-package config.prov

	EOF
}

DEVICE_ID=generic
PUBLISHER_ID=generic

DEVICE_GEN_PASS=%no-protection
PUBLISHER_GEN_PASS=%no-protection

opts="$(getopt -o '?h' -o 'd:D:i:w:' -o 'I:p:P:W:' --long help -n "$APPNAME" \
	--long device-pubkey:,device-privkey:,device-id:,device-password: \
	--long publisher-pubkey:,publisher-privkey:,publisher-id:,publisher-password: \
	-- "$@")" ||
	exit
eval set -- $opts
while true; do
	case "$1" in
                -h | '-?' | --help ) help; exit 0 ;;
        	-d | --device-pubkey )  DEVICE_PUBKEY="$2"; shift 2 ;;
        	-D | --device-privkey ) DEVICE_PRIVKEY="$2"; shift 2 ;;
		-i | --device-id)	DEVICE_ID=$2; shift 2 ;;
		-w | --device-password)	DEVICE_GEN_PASS="Passphrase: $2" DEVICE_PASS="$2"; shift 2 ;;
        	-p | --publisher-pubkey )  PUBLISHER_PUBKEY="$2"; shift 2 ;;
        	-P | --publisher-privkey ) PUBLISHER_PRIVKEY="$2"; shift 2 ;;
		-I | --publisher-id)	   PUBLISHER_ID=$2; shift 2 ;;
		-W | --publisher-password) PUBLISHER_GEN_PASS="Passphrase: $2" PUBLISHER_PASS="$2"; shift 2 ;;
                -- ) shift; break ;;
                * ) die 1 "Invalid argument '$1'. Try '$APPNAME --help'" ;;
        esac
done

GPG=${GPGBIN:-gpg}
for prog in "$GPG" getopt; do
	if ! which "$prog" &>/dev/null; then
		die 1 "'$prog' was not found. It is required by '$APPNAME'"
	fi
done

if [ -z "$1" ]; then
	die 1 "You need to inform an operation as the first argument. Try '$APPNAME --help'"
fi

OPER="$1"
case "$OPER" in
	generate-device-keys)	
		: ${DEVICE_PUBKEY:?You need to inform device public key location. Use --device-pubkey or see '$APPNAME --help'}
		: ${DEVICE_PRIVKEY:?You need to inform device private key location. Use --device-privkey or see '$APPNAME --help'}
	;;
	generate-publisher-keys)
		: ${PUBLISHER_PUBKEY:?You need to inform publisher public key location. Use --publisher-pubkey or see '$APPNAME --help'}
		: ${PUBLISHER_PRIVKEY:?You need to inform publisher private key location. Use --publisher-privkey or see '$APPNAME --help'}
	;;
	generate-package)
		: ${DEVICE_PUBKEY:?You need to inform device public key location. Use --device-pubkey or see '$APPNAME --help'}
		: ${PUBLISHER_PRIVKEY:?You need to inform publisher private key location. Use --publisher-privkey or see '$APPNAME --help'}
		INPUT=${2:?You need to inform a config file (gzipped tar) as the second argument. Try '$APPNAME --help'}
		if ! [ -e "$INPUT" ]; then
			die 1 "Input file '$INPUT' does not exist"
		fi
		if ! tar tzf "$INPUT" >/dev/null; then
			die 1 "Input file '$INPUT' is not a gzipped TAR"
		fi

		OUTPUT="${3:-${2%.tgz}.prov}"
		if [ -e "$OUTPUT" ]; then
			die 1 "Output file '$OUTPUT' already exists"
		fi
	;;
	open-package)
		: ${DEVICE_PRIVKEY:?You need to inform device private key location. Use --device-privkey or see '$APPNAME --help'}
		: ${PUBLISHER_PUBKEY:?You need to inform publisher public key location. Use --publisher-pubkey or see '$APPNAME --help'}

		INPUT=${2:?You need to inform a provisioning file (.prov) as the second argument. Try '$APPNAME --help'}
		if ! [ -e "$INPUT" ]; then
			die 1 "Input file '$INPUT' does not exist"
		fi
		OUTPUT="${3:-${2%.prov}.tgz}"
		if [ -e "$OUTPUT" ]; then
			die 1 "Output file '$OUTPUT' already exists"
		fi
	;;
	*) die 1 "Invalid operation '$1'. Try '$APPNAME --help'";;
esac

tmpdir=$(mktemp -d -t "$APPNAME.XXXXXXXX")
trap "rm -rf '$tmpdir'" EXIT

case "$OPER" in
	generate-device-keys)    keytype=device
				 keyname="device $DEVICE_ID"
				 keypass="$DEVICE_GEN_PASS"
				 keypriv="$DEVICE_PRIVKEY"
				 keypub="$DEVICE_PUBKEY"
				 keyusage=encrypt
	;;
	generate-publisher-keys) keytype=publisher
	       			 keyname="publisher $PUBLISHER_ID"
				 keypass="$PUBLISHER_GEN_PASS"
				 keypriv="$PUBLISHER_PRIVKEY"
				 keypub="$PUBLISHER_PUBKEY"
				 keyusage=sign

	;;
	generate-package)
		PUBLISHER_KEY="$PUBLISHER_PRIVKEY"
		DEVICE_KEY="$DEVICE_PUBKEY"                                                            
	;;                                                                                                    
	open-package)
		PUBLISHER_KEY="$PUBLISHER_PUBKEY"
		DEVICE_KEY="$DEVICE_PRIVKEY"
	;;
esac
case "$OPER" in
	generate-device-keys|generate-publisher-keys)
		GNUPGHOME="$tmpdir" "$GPG" --gen-key --batch  <<-EOF || die 1 "Failed to generate GPG $keytype key pair"
		%echo Generating a $keytype key
		Key-Type: RSA
		Key-Length: 2048
		Key-Usage: $keyusage
		#Subkey-Type: default
		Name-Real: $keyname
		Expire-Date: 0
		# OpenWrt gpg does not support bzip2 (--compress-algo==3) Z3
		Preferences: S9 S8 S7 S2 H10 H9 H8 H11 H2 Z2 Z1
		$keypass
		%commit
		%echo done
		EOF
		GNUPGHOME="$tmpdir" "$GPG" --armor --export-secret-keys "$keyname" > "$keypriv"
		GNUPGHOME="$tmpdir" "$GPG" --armor --export "$keyname" > "$keypub"
	;;
	generate-package|open-package)
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
	;;
esac
case "$OPER" in
	generate-package)
		GNUPGHOME="$tmpdir" "$GPG" --quiet --armor --output "$OUTPUT" --encrypt --sign \
			${PUBLISHER_PASS:+--passphrase "$PUBLISHER_PASS"} \
			--local-user "$PUBLISHER_KEYID" --recipient "$DEVICE_KEYID" "$INPUT" ||
			die 1 "Failed to cypher and sign '$INPUT' to '$OUTPUT'"
	;;
	open-package)
		if GNUPGHOME="$tmpdir" "$GPG" --quiet --armor --output "$OUTPUT" --decrypt "$INPUT" ${DEVICE_PASS:+--passphrase "$DEVICE_PASS"}; then
			true
		else
			err=$?
			if [ -e "$OUTPUT" ]; then
				die "$err" "File was deciphered but something else failed. Probably because signature was not accepted as publisher key did not match."
			else
				die "$err" "File was not deciphered. Probably file was ciphered not with this device pubkey."
			fi
		fi
	;;
esac

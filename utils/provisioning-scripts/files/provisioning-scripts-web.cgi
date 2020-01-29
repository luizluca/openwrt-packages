#!/bin/sh

log() {
	tag=/www/cgi-bin/provision
	echo "$tag: $*" >> /tmp/provisioning-scripts.log
	echo "$tag: $*" > /dev/console
	logger -t "$tag" -s "$*"
}


read_upload() {
	# Read content
	IFS=$'\r' read -r delim_line

	while true; do
		header_content_disposition= header_content_type=
		while IFS=$'\r' read -r line; do
			key=${line%%:*}; value="${line#*: }"
			case $key in
				Content-Disposition) header_content_disposition="$value";;
				Content-Type) header_content_type="$value";;
				"") break
			esac
		done

		# HACK: cannot use shell for reading binary
		# This will work for a single upload file
		head -c -$((${#delim_line}+6)) >$1
		
		break
		# Read until $delim_line or $delim_line-- is found
		# Cannot do it with shell, because of \0
		blocksize=1024
		while IFS=$'\r' read -r -n $blocksize line; do
			if [ "${line:0:${#delim_line}}" = "$delim_line" ]; then
				break
			fi
			if [ "${#line}" -eq $blocksize ]; then
				echo -n "$line"
			else
				echo -n "$line"$'\r'
			fi
		done | head -c -1 >$1

		if [ "$line" = "$delim_line--" ] || [ "$line" == "" ]; then
			break
		fi
	done
}


printf '\r\n'
cat <<EOF
<html>
	<head>
		<title>Provisioning-scripts</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	</head>
	<body>
		<pre>
$(
if [ "$CONTENT_LENGTH" ] && [ "$CONTENT_LENGTH" -gt 0 ]; then
	# Check if there is enough space
	freespace=$(df -kP /tmp/ | tail -1 | awk '{ print $4 }')	
	if [ $((freespace*1024)) -lt $CONTENT_LENGTH ] ; then
		echo "Not enough free space to upload the file"
	else
		# Create TMP dir
		tmpdir=$(mktemp -d -t provision.XXXXXXX)
		trap "rm -rf '$tmpdir'" EXIT

		log "Uploading provision file to $tmpdir/default.prov"
		read_upload $tmpdir/default.prov
		log "Calling /sbin/provision '$tmpdir/default.prov'"
		flock -n /tmp/provision.lock /sbin/provision "$tmpdir/default.prov"
			log "Failed to call /sbin/provision '$tmpdir/default.prov'"
	fi
else
	echo "Please provide the provision file:"
fi 2>&1)
		</pre>
		<form method="post" action="" enctype="multipart/form-data">
		   <input type="file" name="file" />
		   <input type="submit" />
		</form>
	</body>
</html>
EOF

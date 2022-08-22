#!/bin/bash

if [[ -n "$BUILDER_SSHKEY_URL" ]]; then
	echo "Installing ssh keys for builder"
	install -d -m 755 -o builder -g abuild /home/builder
	install -d -m 700 -o builder -g abuild /home/builder/.ssh
	install -m 600 -o builder -g abuild /dev/null /home/builder/.ssh/authorized_keys

	tmpfile=$(mktemp)
	trap 'rm -f $tmpfile' EXIT
	curl -sf -L "$BUILDER_SSHKEY_URL" > "$tmpfile" &&
		cat "$tmpfile" > /home/builder/.ssh/authorized_keys
fi

if ! [[ -d /home/builder/.abuild ]]; then
	echo "Creating abuild key"
	sudo -u builder abuild-keygen -n -a -i
fi

cp /home/builder/.abuild/*.pub /etc/apk/keys

if ! [[ -f /etc/ssh/ssh_host_rsa_key ]]; then
	for keytype in rsa ecdsa; do
		echo "Generating $keytype host key"
		ssh-keygen -q -t "$keytype" -N '' -f "/etc/ssh/ssh_host_${keytype}_key"
	done
fi

chown -R builder:abuild /src/aports

echo "Running $*"
exec "$@"

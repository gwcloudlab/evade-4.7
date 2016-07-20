#!/bin/sh

until `sudo xl -vvvv remus -Fd -i 30 ubuntu1204 nimbnode11 2>&1|tee remus_log/remus.log`; do
	echo "remus crashed with exit code $?.  Respawning.." >&2
	sleep 1
done

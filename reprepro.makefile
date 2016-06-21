#!/usr/bin/make -f

SHELL=/bin/bash

.PHONY: default includedeb includedeb-debug list-debs list-keys processincoming processincoming-debug sign purge purge-incoming

default: purge includedeb

includedeb:
	# https://github.com/docker/docker/issues/728#issuecomment-30077403
	exec >/dev/tty 2>/dev/tty </dev/tty && reprepro includedeb stable $(REPREPRO_BASE_DIR)/incoming/*.deb

includedeb-debug:
	exec >/dev/tty 2>/dev/tty </dev/tty && GPGME_DEBUG=9 reprepro -V includedeb stable $(REPREPRO_BASE_DIR)/incoming/*.deb

list-debs:
	reprepro list stable

list-keys:
	gpg --list-keys
	gpg --list-secret-key

processincoming:
	exec >/dev/tty 2>/dev/tty </dev/tty && reprepro processincoming default

processincoming-debug:
	exec >/dev/tty 2>/dev/tty </dev/tty && GPGME_DEBUG reprepro -V processincoming default

sign:
	dpkg-sig --sign builder $(REPREPRO_BASE_DIR)/incoming/*.deb

purge:
	rm --force --recursive $(REPREPRO_BASE_DIR)/{db,dists,pool} $(REPREPRO_BASE_DIR)/{logs,tmp}/*

purge-incoming:
	rm --force --recursive $(REPREPRO_BASE_DIR)/incoming/*


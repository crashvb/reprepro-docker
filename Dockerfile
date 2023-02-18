FROM crashvb/nginx:202302180021@sha256:5d51352cd78928288bc98ad1b2829f6a34e83c171b94656623eaa08616ef97fe
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:5d51352cd78928288bc98ad1b2829f6a34e83c171b94656623eaa08616ef97fe" \
	org.opencontainers.image.base.name="crashvb/nginx:202302180021" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing reprepro." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/reprepro-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/reprepro" \
	org.opencontainers.image.url="https://github.com/crashvb/reprepro-docker"

# Install packages, download files ...
RUN docker-apt dpkg-sig make nginx-extras openssh-server reprepro xz-utils

# Configure: nginx
COPY default.nginx /etc/nginx/sites-available/default

# Configure: reprepro
ENV REPREPRO_BASE_DIR=/var/www REPREPRO_HOME=/home/reprepro
COPY *.template *.defaults /usr/local/share/reprepro/
RUN useradd --comment="Reprepro Daemon" --create-home --groups=tty --shell=/bin/bash reprepro && \
	useradd --comment="Reprepro Contributor" --create-home --shell=/bin/bash contrib && \
	echo "REPREPRO_BASE_DIR=${REPREPRO_BASE_DIR}" >> /etc/environment

# Configure: root
COPY reprepro.makefile /home/reprepro/makefile

# Configure: sshd
RUN sed --in-place 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config && \
	rm --force /etc/ssh/ssh_host_* && \
	mkdir --parents /var/run/sshd

# Configure: supervisor
COPY supervisord.sshd.conf /etc/supervisor/conf.d/sshd.conf

# Configure: entrypoint
COPY entrypoint.gnupg /etc/entrypoint.d/20gnupg
COPY entrypoint.reprepro /etc/entrypoint.d/30reprepro
COPY entrypoint.sshc /etc/entrypoint.d/40sshc
COPY entrypoint.sshd /etc/entrypoint.d/10sshd

# Configure: healthcheck
COPY healthcheck.sshd /etc/healthcheck.d/sshd

EXPOSE 22/tcp

VOLUME /etc/ssh /home/contrib/.ssh ${REPREPRO_BASE_DIR}

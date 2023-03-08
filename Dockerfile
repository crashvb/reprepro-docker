FROM crashvb/nginx:202303080204@sha256:12e9f1b44b475dbf5171b2a90d95cb2aab5e159035914163efd9d7d0b140c26f
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:12e9f1b44b475dbf5171b2a90d95cb2aab5e159035914163efd9d7d0b140c26f" \
	org.opencontainers.image.base.name="crashvb/nginx:202303080204" \
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
COPY entrypoint.gnupg /etc/entrypoint.d/gnupg
COPY entrypoint.reprepro /etc/entrypoint.d/reprepro
COPY entrypoint.sshc /etc/entrypoint.d/sshc
COPY entrypoint.sshd /etc/entrypoint.d/sshd

# Configure: healthcheck
COPY healthcheck.sshd /etc/healthcheck.d/sshd

EXPOSE 22/tcp

VOLUME /etc/ssh /home/contrib/.ssh ${REPREPRO_BASE_DIR}

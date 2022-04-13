# reprepro-docker

[![version)](https://img.shields.io/docker/v/crashvb/reprepro/latest)](https://hub.docker.com/repository/docker/crashvb/reprepro)
[![image size](https://img.shields.io/docker/image-size/crashvb/reprepro/latest)](https://hub.docker.com/repository/docker/crashvb/reprepro)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/reprepro-docker.svg)](https://github.com/crashvb/reprepro-docker/blob/master/LICENSE.md)

## Overview

This docker image contains [reprepro](https://wiki.debian.org/SettingUpSignedAptRepositoryWithReprepro).

## Signature Types

The following Debian signature types are compiled from the `debsigs` [man page](https://manpages.debian.org/stretch/debsigs/debsigs.1p.en.html), and [supporting documentation](https://gitlab.com/debsigs/debsigs/blob/master/signing-policy.txt):

 | Signature Type | Description |
 | -------------- | ----------- |
 | archive | An automatically-added signature renewed periodically to ensure that a package downloaded from an online archive is indeed the latest version distributed by the organization. |
 | builder | dpkg-sig signature synonymous with 'maint'. |
 | maint | The signature of the maintainer of the Debian package. This signature should be added by the maintainer before uploading the package. |
 | origin | The official signature of the organization which distributes the package, usually the Debian Project or a GNU/Linux distribution derived from it. This signature may be added automatically. |
 | qa | The signature of the Quality Assurance department. This signature can reduce the damage done if the key for an individual maintainer were to become compromised in some way. |

## Entrypoint Scripts

### sshd

The embedded entrypoint script is located at `/etc/entrypoint.d/10sshd` and performs the following actions:

1. The SSH host keys are generated.

### gnupg

The embedded entrypoint script is located at `/etc/entrypoint.d/20gnupg` and performs the following actions:

1. The GPG keys are imported, or generated using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | REPREPRO\_DESCRIPTION | | _See: reprepro_ |
 | REPREPRO\_URL | | _See: reprepro_ |

2. The ownership and permissions are verified on the following locations: `$GNUPGHOME`.

### reprepro

The embedded entrypoint script is located at `/etc/entrypoint.d/30reprepro` and performs the following actions:

1. A new reprepro configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | REPREPRO\_ARCHITECTURES | amd64 i386 source | The package architectures contained within. |
 | REPREPRO\_CODENAME | stable | The operating system release name. |
 | REPREPRO\_COMPONENTS | main | The packaging areas contained within. |
 | REPREPRO\_COMPRESSION | .bz2 .gz | Available compression formats. |
 | REPREPRO\_DESCRIPTION | Generic APT Repository | The repository description. |
 | REPREPRO\_GPG\_KEY| default | The GPG key to use for signing. |
 | REPREPRO\_URL | packages.generic.com | The repository URL. |

2. The existence, ownership, and permissions are verified on the following configured locations: `DebOverride`, `DscOverride`, and `UDebOverride`.
3. The ownership and permissions are verified on the following locations: `$REPREPRO_BASE_DIR`.

### sshc

The embedded entrypoint script is located at `/etc/entrypoint.d/40sshc` and performs the following actions:

1. The ssh `authorized_keys` file is generated using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | CONTRIB\_AUTHORIZED\_KEYS | | The SSH public keys for the `contrib` user. |

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ entrypoint.d/
│  │  ├─ 10sshd
│  │  ├─ 20gnupg
│  │  ├─ 30reprepro
│  │  └─ 40sshc
│  └─ nginx/
│     └─ sites-available/
│        └─ default
├─ home/
│  ├─ contrib/
│  │  └─ .ssh/
│  │     └─ authorized_keys
│  └─ reprepro/
│     └─ makefile
├─ run/
│  └─ secrets/
│     └─ reprepro.gpg
└─ var/
   └─ www/
      ├─ conf/
      │  ├─ distributions
      │  ├─ incoming
      │  ├─ options
      │  └─ uploaders
      ├─ incoming
      ├─ indices
      ├─ logs
      ├─ project
      └─ tmp
```

### Exposed Ports

* `22/tcp` - sshd listening port.

### Volumes

* `/etc/ssh` - The SSH configuration directory.
* `/home/contrib/.ssh` - The contrib user SSH authorized keys.
* `/var/www` - The reprepro data directory.

## Development

[Source Control](https://github.com/crashvb/reprepro-docker)


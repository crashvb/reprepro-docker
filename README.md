# reprepro-docker

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
 | REPREPRO_DESCRIPTION | | _See: repositry_ |
 | REPREPRO_URL | | _See: repositry_ |

2. The ownership and permissions are verified on the following locations: `$GNUPGHOME`.

### reprepro

The embedded entrypoint script is located at `/etc/entrypoint.d/30reprepro` and performs the following actions:

1. A new reprepro configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | REPREPRO_ARCHITECTURES | amd64 i386 source | The package architectures contained within. |
 | REPREPRO_CODENAME | stable | The operating system release name. |
 | REPREPRO_COMPONENTS | main | The packaging areas contained within. |
 | REPREPRO_COMPRESSION | .bz2 .gz | Available compression formats. |
 | REPREPRO_DESCRIPTION | Generic APT Repository | The repository description. |
 | REPREPRO_GPG_KEY| default | The GPG key to use for signing. |
 | REPREPRO_URL | packages.generic.com | The repository URL. |

2. The existence, ownership, and permissions are verified on the following configured locations: `DebOverride`, `DscOverride`, and `UDebOverride`.
3. The ownership and permissions are verified on the following locations: `$REPREPRO_BASE_DIR`.

### sshc

The embedded entrypoint script is located at `/etc/entrypoint.d/40sshc` and performs the following actions:

1. The ssh `authorized_keys` file is generated using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | CONTRIB_AUTHORIZED_KEYS | | The SSH public keys for the `contrib` user. |

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


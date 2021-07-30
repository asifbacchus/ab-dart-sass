# ab-dart-sass: Dart-SASS Compiler

Containerized deployment of Dart-SASS compiler running on Debian-slim. The container takes input SASS/SCSS files and outputs either regular or compressed CSS files. It can run in ‘one-off’ mode where it processes files and exits or it can sit in the background (default) and process any new/changed input files automatically. All options are set via environment variables passed at runtime.

## Contents

<!-- toc -->

- [Quick-start](#quick-start)
- [Repositories and Signing](#repositories-and-signing)
- [Permissions](#permissions)
  * [Rebuild the container](#rebuild-the-container)
  * [Supply UID/GID at runtime](#supply-uidgid-at-runtime)
- [Mounts](#mounts)
- [Environment variables](#environment-variables)
- [One-shot mode](#one-shot-mode)
- [Final thoughts](#final-thoughts)

<!-- tocstop -->

## Quick-start

```bash
docker run -d --rm -u "123:456" -v /my/scss:/scss:ro -v /my/css:/css docker.asifbacchus.dev/dart-sass/ab-dart-sass:latest
```

- `-d`: Run container in the background and watch for changes to input files.
- `--rm`: Remove container when exited.
- `u "123:456"`: Run container as user with UID=123 and GID=456. This is very likely necessary so the container has write permissions to the output directory on the host! Please refer to the [permissions](#permissions) section for more information.
- `-v /my/scss:/scss:ro`: Mount */my/scss* on the host to */scss* in the container and mark everything as read-only so the container can’t change any source files (it doesn’t, but this is a wise precaution).
- `-v /my/css:/css`: Mount */my/css* on the host to */css* in the container. The container user **must** be able to write to this location!

If you only want to run the container one-time to parse files and output css then exit (i.e. no background listening), then run it with the `oneshot` command as follows:

```bash
docker run -d --rm -u "123:456" -v /my/scss:/scss:ro -v /my/css:/css docker.asifbacchus.dev/dart-sass/ab-dart-sass:latest oneshot
```

## Repositories and Signing

You can download this container either from DockerHub or from my private repository:

| image name                                          | source             |
| --------------------------------------------------- | ------------------ |
| docker.asifbacchus.dev/dart-sass/ab-dart-sass:*tag* | private repository |
| asifbacchus/ab-dart-sass:*tag*                      | DockerHub          |

Images are synced from my private repository to DockerHub so, in rare cases, you may find slightly more up-to-date versions in my repository. All specific point releases (e.g. 1.1 or 1.1.2) will be signed using [CodeNotary](https://www.codenotary.com) and can be verified using their *vcn* tool. Non-specific releases (such as ‘1’, ‘2’ or ‘latest’) are not signed since they are always changing with new updates.

## Permissions

The SASS compiler in the container runs as the limited user ‘*sass*’ with UID=8101 and GID=8101. This means the container user needs permission to read any source files mounted and permission to write to any target output directory. You can either change your environment to grant read and/or write to UID/GID 8101 or you can change the container. Actually, the latter is easier. You have two options: rebuild the container with custom UID/GID values or supply those values at runtime.

### Rebuild the container

In some cases, it might be more desirable to simply rebuild the container with the correct UID/GID for your environment. Simply clone the git repository, set build-args and build the container:

```bash
# change to a location where you can clone stuff
cd /usr/local/src

# clone the repository and change directory
git clone https://git.asifbacchus.dev/ab-docker/dart-sass
cd dart-sass

# build the container with desired UID and/or GID (example: 6001 and 7500, respectively)
docker build --build-arg SASS_UID=6001 --build-arg SASS_GID=7500 -t sass:latest .
```

- `SASS_UID`: Desired UID for container user.
- `SASS_GID`: Desired GID for container user.
- `image:tag`: You can, of course, set this to anything you want. In this example, the image is named ‘sass’ and tagged ‘latest’.

That’s it. Now you just run your custom container instead of mine :-)

### Supply UID/GID at runtime

Perhaps easier and definitely more flexible, you can supply a UID and/or GID at runtime for the container user. Simply run with the `--user "uid:gid"` docker option. For example, let’s run the container as UID 1001 and GID 1001:

```bash
docker run -d --rm --user "1001:1001" -v ~/webstuff/scss:/sass:ro -v ~/webstuff/css:/css docker.asifbacchus.dev/dart-sass/ab-dart-sass:latest
```

Or perhaps you only need to change the GID so the container can write to the output directory (very common scenario):

```bash
docker run -d --rm --user "8101:1001" -v /var/www/scss:/sass:ro -v /var/www/css:/css docker.asifbacchus.dev/dart-sass/ab-dart-sass:latest
```

## Mounts

Since the container needs input files and somewhere to put generated output files, we need two (2) mounts.

| host location          | container mount point |
| ---------------------- | --------------------- |
| /path/to/**scss**      | /scss                 |
| /path/to/write/**css** | /css                  |

- You can mount your scss files as read-only if you want -- the container only ever needs to *read* these files.
- The container **must** have *write* access to the location mounted to */css* otherwise it cannot output the parsed files. Please refer to the [permissions](#permissions) section for more information.

## Environment variables

The container doesn’t have many options for configuration but, the ones that exist are all set via environment variables at runtime:

| variable name                            | values                  | default    |
| ---------------------------------------- | ----------------------- | ---------- |
| SASS_STYLE<br />format for generated CSS | `expanded` `compressed` | compressed |
| TZ<br />set container timezone           | IANA TZ-style timezones | Etc/UTC    |

## One-shot mode

By default, the container is designed to sit in the background and monitor the mounted input directory looking for new/changed files. As soon any changes to the source files are detected, the container generates a new set of output CSS files and saves them to the output directory.

However, you may only want to run this process once and then have the container exit. In that case, you can supply the command `oneshot` to the container. It will read the input directory, compile CSS, write that CSS to the output directory and then exit.

```bash
docker run -d --rm -u "uid:gid" -v /my/scss:/scss:ro -v /my/css:/css docker.asifbacchus.dev/dart-sass/ab-dart-sass:latest oneshot
```

## Final thoughts

That’s it. Sometimes it’s easier to drop a container into an environment and not have to worry about installing a bunch of things on a machine -- especially in the case of developing on machines that are also used for other things. Surprisingly, I couldn’t find an up-to-date container for just parsing SCSS... so I cobbled this together. I hope it’s useful to you also! As always, if you find any bugs or have any suggestions, file an issue on my [private git repo](https://git.asifbacchus.dev/ab-docker/dart-sass) or at [GitHub](https://github.com/asifbacchus/ab-dart-sass).

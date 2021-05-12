# i-d-toolchain

This repository provides a docker image with all the tools installed that
[kramdown-rfc2629](https://github.com/cabo/kramdown-rfc2629) might need.

This makes it possible to generate the XML and other desired formats for
Internet-Drafts without installing any local tools, except of course docker.

This is free and unencumbered software released into the public domain.

## Usage

Here is an example of how to use the docker image to generate text and HTML
versions of the included test markdown document
`draft-i-d-toolchain-test-00.md`, which is expected to be in the current working
directory:
``` shell
docker run \
       --pull always \
       -v $(pwd):/id:delegated \
       --cap-add=SYS_ADMIN \
       ghcr.io/larseggert/i-d-toolchain:latest \
       kdrfc -h -3 draft-i-d-toolchain-test-00.md
```

Make sure the test markdown document exist in your local directory.

Here is a breakdown of what the components of this rather long command are:

* `docker run` executes a given command in a given docker container

* `--pull always` makes sure that the latest published version of the docker
  image provided in this repository is used. This can be omitted, e.g., when
  running without Internet connectivity, but then `docker pull` should be
  occasionally run to update the image.

* `-v $(pwd):/id:delegated` mounts the current directory into the docker
  container at the `/id` mount point. The name of the `/id` mount point **must
  not** be changed, since it is tied to where various caches are being kept. The
  `:delegated` can be omitted, but provides a minor speed-up.

* `--cap-add=SYS_ADMIN` is needed when the draft markdown contains artwork that
  relies on `mermaid` for processing. It can be omitted in other cases, but
  there is no harm in always passing it.

* `ghcr.io/larseggert/i-d-toolchain:latest` is the name of the docker image to
  be run.

* Finally, you can specify a command to run inside the container for some
  file(s) in the current working directory. In this example, we execute
  ``` shell
  kdrfc -h -3 draft-i-d-toolchain-test-00.md
  ```
  which runs `kdrfc` from
  [kramdown-rfc2629](https://github.com/cabo/kramdown-rfc2629) in order to
  convert the markdown document `draft-i-d-toolchain-test-00.md` in the current
  working directory to text and HTML. This can be replaced by any other command
  installed in side the container, as desired.

## Installed components

These are the tools that are currently installed in this image:

* [kramdown-rfc2629](https://github.com/cabo/kramdown-rfc2629) and its
  dependencies:
  * [goat](https://github.com/blampe/goat)
  * [ditaa](https://github.com/stathissideris/ditaa)
  * [mscgen](http://www.mcternan.me.uk/mscgen/)
  * [plantuml](https://plantuml.com)
  * [mermaid](https://github.com/mermaid-js/mermaid-cli)
  * [tex2svg](https://github.com/mathjax/mathjax-node-cli)
  * [asciiTeX](https://github.com/larseggert/asciiTeX)
  * [kgt](https://github.com/katef/kgt)
* [mmark](https://github.com/mmarkdown/mmark)
* [idnits](https://tools.ietf.org/tools/idnits/)
* [rfcdiff](https://tools.ietf.org/tools/rfcdiff/)
* [rfcmarkup](https://tools.ietf.org/tools/rfcmarkup/)

Pull requests adding additional tools to the toolchain are appreciated!

## Common errors

* In case you see the "no basic auth credentials" error
  ```
  docker: Error response from daemon: Head https://ghcr.io/v2/larseggert/i-d-toolchain  /manifests/latest: no basic auth credentials
  ```
  you need to `docker login`, using your GitHub user name and a personal
  access token as the password. The token needs to have at least the
  `read:packages` scope, and [can be generated
  here](https://github.com/settings/tokens/new).
  
  ``` shell
  docker login -u $GITHUB_USERNAME -p $GITHUB_TOKEN ghcr.io
  ```

* If you are able to run docker, but see something similar to
  ```
  `read': No such file or directory @ rb_sysopen - draft-i-d-toolchain-test-00.md (Errno::ENOENT)
  from /usr/lib/ruby/gems/2.7.0/gems/kramdown-rfc2629-1.3.37/bin/kramdown-rfc2629:320:in `<top (required)>'
  from /usr/bin/kramdown-rfc2629:23:in `load'
  from /usr/bin/kramdown-rfc2629:23:in `<main>'
  *** kramdown-rfc failed, status 1
  ```
  the given file (here, `draft-i-d-toolchain-test-00.md`) is not present in the
  current working directory.
  

# build asciitex in build image
FROM    alpine:latest
RUN     apk add --no-cache \
                build-base \
                cmake \
                gcc \
                git \
                make
ENV     CURL_FLAGS="-v -L --retry 999 --retry-all-errors --retry-max-time 999 -C -"
RUN     git clone --recursive --depth=1 https://github.com/larseggert/asciiTeX.git
RUN     cmake -E make_directory build
RUN     cmake -B /tmp -DCMAKE_BUILD_TYPE=Release asciiTeX
RUN     cmake --build /tmp --config Release
RUN     cmake --install /tmp


# build wdiff
RUN     apk add --no-cache curl gawk texinfo diffutils
RUN     curl $CURL_FLAGS -o wdiff.tgz https://ftp.gnu.org/gnu/wdiff/wdiff-latest.tar.gz
RUN     mkdir -p /tmp/wdiff /wdiff
RUN     tar xv --strip-components=1 -C /wdiff -f wdiff.tgz
WORKDIR /wdiff
RUN     ./configure --prefix /tmp/wdiff
RUN     make install
WORKDIR /

# build kgt
RUN     apk add --no-cache bmake
RUN     git clone --recursive --depth=1 https://github.com/katef/kgt.git
WORKDIR /kgt
RUN     bmake -r install
WORKDIR /

FROM    alpine:latest
LABEL   maintainer="Lars Eggert <lars@eggert.org>"

# install asciitex and wdiff to final image
COPY    --from=0 /usr/local/bin /usr/local/bin
COPY    --from=0 /tmp/wdiff /
ENV     CURL_FLAGS="-v -L --retry 999 --retry-all-errors --retry-max-time 999 -C -"

# install idnits
RUN     apk add --no-cache bash curl gawk aspell aspell-en
# TODO: we may want to install languagetool, too
RUN     curl $CURL_FLAGS -o idnits.tgz https://tools.ietf.org/tools/idnits/idnits-2.16.05.tgz
RUN     tar xv --strip-components=1 -C /bin -f idnits.tgz
RUN     rm idnits.tgz

# install mmark
RUN     curl $CURL_FLAGS -o mmark.tgz https://github.com/mmarkdown/mmark/releases/download/v2.2.10/mmark_2.2.10_linux_amd64.tgz
RUN     tar xv -C /bin -f mmark.tgz
RUN     rm mmark.tgz

# install xml2rfc
RUN     apk add --no-cache \
                py3-appdirs \
                py3-configargparse \
                py3-html5lib \
                py3-jinja2 \
                py3-lxml \
                py3-pip \
                py3-pycountry \
                py3-pyflakes \
                py3-requests \
                py3-setuptools \
                py3-six \
                py3-yaml
RUN     pip install xml2rfc

# install rfcmarkup
RUN     curl $CURL_FLAGS -o /bin/rfcmarkup https://tools.ietf.org/svn/src/rfcmarkup/rfcmarkup
RUN     chmod a+x /bin/rfcmarkup

# install rfcdiff
RUN     apk add --no-cache wget coreutils gawk diffutils
RUN     curl $CURL_FLAGS -o /bin/rfcdiff https://tools.ietf.org/svn/src/rfcdiff/rfcdiff
RUN     chmod a+x /bin/rfcdiff

# install kramdown-rfc2629
RUN     apk add --no-cache ruby
RUN     gem install kramdown-rfc2629
ENV     KRAMDOWN_REFCACHEDIR=/tmp

# install tex2svg
RUN     apk add --no-cache npm
RUN     npm install -g mathjax-node-cli

# install svgcheck
RUN     pip install svgcheck

# install goat
RUN     apk add --no-cache go git
ENV     GOPATH=/
RUN     go get github.com/blampe/goat

# install ditaa
RUN     apk add --no-cache openjdk11 ttf-dejavu
RUN     curl $CURL_FLAGS -o /bin/ditaa.jar https://github.com/stathissideris/ditaa/releases/download/v0.11.0/ditaa-0.11.0-standalone.jar
RUN     echo '#! /bin/sh' > /bin/ditaa
RUN     echo 'java -jar /bin/ditaa.jar $@' >> /bin/ditaa
RUN     chmod a+x /bin/ditaa

# install mscgen
RUN     curl $CURL_FLAGS -o mscgen.tgz http://www.mcternan.me.uk/mscgen/software/mscgen-static-0.20.tar.gz
RUN     tar xv --strip-components=1 -f mscgen.tgz
RUN     rm mscgen.tgz

# install plantuml
RUN     apk add --no-cache graphviz ttf-droid ttf-droid-nonlatin curl
RUN     curl $CURL_FLAGS -o /bin/plantuml.jar http://sourceforge.net/projects/plantuml/files/plantuml.jar/download
RUN     echo '#! /bin/sh' > /bin/plantuml
RUN     echo 'java -jar /bin/plantuml.jar $@' >> /bin/plantuml
RUN     chmod a+x /bin/plantuml

# install mermaid
RUN     apk add --no-cache chromium
ENV     PUPPETEER_SKIP_DOWNLOAD=1
ENV     PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser"
RUN     npm install -g @mermaid-js/mermaid-cli

# make a user to run things under, and make their home directory /id
RUN     adduser --disabled-password --no-create-home --home /id user user
USER    user
WORKDIR /id

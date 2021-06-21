# build asciitex in build image
FROM    alpine:latest
RUN     apk add --no-cache \
                build-base \
                cmake \
                gcc \
                git \
                make
ENV     CURL="curl -L --retry 999 --retry-all-errors --retry-max-time 999 -O -C -"
RUN     git clone --recursive --depth=1 https://github.com/larseggert/asciiTeX.git
RUN     cmake -E make_directory build
RUN     cmake -B /tmp -DCMAKE_BUILD_TYPE=Release asciiTeX
RUN     cmake --build /tmp --config Release
RUN     cmake --install /tmp


# build wdiff
RUN     apk add --no-cache curl gawk texinfo diffutils
RUN     $CURL https://ftp.gnu.org/gnu/wdiff/wdiff-latest.tar.gz
RUN     mkdir -p /tmp/wdiff /wdiff
RUN     tar xv --strip-components=1 -C /wdiff -f wdiff-latest.tar.gz
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
ENV     CURL="curl -L --retry 999 --retry-all-errors --retry-max-time 999 -O -C -"

# install idnits
RUN     apk add --no-cache bash curl gawk aspell aspell-en
# TODO: we may want to install languagetool, too
RUN     $CURL https://tools.ietf.org/tools/idnits/idnits-2.16.05.tgz
RUN     tar xv --strip-components=1 -C /bin -f idnits-2.16.05.tgz
RUN     rm idnits-2.16.05.tgz

# install mmark
RUN     $CURL https://github.com/mmarkdown/mmark/releases/download/v2.2.10/mmark_2.2.10_linux_amd64.tgz
RUN     tar xv -C /bin -f mmark_2.2.10_linux_amd64.tgz
RUN     rm mmark_2.2.10_linux_amd64.tgz

# install ietf-reviewtool
RUN     apk add --no-cache py3-pip openjdk11
RUN     $CURL https://www.languagetool.org/download/LanguageTool-stable.zip
RUN     unzip -d languagetool LanguageTool-stable.zip
RUN     rm LanguageTool-stable.zip
ENV     LTP_PATH=/languagetool
RUN     pip install ietf-reviewtool

# install xml2rfc
RUN     apk add --no-cache \
                py3-appdirs \
                py3-configargparse \
                py3-html5lib \
                py3-jinja2 \
                py3-lxml \
                py3-pycountry \
                py3-pyflakes \
                py3-requests \
                py3-setuptools \
                py3-six
RUN     pip install xml2rfc

# install rfcmarkup
WORKDIR /bin
RUN     $CURL https://tools.ietf.org/svn/src/rfcmarkup/rfcmarkup
RUN     chmod a+x rfcmarkup

# install rfcdiff
RUN     apk add --no-cache wget coreutils gawk diffutils
WORKDIR /bin
RUN     $CURL https://tools.ietf.org/svn/src/rfcdiff/rfcdiff
RUN     chmod a+x rfcdiff

# install kramdown-rfc2629
RUN     apk add --no-cache ruby
RUN     gem install kramdown-rfc2629 net-http-persistent

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
WORKDIR /bin
RUN     $CURL https://github.com/stathissideris/ditaa/releases/download/v0.11.0/ditaa-0.11.0-standalone.jar
RUN     echo '#! /bin/sh' > ditaa
RUN     echo 'java -jar /bin/ditaa-0.11.0-standalone.jar $@' >> ditaa
RUN     chmod a+x ditaa

# install mscgen
WORKDIR /
RUN     $CURL http://www.mcternan.me.uk/mscgen/software/mscgen-static-0.20.tar.gz
RUN     tar xv --strip-components=1 -f mscgen-static-0.20.tar.gz
RUN     rm mscgen-static-0.20.tar.gz

# install plantuml
RUN     apk add --no-cache graphviz ttf-droid ttf-droid-nonlatin curl
WORKDIR /bin
RUN     $CURL http://sourceforge.net/projects/plantuml/files/plantuml.jar
RUN     echo '#! /bin/sh' > plantuml
RUN     echo 'java -jar /bin/plantuml.jar $@' >> plantuml
RUN     chmod a+x plantuml

# install mermaid
RUN     apk add --no-cache chromium
ENV     PUPPETEER_SKIP_DOWNLOAD=1
ENV     PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser"
RUN     npm install -g @mermaid-js/mermaid-cli

# install various other things that i-d-template depends on
RUN     apk add --no-cache make enscript ghostscript
RUN     pip install codespell

# install things needed for the web service
RUN     apk add --no-cache \
                cairo-dev \
                font-noto \
                gcc \
                gdk-pixbuf-dev \
                jpeg-dev \
                libffi-dev \
                musl-dev \
                pango-dev \
                python3-dev \
                zlib-dev
RUN     pip install wheel
RUN     pip install WeasyPrint pycairo
WORKDIR /www
RUN     $CURL https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/css/bootstrap.min.css
RUN     $CURL https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/css/bootstrap.min.css.map
RUN     $CURL https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/js/bootstrap.bundle.min.js
RUN     $CURL https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/js/bootstrap.bundle.min.js.map
RUN     $CURL https://code.jquery.com/jquery-3.6.0.min.js
RUN     $CURL https://www.ietf.org/media/images/ietf-logo.original.jpg
RUN     $CURL https://icons.getbootstrap.com/assets/icons/file-earmark-arrow-up.svg
RUN     $CURL https://icons.getbootstrap.com/assets/icons/bug.svg
RUN     $CURL https://icons.getbootstrap.com/assets/icons/github.svg
COPY    ui/ .

# make a user to run things under, and make their home directory /id
RUN     adduser --disabled-password --no-create-home --home /id user user
USER    user
WORKDIR /id

# start the I-D converter webservice by default
EXPOSE  8000
ENV     XML2RFC_REFCACHEDIR=/tmp/xml2rfc
ENV     KRAMDOWN_REFCACHEDIR=/tmp/xml2rfc
CMD     echo Open http://localhost:8000 to access the I-D Converter && \
        cd /www && \
        python3 -m http.server --cgi

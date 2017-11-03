FROM rakudo-star:latest

RUN buildDeps=' \
        build-essential \
        cpanminus \
        npm \
    ' \
    runtimeDeps=' \
        graphviz \
        make \
        nodejs \
        ruby-sass \
    ' \
    testDeps=' \
        aspell \
    ' \

    && set -x \
    && apt-get update \
    && apt-get --yes --no-install-recommends install $buildDeps $runtimeDeps $testDeps \
    && rm -rf /var/lib/apt/lists/* \

    && cpanm -vn Mojolicious \
    && zef install Test::META \

    && ln -s /usr/bin/nodejs /usr/bin/node \
    && npm cache clean -f \
    && npm install -g n \
    && n stable \

    && apt-get purge --yes --auto-remove $buildDeps

WORKDIR /perl6/doc/
EXPOSE  3000

CMD bash -c 'make test && make html && ./app-start'

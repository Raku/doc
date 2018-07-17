FROM rakudo-star:latest

RUN buildDeps='         \
        build-essential \
        cpanminus       \
    '                   \
    runtimeDeps=' \
        graphviz  \
        make      \
        ruby-sass \
    '             \
    testDeps=' \
        aspell \
    ' \
      \
    && set -x \
              \
    && apt-get update \
    && apt-get --yes --no-install-recommends install $buildDeps $runtimeDeps $testDeps \
    && rm -rf /var/lib/apt/lists/* \
                                   \
    && cpanm -vn Mojolicious  \
    && zef install Test::META \
                              \
    && n=/usr/local/bin/n \
    && curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n > "$n" \
    && chmod +x "$n"      \
    && n stable

WORKDIR /perl6/doc
EXPOSE  3000

CMD make test && make html && ./app-start

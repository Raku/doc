FROM jjmerelo/rakudo-nostar:latest

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
    && apt-get update \
    && apt-get --yes --no-install-recommends install $buildDeps $runtimeDeps $testDeps \
    && rm -rf /var/lib/apt/lists/* \
                                   \
    && cpanm -vn Mojolicious  \
    && n=/usr/local/bin/n \
    && curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n > "$n" \
    && chmod +x "$n"      \
    && n stable

WORKDIR /perl6/doc
COPY . .
RUN zef install --deps-only .

RUN make test && make html

EXPOSE 3000

CMD ["morbo", "-w", "assets/sass", "-w", "assets/js", "-w", "html/js/search.js", "-l", "http://0.0.0.0:3000", "app.pl"]

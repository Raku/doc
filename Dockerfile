FROM rakudo-star:latest

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get --yes --no-install-recommends install \
    ruby-sass \
    cpanminus \
    build-essential \
    nodejs \
    graphviz \
    ;

RUN zef install Pod::To::HTML Pod::To::BigPage

RUN cpanm -vn Mojolicious

RUN cpanm -vn CSS::Sass Mojolicious::Plugin::AssetPack

RUN mkdir /doc

WORKDIR /doc

EXPOSE 3000

CMD bash -c "make init-highlights && perl6 htmlify.p6 && perl app.pl daemon"

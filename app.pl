#!/usr/bin/env perl

use File::Spec::Functions 'catfile';
use Mojolicious 6.66;
use Mojolicious::Lite;
use Mojolicious::Plugin::AssetPack 1.15;
use Mojo::Util qw/spurt/;

app->static->paths(['html']);

if ( eval { require CSS::Sass; require CSS::Minifier::XS; 1; } ) {
    plugin AssetPack => { pipes => [qw/Sass JavaScript Combine/] };
    app->asset->process('app.css' => 'sass/style.scss' );

    my $style_sheet = catfile qw{html css style.css};
    app->log->debug(
        "Processing SASS and copying the results over to $style_sheet..."
    );
    spurt app->asset->processed('app.css')->map("content")->join
        => $style_sheet;
    app->log->debug('...Done');
}
else {
    app->log->debug(
        'Install CSS::Sass and CSS::Minifier::XS to enable SASS processor'
    );
}

## ROUTES

get '/' => sub { shift->reply->static('/index.html') };

get '*dir' => sub {
    my $self = shift;
    ( my $dir = $self->param('dir') ) =~ s{/$}{};
    $self->reply->static("/$dir.html");
};

app->start;

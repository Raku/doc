#!/usr/bin/env perl

use File::Spec::Functions 'catfile';
use Mojolicious 6.58;
use Mojolicious::Lite;
use Mojo::Util qw/spurt/;

app->static->paths(['html']);

my $has_extra_modules = eval {
    require CSS::Sass;
    require CSS::Minifier::XS;
    require Mojolicious::Plugin::AssetPack;
    1;
};

if ( $has_extra_modules ) {
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
    app->log->debug( 'Install CSS::Sass, CSS::Minifier::XS, and'
        . ' Mojolicious::Plugin::AssetPack to enable SASS processor'
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

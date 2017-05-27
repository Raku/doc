#!/usr/bin/env perl

use File::Spec::Functions 'catfile';
use Mojolicious 6.58;
use Mojolicious::Lite;
use Mojo::Util qw/spurt/;

app->static->paths(['html']);

if ( eval { require Mojolicious::Plugin::AssetPack; 1; } ) {
    unless ( eval { require CSS::Sass } ) {
        app->log->debug('CSS::Sass not loaded. Relying on `sass` program'
            . ' to process SASS');
    }

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
    app->log->debug( 'Install Mojolicious::Plugin::AssetPack to enable SASS'
        . ' processor. You will also need CSS::Sass module or have `sass`'
        . ' command working'
    );
}

app->hook(
    before_dispatch => sub {
        my $c = shift;
        $c->req->url->path( $c->req->url->path =~ s/::/\$COLON\$COLON/gr )
            if $c->req->url->path =~ m{^/type/} and $^O =~ m/MSWin/i;
    }
);

## ROUTES

get '/' => sub { shift->reply->static('/index.html') };

get '*dir' => sub {
    my $self = shift;
    ( my $dir = $self->param('dir') ) =~ s{/$}{};
    $self->reply->static("/$dir.html");
};

app->start;

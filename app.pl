#!/usr/bin/env perl

use File::Spec::Functions 'catfile';
use Mojolicious 7.31;
use Mojolicious::Lite;
use File::Copy;
use Mojo::File qw/path/;
use File::Temp qw/tempfile/;

my $mode = shift || 'dev';
app->mode($mode eq 'assets' ? 'production' : 'development');

app->static->paths(['html']);
if ( eval { require Mojolicious::Plugin::AssetPack; 1; } ) {
    unless ( eval { require CSS::Sass } ) {
        app->log->debug('CSS::Sass not loaded. Relying on `sass` program'
            . ' to process SASS');
    }
    gen_assets();
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

$mode eq 'assets' and app->start(qw/eval exit/) or app->start;


sub gen_assets {
    my $app = shift;

    app->plugin(AssetPack => { pipes => [qw/Sass JavaScript Combine/]});

    app->asset->process(
        'app.css' => qw{
            /sass/style.scss
        },
    );
    app->asset->process(
        'app.js' => qw{
            /js/jquery-3.1.1.min.js
            /js/jquery-ui.min.js
            /js/jquery.tablesorter.js
            /js/main.js
        },
    );

    app->log->info('Copying assets...');
    my ($temp_css, $temp_js) = ((tempfile)[1], (tempfile)[1]);
    Mojo::File->new($temp_css)->spurt(
        join "\n", @{app->asset->processed('app.css')->map(sub {$_->content})}
    );
    Mojo::File->new($temp_js)->spurt(
        join "\n", @{app->asset->processed('app.js')->map(sub {$_->content})}
    );
    copy $temp_css, 'html/css/app.css'
        or app->log->warn("Copying CSS failed: $!");
    copy $temp_js,  'html/js/app.js'
        or app->log->warn("Copying JS failed: $!");
    app->log->info('...done');

}

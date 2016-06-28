#!/usr/bin/env perl

use CSS::Sass 3.3.4;
use CSS::Minifier::XS 0.09;
use File::Spec::Functions 'catfile';
use Mojolicious 6.66;
use Mojolicious::Lite;
use Mojolicious::Plugin::AssetPack 1.15;
use Mojo::Util qw/spurt/;

app->static->paths(['html']);

plugin AssetPack => { pipes => [qw/Sass JavaScript Combine/] };
app->asset->process('app.css' => 'sass/style.scss' );

my $style_sheet = catfile qw{html css style.css};
app->log
    ->debug("Processing SASS and copying the results over to $style_sheet...");
spurt app->asset->processed('app.css')->map("content")->join => $style_sheet;
app->log->debug('...Done');

## ROUTES

get '/' => sub { shift->reply->static('/index.html') };

get '*dir' => sub {
    my $self = shift;
    ( my $dir = $self->param('dir') ) =~ s{/$}{};
    $self->reply->static("/$dir.html");
};

app->start;

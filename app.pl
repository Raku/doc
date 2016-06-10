#!/usr/bin/env perl

use Mojolicious::Lite;

app->static->paths(['html']);

get '/' => sub { shift->reply->static('/index.html') };

get '*dir' => sub {
    my $self = shift;
    ( my $dir = $self->param('dir') ) =~ s{/$}{};
    $self->reply->static("/$dir.html");
};

app->start;

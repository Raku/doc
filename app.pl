#!/usr/bin/env perl

use Mojolicious::Lite;

app->static->paths(['html']);

get '(*dir)/:file' => sub {
    my $self = shift;
    my $dir  = $self->param('dir');
    my $file = $self->param('file');
    return $self->redirect_to("/$dir/$file.html");
};

get '(*dir)/' => sub {
    my $self = shift;
    my $dir  = $self->param('dir');
    return $self->redirect_to("/$dir.html");
};

get '/' => sub {
    my $self = shift;
    return $self->redirect_to('/index.html');
};

app->start;

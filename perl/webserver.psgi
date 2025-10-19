#!/usr/bin/perl
use strict;
use warnings;

use Plack::App::Directory;
my $app = Plack::App::Directory->new({ 
    root => "htdocs" 
})->to_app;
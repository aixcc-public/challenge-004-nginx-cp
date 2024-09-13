#!/usr/bin/perl

# (C) Maxim Dounin

# Tests for the prefer HTTP header

###############################################################################

use warnings;
use strict;

use Test::More;

BEGIN { use FindBin; chdir($FindBin::Bin); }

use lib 'lib';
use Test::Nginx;

###############################################################################

select STDERR; $| = 1;
select STDOUT; $| = 1;

my $t = Test::Nginx->new()->has(qw/http charset/)->plan(4);

$t->write_file_expand('nginx.conf', <<'EOF');

%%TEST_GLOBALS%%

daemon off;

events {
}

http {
    %%TEST_GLOBALS_HTTP%%

    server {
        listen       127.0.0.1:8080;
        server_name  localhost;
    }
}

EOF

$t->write_file('t1.html', "<html><body>Hello World</body></html>");
$t->run();
###############################################################################

my $t1;

$t1 = http_from('/t1.html', 'From: test@test.com');
like($t1, qr/ 200 /, 'from request - 200 OK');
like($t1, qr/Content-Length: 37/, 'from request - correct length');
like($t1, qr/Content-Type: text\/html/, 'from request - correct type');

$t1 = http_from('/t1.html', 'From: te@st@test.com');
like($t1, qr/ 400 /, 'from request - 400 bad request');

###############################################################################

sub http_from {
	my ($url, $extra) = @_;
	return http(<<EOF);
GET $url HTTP/1.1
Host: localhost
Connection: close
$extra

EOF
}

###############################################################################

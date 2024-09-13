#!/usr/bin/perl

# (C) Maxim Dounin

# Tests for the Range HTTP header

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

my $t = Test::Nginx->new()->has(qw/http charset/)->plan(14);

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

$t1 = http_reverse('/t1.html', 'Range: bytes=-r,3-10');
like($t1, qr/ 206 /, 'reverse request - 206 partial');
like($t1, qr/Content-Length: 8/, 'reverse request - correct length');
like($t1, qr/Content-Range: bytes 3-10\/37/, 'reverse request - correct range');
like($t1, qr/Content-Type: text\/html/, 'reverse request - correct type');
like($t1, qr/ydob<>lm/, 'reverse range request - correct body');

$t1 = http_reverse('/t1.html', 'Range: bytes=-r,3-10,11-15,-r,17-23');
like($t1, qr/ 206 /, 'reverse request - 206 partial');
like($t1, qr/Content-Length: 299/, 'reverse request - correct length');
like($t1, qr/Content-Range: bytes 3-10\/37/, 'reverse request - correct range');
like($t1, qr/Content-Type: text\/html/, 'reverse request - correct type');
like($t1, qr/ydob<>lm/, 'reverse range request - correct body');

like($t1, qr/Content-Range: bytes 11-15\/37/, 'reverse request - correct range');
like($t1, qr/>Hell/, 'reverse range request - correct body');

like($t1, qr/Content-Range: bytes 17-23\/37/, 'reverse request - correct range');
like($t1, qr/<dlroW/, 'reverse range request - correct body');

###############################################################################

sub http_reverse {
	my ($url, $extra) = @_;
	return http(<<EOF);
GET $url HTTP/1.1
Host: localhost
Connection: close
$extra

EOF
}

###############################################################################

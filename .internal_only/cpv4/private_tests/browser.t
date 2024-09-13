#!/usr/bin/perl

# (C) Maxim Dounin

# Tests for user agent specific cookies module.

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

$t->write_file('t1.html', '<html><body>Hello world</body></html>');
$t->run();

###############################################################################

my $t1;

$t1 = http_browser_cookie('/t1.html', 'Safari/1234 Mac OS X');
like($t1, qr/ 200 /, 'browser request - 200 good reply');
like($t1, qr/Browser-Cookie:/, 'browser request - found field');

$t1 = http_browser_cookie('/t1.html', 'Firefox');
like($t1, qr/ 200 /, 'browser request - 200 good reply');
unlike($t1, qr/Browser-Cookie:/, 'browser request - should not have found field');

###############################################################################

sub http_browser_cookie {
	my ($url, $extra) = @_;
	return http(<<EOF);
GET $url HTTP/1.1
Host: localhost
Connection: close
Cookie: foo
User-Agent: $extra

EOF
}

###############################################################################

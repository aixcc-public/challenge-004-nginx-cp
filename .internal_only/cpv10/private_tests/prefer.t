#!/usr/bin/perl

# (C) Maxim Dounin

# Tests for prefer header.

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

my $t = Test::Nginx->new()->has(qw/http charset/)->plan(2);

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

$t1 = http_prefer('/t1.html', 'Prefer: test');
like($t1, qr/ 200 /, 'prefer request - 200 good reply');
like($t1, qr/Prefer: test/, 'prefer request - found field');

###############################################################################

sub http_prefer {
	my ($url, $extra) = @_;
	return http(<<EOF);
GET $url HTTP/1.1
Host: localhost
Connection: close
$extra

EOF
}

###############################################################################

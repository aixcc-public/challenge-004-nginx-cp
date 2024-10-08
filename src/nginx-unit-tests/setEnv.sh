# Test suite for nginx.

# Use prove to run tests as one usually do for perl tests.  Individual tests
# may be run as well.

# Note: tests run nginx (and backend daemons if needed) listening on localhost
# and may use various ports in 8000 .. 8999 range.

# Usage:

    export TEST_NGINX_BINARY=~/nginx-1.24.0/projects/nginx/nginx-1.24.0/objs/nginx

# By default tests expect nginx binary to be at ../nginx/objs/nginx.

# Environment variables:

# TEST_NGINX_BINARY

#     Sets path to nginx binary to be tested, defaults to "../nginx/objs/nginx".

# TEST_NGINX_MODULES

#     Sets path to modules directory, defaults to dirname of TEST_NGINX_BINARY.

# TEST_NGINX_VERBOSE

#     Be a bit more verbose (in particular, print requests sent and responses
#     got from nginx).  Note that this requires prove -v (or HARNESS_VERBOSE).

# TEST_NGINX_LEAVE

#     If set, temporary directory with configs and logs won't be deleted on test
#     completion.  Useful for debugging.

# TEST_NGINX_CATLOG

#     Cat error log to stdout after test completion.  Useful for debugging.

# TEST_NGINX_UNSAFE

#     Run unsafe tests.

# TEST_NGINX_GLOBALS

#     Sets additional directives in main context.

# TEST_NGINX_GLOBALS_HTTP

#     Sets additional directives in http context.

# TEST_NGINX_GLOBALS_STREAM

#     Sets additional directives in stream context.

# Happy testing!
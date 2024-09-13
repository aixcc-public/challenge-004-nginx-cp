# Overview

ID: cpv14<br>
Type: [CWE-125](https://cwe.mitre.org/data/definitions/125.html) Out of Bounds Read<br>
Sanitizer: AddressSanitizer: global-buffer-overflow<br>

# Details

This patch modifies the `ngx_http_script.c` file to add a check for the length of the rewritten URI in the `ngx_http_script_regex_end_code` function. If the length of the buffer containing the rewritten URI exceeds 2000 characters, it logs an error message indicating that the URI is too long, sets the instruction pointer to `ngx_http_script_exit`, and changes the response status to `NGX_HTTP_INTERNAL_SERVER_ERROR`. This prevents the processing of excessively long rewritten URIs and helps maintain server stability and security. In this case, prematurely setting the script engine to exit with a `NGX_HTTP_INTERNAL_SERVER_ERROR` results in `e->ip` (instruction pointer) attempting to call a wrong function causing a segfault.<br>

Difficulty to Discover (easy, medium, hard): Hard<br>
Difficulty to Patch (easy, medium, hard): Easy<br>

This vulnerability is difficult to find because the script engine functions are being called via a pointer. Pointers to functions allow for indirect calls, where the function being called is determined at runtime based on the value of the pointer. This makes it less straightforward to trace and verify which function is actually being called at any given point in the code. In a large codebase, especially one involving multiple layers of function pointers or complex pointer manipulations, tracing the origin and usage of a pointer can be non-trivial.<br>

A proper patch would make sure that when an error is found where exit from the current function is required, the error handling correctly returns from the function to prevent any abnormal behavior in the program. As such, simply adding a return after catching the "too large buffer" error will suffice.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

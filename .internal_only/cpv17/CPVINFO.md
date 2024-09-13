# Overview

ID: cpv17<br>
Type: [CWE-416](https://cwe.mitre.org/data/definitions/416.html) Use After Free<br>
Sanitizer: AddressSanitizer: heap-use-after-free<br>

# Details

A new SMTP response message for the NOOP command is added. The NOOP command handling is integrated into the `ngx_mail_smtp_auth_state` function. The `ngx_mail_smtp_noop` function is defined, which checks if the number of arguments exceeds 10. If so, it sets an invalid argument error and closes the connection. Otherwise, it responds with the `smtp_noop` message. The function appears to handle this correctly by first closing the connection and then destroying the pool. However, since `NGX_ERROR` gets returned, it is caught by another check that then calls `ngx_mail_session_internal_server_error`. This function attempts to access the freed connection structure, which leads to a crash via a UAF.<br>

Difficulty to Discover (easy, medium, hard): Hard<br>
Difficulty to Patch (easy, medium, hard): Easy<br>

The nature of a Use-After_free vulnerability is what makes it difficult to find (especially if all you have access to is the source code). This is due to the fact that large and complex codebases can make it difficult to track memory allocations and deallocations, leading to potential use-after-free issues being overlooked. Manual code review relies on the thoroughness and expertise of the reviewer, but humans can miss these bugs, especially in complex or unfamiliar code.<br>

A good patch will ensure that no references to the freed memory are accessed after the `ngx_destroy_pool` call. This can easily be done by simply not prematurely closing the connection (assuming the reviewer knows that `ngx_mail_close-connection` destroys the memory pool). This is because closing a connection usually occurs in the handler of each module, and not the functions called by the handler. By doing this we ensure that any subsequent access to this pointer will be safely handled, thereby preventing a use-after-free scenario. This will look like the removal of the line of code that calls `ngx_mail_close_connection` in `ngx_mail_smtp_noop`.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

# Overview

ID: cpv10<br>
Type: [CWE-415](https://cwe.mitre.org/data/definitions/415.html) Double Free<br>
Sanitizer: AddressSanitizer: attempting double-free<br>

# Details

This CPV introduces support for the `Prefer` header in NGINX. It modifies the header filter module to account for the `Prefer` header's length and include it in the response if present in the request. The CPV also updates the request processing code to handle the `Prefer` header by declaring and implementing a new function, `ngx_http_process_prefer`, which processes this header, checks for duplicates, logs appropriately, and allocates memory for storing the header. Additionally, the `ngx_http_headers_in_t` structure is updated to include a field for the `Prefer` header, ensuring proper storage and handling within the request lifecycle. However, if there are more than one of these `Prefer` headers in a request, nginx should fail but this implmentation does not cause failure. If an attacker sends this mistaken header they can trigger a double free of the prefer buffer in the http request structure.<br>

Difficulty to Discover (easy, medium, hard): Hard<br>
Difficulty to Patch (easy, medium, hard): Easy<br>

The nature of a Use-After_free vulnerability is what makes it difficult to find (especially if all you have access to is the source code). This is due to the fact that large and complex codebases can make it difficult to track memory allocations and deallocations, leading to potential use-after-free issues being overlooked. Manual code review relies on the thoroughness and expertise of the reviewer, but humans can miss these bugs, especially in complex or unfamiliar code. <br>

A good patch will ensure that no references to the freed memory are accessed after the `ngx_free` call. This can easily be done by simply setting the freed pointer to `NULL`. By doing this we ensure that any subsequent access to this pointer will be safely handled as a null reference, thereby preventing a use-after-free scenario.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

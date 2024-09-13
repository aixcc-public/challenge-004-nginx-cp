# Overview

ID: cpv1   
Type: [CWE-787](https://cwe.mitre.org/data/definitions/787.html) Out-of-bounds write   
Sanitizer: AddressSanitizer: heap-buffer-overflow   

# Details

This CPV adds new functionality to the NGINX web server for handling the ``From`` HTTP header in incoming requests. This header is typically used to specify the email address of the user making the request. By introducing this capability, the patch allows NGINX to recognize, process, and validate the From header, ensuring that it adheres to a proper email address format.

**Header Registration**: The ``ngx_http_headers_in`` array is updated to register the ``From`` header, mapping it to a new processing function, ``ngx_http_process_from``. This ensures that NGINX can correctly identify and route the ``From`` header to the appropriate handler.

**Header Handling Logic**: A new function, ``ngx_http_process_from``, is implemented to handle the ``From`` header. This function checks for duplicate headers, validates the header value using ``the ngx_http_validate_from`` function, and assigns it to the request structure. If the ``From`` header is found to be invalid or duplicated, the function finalizes the request with a bad request error.

**Validation Logic**: The ``ngx_http_validate_from`` function is introduced to ensure that the ``From`` header value conforms to a valid email address format. This function validates the presence of alphanumeric characters, the @ symbol, and a valid domain structure. It prevents malformed email addresses from being processed, thus enhancing the robustness of the request handling.

**Request Structure Update**: The ``ngx_http_request_t`` structure in ``ngx_http_request.h`` is modified to include a new field for the ``From`` header (``ngx_table_elt_t *from``). This allows the header to be stored and accessed within the request's context.

## Understanding the ``From`` Header

The ``From`` header in HTTP requests is used to indicate the email address of the user making the request. While not commonly used in modern web applications, this header can be useful for logging, analytics, and access control purposes. By validating and processing this header, NGINX can enhance its logging capabilities, allowing administrators to track requests based on user email addresses. This can be particularly useful in scenarios where user identification and auditing are important. For additional information see [here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/From). 

The injected vulnerability exists in the validation function. If a user has two ``..`` in a row the code attempts to remove one. However, if this is at the beginning of the email then there will be a buffer underrun and an attacker can write data to a buffer prior to the start of the string. 

This is similar to an old bug in nginx but in a completely different section of code seen [here](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-2629). Handling of a complex state machine can be difficult for something that is primarily generative and doesn't necessarily understand state. The parsing of the email is a fairly simple state machine but if a system is able to demonstrate that it could effectively recognize the coding pattern and detect the problem then this would be a success.

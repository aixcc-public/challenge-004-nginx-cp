# Overview
ID: cpv3   
Type: [CWE-787](https://cwe.mitre.org/data/definitions/787.html) Out of Bounds Write     
Sanitizer: AddressSanitizer: heap-buffer-overflow    

# Details

## Modification in Request Processing:

Previously, if a TRACE request was received, NGINX would log the event and immediately finalize the request with a 405 Method Not Allowed response, stopping further processing. The patch changes this behavior to call a new function ``ngx_http_trace_handler`` when a TRACE method is detected.

## New Handler Implementation (``ngx_http_trace_handler``):

The handler begins by allocating a buffer of 200 bytes using ``ngx_create_temp_buf``. This buffer is intended to accumulate the entire request line and headers to echo them back to the client. It then iterates over all received HTTP headers, appending each header and its value to the buffer, formatted correctly with newlines. After processing all headers, it sets up the response headers, including setting the Content-Type to message/http and calculating the Content-Length based on the accumulated length of the request line and headers. The response is sent using ``ngx_http_output_filter``, and the request is closed.

## Vulnerability 

The initial allocation of a 200-byte buffer does not account for the potential size of the request line and headers. Given that the buffer is populated in a loop over the headers, and no bounds checking is implemented during this loop, this leads to a significant risk of buffer overflow. The overflow of this buffer by approximately 409 bytes leads to heap memory corruption. This occurs because the memory adjacent to the allocated buffer, which could be used by other parts of NGINX or by the underlying system libraries (like libc), is overwritten.

# Overview

ID: cpv12<br>
Type: [CWE-122](https://cwe.mitre.org/data/definitions/122.html) heap-buffer-overflow write<br>
Sanitizer: AddressSanitizer: heap-buffer-overflow<br>

# Details

CPV-12 expands on NGINX's capability of sending a range of data rather than an entire resource requested. CPV-12 responds with the desired range of bytes from the resource, but in reverse order. However the new function to do this in `ngx_linux_sendfile_chain.c` incorrectly iterates through the range of that data. The size of the data is assumed and hard-coded instead of calculated from the resource on disk requested.<br>

Difficulty to Discover (easy, medium, hard): Easy<br>
Difficulty to Patch (easy, medium, hard): Easy<br>

The vulnerability should be easy to spot; we can see the size of the memory being used does not match the size of the resource being requested. There are cases in which we may want to hard-code the size of memory being allocated, to enforce some kind of limit, but in ours, we do not know the size of the resource that can be requested beforehand, therefore, opening the file and measuring the size of the memory needed is required.<br>

There is at most one intentional vulnerability in this challenge; memory is being allocated using a hard-coded value instead of the calculated size of the resource on disk being read and reversed. The patch for this is trivial and is fixed in one line by passing the calculated size of the file to NGINX's proprietary memory allocator, so instead of this call `ngx_alloc(NGX_SENDFILE_R_MAXSIZE, c->log)`, we do this instead `ngx_alloc(size, c->log)`.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

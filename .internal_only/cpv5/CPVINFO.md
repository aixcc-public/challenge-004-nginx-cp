# Overview

ID: cpv5     
Type: [CWE-476](https://cwe.mitre.org/data/definitions/476.html) Null Pointer Dereference     
Sanitizer: AddressSanitizer SEGV    

# Details

The inject introduces counters at both the connection (``ngx_connection_t``) and request (``ngx_http_request_t``) levels. These counters are utilized to keep track of the total number of requests and connections processed by the server. A new structure, ``ngx_con_his_t``, is introduced, which is linked-listed to record details of each connection. This structure includes the address in text form (``addr_text``) and a pointer to the next history record (``next``). This feature allows NGINX to maintain a history of connections.

Modifications in ``ngx_http_core_module.c`` and ``ngx_http_static_module.c`` integrate the tracking logic. Specifically, the patch modifies the static handler to include cookie setting based on the browser type and integrates connection history handling directly within the event loop of the epoll module. This means each new connection increments the connection counter and potentially modifies the connection history chain. Two new functions, ``ngx_insert_con_his`` and ``ngx_get_con_his``, manage the connection history linked list. ``ngx_insert_con_his`` adds a new connection record to the history, while ``ngx_get_con_his`` retrieves a specific connection history record based on a sequential number which can be done by requesting the ``/lastConnection`` url.

This inject introduces a vulnerabily that is able to trigger a null-pointer-dereference within NGINX. By sending the URL `/lastConnection`, the server will respond with a string of the last IP to have connected, however, quering this URL the second time, will cause a poorly written `for-loop` to read a linked-list out of bounds dereference a null pointer. The included PoC simply causes a crash of the worker process. This CPV requires that the system is able to generate two requests in a single blob as well as understand how to maintain state across two requests. Additionally, it needs to understand the logic of traversing a linked list using a for loop.

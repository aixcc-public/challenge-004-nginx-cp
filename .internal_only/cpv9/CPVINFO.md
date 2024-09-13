# Overview

ID: cpv9<br>
Type: [CWE-416](https://cwe.mitre.org/data/definitions/416.html)Use-After-Free<br>
Sanitizer: AddressSanitizer: Heap-Use-After-Free<br>

# Details

For CPV-9, a feature of black-listing IPs was introduced to NGINX in `ngx_cycle.c`. This allows banning specific IPs and unbanning them. When "white-listing" or unbanning an IP, we fail to remove the object from the list, setting up a Use-After-Free. These errors cause a crash of the running process.<br>

Difficulty to Discover (easy, medium, hard): Medium<br>
Difficulty to Patch (easy, medium, hard): Medium<br>

The unchecked dereferencing of pointers is an easy to spot syntactical check. This vulnerability should be spotted fairly quickly. Now the incorrect removal of a dynamically allocated object from a list can take a little more analysis,for there is no one way to safely do so. You need to study the structure of the data that is being manipulated and understand how to clean it up after it is used.<br>

To mitigate these errors, we can use the provided macros `ngx_double_link_insert()`, `ngx_double_link_remove()`, and `ngx_destroy_black_list_link()` to safely interact with the objects in the list. We must also remember to check if a pointer is non-NULL before dereferencing.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

# Overview

ID: cpv13<br>
Type: [CWE-476](https://cwe.mitre.org/data/definitions/476.html) Null-Pointer Dereference<br>
Sanitizer: AddressSanitizer: SEGV on unknown address<br>

# Details

CPV-13 adds a new data structure to `ngx_mail_pop3_handler.c` for keeping track of users and their passwords that authenticate with the POP3 mail protocol. CPV-13 needlessly adds a layer of redirection in a pointer, which can lead to mishandling of pointers to objects. This allows for incorrectly checking if a pointer is safe to dereference or not when adding to the list of usernames and passwords.<br>

Difficulty to Discover (easy, medium, hard): Medium<br>
Difficulty to Patch (easy, medium, hard): Easy<br>

This vulnerability is similar to others in syntax and can be recognized as a NULL pointer dereference rather easily. When reading the new functionality added to the `ngx_mail_pop3_pass()` function, it's easy to notice that two layers of reference is needless. There is also a for-loop that is iterating through a linked-list structure with pointer arithmetic instead of following the pointer to the next object in the list.<br>

There are at most two intentional vulnerabilities in this challenge; a needless pointer-to-a-pointer, and an incorrect iteration through a for-loop. We first need to remove a layer of reference (The extra pointer-to-a-pointer) and then correctly calculate how to iterate through the list of usernames and passwords to find the end.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

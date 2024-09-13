# Overview

ID: cpv8<br>
Type: [CWE-787](https://cwe.mitre.org/data/definitions/787.html) Out of Bounds Write<br>
Sanitizer: AddressSanitizer: heap-buffer-overflow<br>

# Details

The size of the temporary buffer created in the `ngx_mail_pop3_init_protocol` function is increased from 128 bytes to 1000 bytes. This change can accommodate larger data within the buffer during the POP3 protocol initialization. In the `ngx_mail_pop3_user` function, the allocation for `s->login.data` is changed from a dynamic allocation based on the length of the login argument to a fixed size allocation of 100 bytes. If the login data exceeds 100 bytes, it will overflow the allocated buffer (s->login.data). This could lead to overwriting adjacent memory, causing undefined behavior, crashes, or security vulnerabilities such as arbitrary code execution.<br>

Difficulty to Discover (easy, medium, hard): Easy<br>
Difficulty to Patch (easy, medium, hard): Easy<br>

This vulnerability is similar to others in syntax and can be recognized as an overflow quite easily. This is because it is commonm practice to avoid using a fixed size for memory allocation (Which is seen with `s->login.data`), so any seasoned code reviewer should notice that a fixed size is unnecessary since `s->login.len` contains the actual size of the buffer. <br>

An optimal patch for this vulnerability is simply to change the fixed size allocation of 100 bytes (which is arbitrary), to a dynamic allocation based on the length of the login argument (which is provided by `s->login.len`). This will make sure that a buffer overflow never occurs here, because we are allocating to the buffer the exact length that we need.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

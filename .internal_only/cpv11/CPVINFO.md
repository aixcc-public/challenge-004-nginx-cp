# Overview

ID: cpv11<br>
Type: [CWE-416](https://cwe.mitre.org/data/definitions/416.html) Use-After-Free<br>
Sanitizer: AddressSanitizer: Heap-Use-After-Free<br>

# Details

CPV-11 introduces a new feature for administrators and users. They can request hardware specifications of the host, such as CPU, RAM, and OS. The vulnerability occurs in `ngx_cycle.c` because CPV-11 fails to check if the runtime configuration of NGINX has enabled this feature before memory allocation. It allocates memory regardless and then checks if the setting is turned on and frees the memory. However, the variables that point to the now freed memory are not cleared, which allows access to the freed memory AKA use-after-free. When a process accesses memory that has been freed, the OS terminates the process.<br>

Difficulty to Discover (easy, medium, hard): Hard<br>
Difficulty to Patch (easy, medium, hard): Medium<br>

The vulnerability is not easy to spot due to the fact that we must consider "non-code", or configurations outside of the codebase itself during runtime. Vulnerabilities due to misconfigurations are notoriously common. There are common vulnerabilities that should be easy to spot; the dereferencing of a pointer without prior checks.<br>

There are at most two intentional vulnerabilities in this challenge; The allocation of memory prior to checking if it is even required, freeing that memory without cleaning up the pointers, and dereferencing them. Thankfully the correction is rather easy; 1. We must first check if the memory allocation is even required and only do so if the configuration calls for it. 2. We need to guard against dereferencing NULL pointers.<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

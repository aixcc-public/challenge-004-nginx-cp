# Overview

ID: cpv15<br>
Type: [CWE-787](https://cwe.mitre.org/data/definitions/787.html) Out-of-bounds write<br>
Sanitizer: AddressSanitizer: SEGV on unknown address<br>

# Details

This CPV removes code that limits the length of the `src` string to 22 characters in the `ngx_http_userid_get_uid` function of `ngx_http_userid_filter_module.c`. This change indicates a revision in handling the `src` string's length or encoding, potentially to allow for decoding base64 strings without a fixed length constraint. The vulnerability exists in this module when an overly long value is provided via the `uid=` option in the Cookie request. This causes an overflow in global memory in a context structure. While the main result of the vulnerability is an overflow, the sanitizer that triggers is a Read Access due to the overwriting of a pointer that is later dereferenced.<br>

Difficulty to Discover (easy, medium, hard): Easy<br>
Difficulty to Patch (easy, medium, hard): Easy<br>

The purpose of this CPV is to demonstrate what could happen if a developer fails to add a simple length check. Therefore, the difficulty of finding this type of vulnerability should not be high for a seasoned code reviewer. This is because knowledge of common vulnerabilities, such as input validation issues, improper use of cryptographic functions, or insufficient data sanitization, can guide the search for the vulnerability in this specific CPV.<br>

Given that this is a relatively common occurance, it is important that successful systems are able to detect and mitigate this type of programming error. Therefore, a good patch would involve setting a length limit to a buffer that is being copied to or from another source (In this case, limiting the `src` string to 22 characters).<br>

This vulnerability causes NGINX to crash thus denying service to its clients. The intentional crash of a service is called "Denial of Service" or DoS.<br>

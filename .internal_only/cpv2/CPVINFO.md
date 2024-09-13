# Overview
ID: cpv2   
Type: [CWE-122](https://cwe.mitre.org/data/definitions/122.html) Heap-based Buffer Overflow  
Sanitizer: AddressSanitizer: heap-buffer-overflow  

# Details

The Basic Auth header is a component of the HTTP protocol used for simple access control. When a user requests access to a protected resource, if unallowed, the server responds with a 401 Unauthorized status and a WWW-Authenticate header. The client could then send a request with an Authorization header containing the word Basic followed by a space and a base64-encoded string username:password. This allows the server to decode the credentials and verify the user's identity.

You could manually perform this operation with the shell command ``curl -H "Authorization: Basic $(echo -n "myuser:mypassword" | base64)" localhost:9999``. If you have a netcat listener you will receive the following request:
```
GET / HTTP/1.1
Host: localhost:9999
User-Agent: curl/7.81.0
Accept: */*
Authorization: Basic bXl1c2VyOm15cGFzc3dvcmQ=
``` 

The vulnerability is in how nginx handles the basic authentication header. The attacker sends a base64 encoded string but the nginx server has a statically size buffer into which it decodes the base64. This results in a heap base buffer overflow. The purpose of this is for systems to detect when a dynamic buffer is allocated with a non-dynamic length and the developer fails to include sufficient checks on the length of user input. This is a fairly fundamental problem and common occurrence that systems should be able to detect and mitigate.

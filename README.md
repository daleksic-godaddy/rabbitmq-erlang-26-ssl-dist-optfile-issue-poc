# RabbitMQ issue PoC

This repository contains a PoC for reproducing an issue with RabbitMQ and Erlang 26 where
`-ssl_dist_optfile` is not loaded in internode TLS communication setup.

Same configuration works with Erlang 25, but using Erlang 26 both rabbitmq 3.12 and 3.13 it fails to load
`inter_node_tls.config` and therefore TLS is not enabled on internode communication port 25672.

## Requirements

- Docker & docker compose
- Make

## How to reproduce

### Initialize project

```shell
make
# or
make all
```

This will:

- generate self-signed certs with tls-gen
- build docker containers with RabbitMQ 3.12/3.13 & Erlang 25/26 combos using the official Ubuntu 22.04 RabbitMQ
  server & RabbitMQ Erlang repo
- start the containers with configuration specified in `docker/config` directory

### Testing

Tests are using `openssl s_client` to connect to RabbitMQ internode communication port 25672 and show the served
certificate.

#### RabbitMQ 3.12 with Erlang 25

Results in a successful connection with the certificate served by RabbitMQ

```
❯ make test_erlang25_rmq312
openssl s_client -connect localhost:25272 || true
Connecting to 127.0.0.1
CONNECTED(00000005)
Can't use SSL_get_servername
depth=1 CN=TLSGenSelfSignedtRootCA 2024-04-23T18:06:17.251004, L=$$$$
verify error:num=19:self-signed certificate in certificate chain
verify return:1
depth=1 CN=TLSGenSelfSignedtRootCA 2024-04-23T18:06:17.251004, L=$$$$
verify return:1
depth=0 CN=rabbitmq.mydomain.local, O=server
verify return:1
00A6750001000000:error:0A000410:SSL routines:ssl3_read_bytes:ssl/tls alert handshake failure:ssl/record/rec_layer_s3.c:865:SSL alert number 40
---
Certificate chain
 0 s:CN=rabbitmq.mydomain.local, O=server
   i:CN=TLSGenSelfSignedtRootCA 2024-04-23T18:06:17.251004, L=$$$$
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: Apr 23 16:06:17 2024 GMT; NotAfter: Apr 21 16:06:17 2034 GMT
 1 s:CN=TLSGenSelfSignedtRootCA 2024-04-23T18:06:17.251004, L=$$$$
   i:CN=TLSGenSelfSignedtRootCA 2024-04-23T18:06:17.251004, L=$$$$
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: Apr 23 16:06:17 2024 GMT; NotAfter: Apr 21 16:06:17 2034 GMT
---
Server certificate
-----BEGIN CERTIFICATE-----
MIID3jCCAsagAwIBAgIBATANBgkqhkiG9w0BAQsFADBMMTswOQYDVQQDDDJUTFNH
ZW5TZWxmU2lnbmVkdFJvb3RDQSAyMDI0LTA0LTIzVDE4OjA2OjE3LjI1MTAwNDEN
MAsGA1UEBwwEJCQkJDAeFw0yNDA0MjMxNjA2MTdaFw0zNDA0MjExNjA2MTdaMDMx
IDAeBgNVBAMMF3JhYmJpdG1xLm15ZG9tYWluLmxvY2FsMQ8wDQYDVQQKDAZzZXJ2
ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCjnJuddXfyhrEStoa1
akfchxjaniFmzBEawaHRHHAsfO6hCuiRI/W3kKRChYFATWIv+j+U2lRVHvYk1TUR
of62s3A+1EnFRNHWfBDXpCNfC7DSz3pf7xEEbbeqPP9hEtKTIcvgy5nu4srxlUz6
6SaCj8aMvy9C+ZsX8dMSY/+n8fPdDIZRgnjMkqxI+EO17UWNMULmxj7uMROOQ6ug
ZSO8LtgrK99n0MqHbaSMdovHQJZBliO3shYEOKsc9adh04rOT+e/edQlFKwYlrE7
WGOL4p1SPhQU/vM3MRACIfoqRIlaRKlUt3/jSbez6hMzQzHLyA1aqIQFs/ZWrjME
mpu5AgMBAAGjgeMwgeAwCQYDVR0TBAIwADALBgNVHQ8EBAMCBaAwEwYDVR0lBAww
CgYIKwYBBQUHAwEwPgYDVR0RBDcwNYIXcmFiYml0bXEubXlkb21haW4ubG9jYWyC
D0xNLUMwMkROMUZRTUQ2UoIJbG9jYWxob3N0MB0GA1UdDgQWBBSaDrQNINXrLgj0
7+B3ENJPsOLdwjAfBgNVHSMEGDAWgBT3SHE/+MCgyH/N36k1LgBJneg8vzAxBgNV
HR8EKjAoMCagJKAihiBodHRwOi8vY3JsLXNlcnZlcjo4MDAwL2Jhc2ljLmNybDAN
BgkqhkiG9w0BAQsFAAOCAQEAjaDbVWvYIxf9cru3/Iyi7ywvKuXmoDbr1L6GOWkW
LByeA+B0iaynlCnAIwhL61eFMozajoeroXEr1TdvmS11nYfU6BRvl+cIfB6rGt1L
ENJQsoAy3eSf8woPj23S7/i3xr2wrMEfxRZW1rha1iESK95erQ1xjnuU0qxn/OGs
LTwbNywxsXcEm1TtwKFPWP0kW9e8fgh8r7ssSX00TV+APPseInQjBV4ZDL9nCTvm
Ol0z3usdictiAKktqpoX0j+k55DS3TYaPl84fW9ef+86fp/Ii4L3PWxZLil8CK4/
vHpEvzYlOrhgA7Glz6/FsZhpGtZObRyKlnHvW6bhr0JBvQ==
-----END CERTIFICATE-----
subject=CN=rabbitmq.mydomain.local, O=server
issuer=CN=TLSGenSelfSignedtRootCA 2024-04-23T18:06:17.251004, L=$$$$
---
Acceptable client certificate CA names
CN=TLSGenSelfSignedtRootCA 2024-04-23T18:06:17.251004, L=$$$$
Client Certificate Types: ECDSA sign, RSA sign, DSA sign
Requested Signature Algorithms: ECDSA+SHA512:RSA-PSS+SHA512:RSA-PSS+SHA512:RSA+SHA512:ECDSA+SHA384:RSA-PSS+SHA384:RSA-PSS+SHA384:RSA+SHA384:ECDSA+SHA256:RSA-PSS+SHA256:RSA-PSS+SHA256:RSA+SHA256:ECDSA+SHA224:RSA+SHA224:ECDSA+SHA1:RSA+SHA1:DSA+SHA1
Shared Requested Signature Algorithms: ECDSA+SHA512:RSA-PSS+SHA512:RSA-PSS+SHA512:RSA+SHA512:ECDSA+SHA384:RSA-PSS+SHA384:RSA-PSS+SHA384:RSA+SHA384:ECDSA+SHA256:RSA-PSS+SHA256:RSA-PSS+SHA256:RSA+SHA256:ECDSA+SHA224:RSA+SHA224
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: ECDH, prime256v1, 256 bits
---
SSL handshake has read 2495 bytes and written 437 bytes
Verification error: self-signed certificate in certificate chain
---
New, TLSv1.2, Cipher is ECDHE-RSA-AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-GCM-SHA384
    Session-ID: 335C4CBA8FA2016453A73A492508B9D27BB757B5575B765767F6EBD256FC6A10
    Session-ID-ctx:
    Master-Key: AA4B6F0FC61D7F6F737F7BDEAFDA6B54D824C7F10717B5F54EABE912A1E32819F5E19E59D139319A34B1B1B6C5B0C0F1
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1713889030
    Timeout   : 7200 (sec)
    Verify return code: 19 (self-signed certificate in certificate chain)
    Extended master secret: no
---
```

#### RabbitMQ 3.12 with Erlang 26

Results in connection where SSL certificate is not served by RabbitMQ

```
❯ make test_erlang26_rmq312
openssl s_client -connect localhost:26272 || true
Connecting to 127.0.0.1
CONNECTED(00000005)
00B63D0601000000:error:0A000126:SSL routines::unexpected eof while reading:ssl/record/rec_layer_s3.c:650:
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 0 bytes and written 306 bytes
Verification: OK
---
New, (NONE), Cipher is (NONE)
This TLS version forbids renegotiation.
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 0 (ok)
---
```

#### RabbitMQ 3.13 with Erlang 26

Results in connection where SSL certificate is not served by RabbitMQ

```
❯ make test_erlang26_rmq313
openssl s_client -connect localhost:26272 || true
Connecting to 127.0.0.1
CONNECTED(00000005)
00B63D0601000000:error:0A000126:SSL routines::unexpected eof while reading:ssl/record/rec_layer_s3.c:650:
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 0 bytes and written 306 bytes
Verification: OK
---
New, (NONE), Cipher is (NONE)
This TLS version forbids renegotiation.
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 0 (ok)
---
```

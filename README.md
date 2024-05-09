# RabbitMQ issue PoC

https://github.com/rabbitmq/rabbitmq-server/issues/11071

This repository contains a PoC for reproducing an issue with RabbitMQ and Erlang 26 where
`-ssl_dist_optfile` is not loaded in internode TLS communication setup.

Same configuration works with Erlang 25, but using Erlang 26 both rabbitmq 3.12 and 3.13 it fails to load
`inter_node_tls.config` and therefore TLS is not enabled on internode communication port 25672.

## Requirements

- Make
- Vagrant

## How to reproduce

### Initialize project

```shell
make
# or
make all
```

This will:

- generate self-signed certs with tls-gen
- bring up 3 VMs via Vagrant
- provision VMs
    - with RabbitMQ 3.12/3.13 & Erlang 25/26 combinations
    - apply `config_variant` (defined in Vagrantfile) configuration to each VM
- Execute `openssl s_client` and `rabbitmqctl status` test for each VM

### Testing

Tests are using `openssl s_client` to connect to RabbitMQ internode communication port 25672 and show the served
certificate. Also, it uses `rabbitmqctl status` to check if internode communication works with CLI tool.

Update `config_variant` variable for different config variant and re-run

```shell
make
# or
make all
```

to run provisioning and test again. Config with observed behaviour comments
are at `ansible/templates/inter_node_tls.<config_variant>.config`

#### RabbitMQ 3.12 with Erlang 25

Results in a successful connection with the certificate served by RabbitMQ

```
=========================================
=> RABBITMQ 3.12 - ERLANG 25
=========================================

=> Test rmq312-er25: Check served certificate on inter-node communication port 25672
openssl s_client \
		-connect rmq312-er25.mydomain.local:25672 \
		-cert ansible/files/rmq312-er25.mydomain.local/client_certificate.pem \
		-key ansible/files/rmq312-er25.mydomain.local/client_key.pem \
		-CAfile ansible/files/rmq312-er25.mydomain.local/chained_ca_certificate.pem \
		-verify_depth 8 \
		-verify_hostname rmq312-er25.mydomain.local \
	|| true
Connecting to 192.168.56.50
CONNECTED(00000006)
depth=3 CN=TLSGenSelfSignedtRootCA 2024-05-09T21:50:52.142560, L=$$$$
verify error:num=19:self-signed certificate in certificate chain
verify return:1
depth=3 CN=TLSGenSelfSignedtRootCA 2024-05-09T21:50:52.142560, L=$$$$
verify return:1
depth=2 CN=*.mydomain.local, O=Intermediate CA 1
verify return:1
depth=1 CN=*.mydomain.local, O=Intermediate CA 2
verify return:1
depth=0 CN=*.mydomain.local, O=server
verify return:1
0096A41201000000:error:0A000418:SSL routines:ssl3_read_bytes:tlsv1 alert unknown ca:ssl/record/rec_layer_s3.c:865:SSL alert number 48
---
Certificate chain
 0 s:CN=*.mydomain.local, O=server
   i:CN=*.mydomain.local, O=Intermediate CA 2
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: May  9 19:50:52 2024 GMT; NotAfter: May  7 19:50:52 2034 GMT
 1 s:CN=*.mydomain.local, O=Intermediate CA 2
   i:CN=*.mydomain.local, O=Intermediate CA 1
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: May  9 19:50:52 2024 GMT; NotAfter: May  7 19:50:52 2034 GMT
 2 s:CN=*.mydomain.local, O=Intermediate CA 1
   i:CN=TLSGenSelfSignedtRootCA 2024-05-09T21:50:52.142560, L=$$$$
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: May  9 19:50:52 2024 GMT; NotAfter: May  7 19:50:52 2034 GMT
 3 s:CN=TLSGenSelfSignedtRootCA 2024-05-09T21:50:52.142560, L=$$$$
   i:CN=TLSGenSelfSignedtRootCA 2024-05-09T21:50:52.142560, L=$$$$
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: May  9 19:50:52 2024 GMT; NotAfter: May  7 19:50:52 2034 GMT
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIDiDCCAnCgAwIBAgIBAzANBgkqhkiG9w0BAQsFADA3MRkwFwYDVQQDDBAqLm15
ZG9tYWluLmxvY2FsMRowGAYDVQQKDBFJbnRlcm1lZGlhdGUgQ0EgMjAeFw0yNDA1
MDkxOTUwNTJaFw0zNDA1MDcxOTUwNTJaMCwxGTAXBgNVBAMMECoubXlkb21haW4u
bG9jYWwxDzANBgNVBAoMBnNlcnZlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBANnYMpC0xexJlSLcioVFzvVJ/JvtV1o4QOoVyWyh2rnDtnnq+1zGssU/
l1CIf6E7/80dMPDCln+boNTPm5KlYZFIIifeiKXthPIeMN6NBuVJTTs5TS7BfQjj
DIVKS0vCAnBuQoQ3jnHV5+EoTwgzVx8FNsc66bMaS165dpLsMU1Mjdtoz0uztazs
To3HM+Sl2M39FJYFeCa1rbSytvXE+sU7ZB9H6laJjHbemvfLNlvBCrPudW6E1xA6
iga15zbQvsLuCspHBgAl9Wr/lbhT5ZucqrOuK5ypeU5nyaJg/tpFzucfALyEitJE
NgFCmMxz8jsB+MsdwbX0S8pRRFFG6nUCAwEAAaOBqTCBpjAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIFoDATBgNVHSUEDDAKBggrBgEFBQcDATA3BgNVHREEMDAughAqLm15
ZG9tYWluLmxvY2Fsgg9MTS1DMDJETjFGUU1ENlKCCWxvY2FsaG9zdDAdBgNVHQ4E
FgQU6pKvEFGFlEhwMmaoPL3qpoTLllMwHwYDVR0jBBgwFoAUWm5X7G4Fhl7ty1gW
GHnJN0hCK2kwDQYJKoZIhvcNAQELBQADggEBACIUF7On/9NfMRe3bHzxS0FUaesM
5n/is1s9YgSdC3E/TjzrVmHyPo9gxIEAwk50zNP7+IZxoiIGXXFysslTQGuV29w7
3q/6p9b0owliZf7i3lnA2Krh6GGbuHqboh0YachQ71IlYwy2zmt2n5vYzo6cQ3tb
HnL5QcXqG4Yj1G2v6xp7+nPddA6hEz+rGlF9ltiJ/3qvM0RYTgbdZXHSyrFkMp6k
eG9dYfNA7OIgQaiRZbad+2kFK6CVitM5rY5Sjo7TtpsuxuDaTBQsHqYHigDeOEvU
g1HJ9e6qgFI9J3uXvL/vTHv8ZH1LOwByGNFvChq18INcSnth56zt64XrUxI=
-----END CERTIFICATE-----
subject=CN=*.mydomain.local, O=server
issuer=CN=*.mydomain.local, O=Intermediate CA 2
---
Acceptable client certificate CA names
CN=TLSGenSelfSignedtRootCA 2024-05-09T21:50:52.142560, L=$$$$
CN=*.mydomain.local, O=Intermediate CA 2
CN=*.mydomain.local, O=Intermediate CA 1
Client Certificate Types: ECDSA sign, RSA sign, DSA sign
Requested Signature Algorithms: ECDSA+SHA512:RSA-PSS+SHA512:RSA-PSS+SHA512:RSA+SHA512:ECDSA+SHA384:RSA-PSS+SHA384:RSA-PSS+SHA384:RSA+SHA384:ECDSA+SHA256:RSA-PSS+SHA256:RSA-PSS+SHA256:RSA+SHA256:ECDSA+SHA224:RSA+SHA224:ECDSA+SHA1:RSA+SHA1:DSA+SHA1
Shared Requested Signature Algorithms: ECDSA+SHA512:RSA-PSS+SHA512:RSA-PSS+SHA512:RSA+SHA512:ECDSA+SHA384:RSA-PSS+SHA384:RSA-PSS+SHA384:RSA+SHA384:ECDSA+SHA256:RSA-PSS+SHA256:RSA-PSS+SHA256:RSA+SHA256:ECDSA+SHA224:RSA+SHA224
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: ECDH, prime256v1, 256 bits
---
SSL handshake has read 4238 bytes and written 4332 bytes
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
    Session-ID: 63EE60EEBBDA9852B45ED80B86FF0719F077FF8F65FFBCB70A518BC749A83276
    Session-ID-ctx:
    Master-Key: C94FCF507E02C6AE38B0054FF5E10CD658E6F077F220FB3A91860EF6FEA3FC07FF25F099D44058F6F08E81B2499487EE
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1715285932
    Timeout   : 7200 (sec)
    Verify return code: 19 (self-signed certificate in certificate chain)
    Extended master secret: no
---

=> Test rmq312-er25: Check rabbitmqctl status execution
vagrant ssh rmq312_er25 -c "sudo rabbitmqctl status" || true
Status of node rabbit@rmq312-er25.mydomain.local ...
Runtime

OS PID: 12175
OS: Linux
Uptime (seconds): 1325
Is under maintenance?: false
RabbitMQ version: 3.12.12
RabbitMQ release series support status: supported
Node name: rabbit@rmq312-er25.mydomain.local
Erlang configuration: Erlang/OTP 25 [erts-13.2.2.9] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [jit:ns]
Crypto library: OpenSSL 3.0.2 15 Mar 2022
Erlang processes: 368 used, 1048576 limit
Scheduler run queue: 1
Cluster heartbeat timeout (net_ticktime): 60

...

Listeners

Interface: [::], port: 15671, protocol: https, purpose: HTTP API over TLS (HTTPS)
Interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Interface: [::], port: 5671, protocol: amqp/ssl, purpose: AMQP 0-9-1 and AMQP 1.0 over TLS
Connection to 127.0.0.1 closed.
```

#### RabbitMQ 3.12 with Erlang 26

Results in connection where SSL certificate is not served by RabbitMQ

```
=========================================
      RABBITMQ 3.12 - ERLANG 26
=========================================

=> Test rmq312-er26: Check served certificate on inter-node communication port 25672
openssl s_client \
		-connect rmq312-er26.mydomain.local:25672 \
		-cert ansible/files/rmq312-er26.mydomain.local/client_certificate.pem \
		-key ansible/files/rmq312-er26.mydomain.local/client_key.pem \
		-CAfile ansible/files/rmq312-er26.mydomain.local/chained_ca_certificate.pem \
		-verify_depth 8 \
		-verify_hostname rmq312-er26.mydomain.local \
	|| true
Connecting to 192.168.56.51
CONNECTED(00000006)
write:errno=54
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 0 bytes and written 334 bytes
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

=> Test rmq312-er26: Check rabbitmqctl status execution
vagrant ssh rmq312_er26 -c "sudo rabbitmqctl status" || true
Error: unable to perform an operation on node 'rabbit@rmq312-er26.mydomain.local'. Please see diagnostics information and suggestions below.

Most common reasons for this are:

 * Target node is unreachable (e.g. due to hostname resolution, TCP connection or firewall issues)
 * CLI tool fails to authenticate with the server (e.g. due to CLI tool's Erlang cookie not matching that of the server)
 * Target node is not running

In addition to the diagnostics info below:

 * See the CLI, clustering and networking guides on https://rabbitmq.com/documentation.html to learn more
 * Consult server logs on node rabbit@rmq312-er26.mydomain.local
 * If target node is configured to use long node names, don't forget to use --longnames with CLI tools

DIAGNOSTICS
===========

attempted to contact: ['rabbit@rmq312-er26.mydomain.local']

rabbit@rmq312-er26.mydomain.local:
  * connected to epmd (port 4369) on rmq312-er26.mydomain.local
  * epmd reports node 'rabbit' uses port 25672 for inter-node and CLI tool traffic
  * TCP connection succeeded but Erlang distribution failed
  * suggestion: check if the Erlang cookie is identical for all server nodes and CLI tools
  * suggestion: check if all server nodes and CLI tools use consistent hostnames when addressing each other
  * suggestion: check if inter-node connections may be configured to use TLS. If so, all nodes and CLI tools must do that
   * suggestion: see the CLI, clustering and networking guides on https://rabbitmq.com/documentation.html to learn more


Current node details:
 * node name: 'rabbitmqcli-535-rabbit@rmq312-er26.mydomain.local'
 * effective user's home directory: /var/lib/rabbitmq
 * Erlang cookie hash: Tsc+rWq+mZ0LTkPFWaS1kw==

Connection to 127.0.0.1 closed.
```

#### RabbitMQ 3.13 with Erlang 26

Results in connection where SSL certificate is not served by RabbitMQ

```
=========================================
=> RABBITMQ 3.13 - ERLANG 26
=========================================

=> Test rmq313-er26: Check served certificate on inter-node communication port 25672
openssl s_client \
		-connect rmq313-er26.mydomain.local:25672 \
		-cert ansible/files/rmq313-er26.mydomain.local/client_certificate.pem \
		-key ansible/files/rmq313-er26.mydomain.local/client_key.pem \
		-CAfile ansible/files/rmq313-er26.mydomain.local/chained_ca_certificate.pem \
		-verify_depth 8 \
		-verify_hostname rmq313-er26.mydomain.local \
	|| true
Connecting to 192.168.56.52
CONNECTED(00000006)
write:errno=54
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 0 bytes and written 334 bytes
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

=> Test rmq313-er26: Check rabbitmqctl status execution
vagrant ssh rmq313_er26 -c "sudo rabbitmqctl status" || true
Error: unable to perform an operation on node 'rabbit@rmq313-er26.mydomain.local'. Please see diagnostics information and suggestions below.

Most common reasons for this are:

 * Target node is unreachable (e.g. due to hostname resolution, TCP connection or firewall issues)
 * CLI tool fails to authenticate with the server (e.g. due to CLI tool's Erlang cookie not matching that of the server)
 * Target node is not running

In addition to the diagnostics info below:

 * See the CLI, clustering and networking guides on https://rabbitmq.com/documentation.html to learn more
 * Consult server logs on node rabbit@rmq313-er26.mydomain.local
 * If target node is configured to use long node names, don't forget to use --longnames with CLI tools

DIAGNOSTICS
===========

attempted to contact: ['rabbit@rmq313-er26.mydomain.local']

rabbit@rmq313-er26.mydomain.local:
  * connected to epmd (port 4369) on rmq313-er26.mydomain.local
  * epmd reports node 'rabbit' uses port 25672 for inter-node and CLI tool traffic
  * TCP connection succeeded but Erlang distribution failed
  * suggestion: check if the Erlang cookie is identical for all server nodes and CLI tools
  * suggestion: check if all server nodes and CLI tools use consistent hostnames when addressing each other
  * suggestion: check if inter-node connections may be configured to use TLS. If so, all nodes and CLI tools must do that
   * suggestion: see the CLI, clustering and networking guides on https://rabbitmq.com/documentation.html to learn more


Current node details:
 * node name: 'rabbitmqcli-641-rabbit@rmq313-er26.mydomain.local'
 * effective user's home directory: /var/lib/rabbitmq
 * Erlang cookie hash: 8lsn1cPFIQMGgdja5ThZHA==

Connection to 127.0.0.1 closed.
```

## Problem & Solution

> **Note**
>
> Based on troubleshooting and observed behaviour

Due to changes in Erlang 26 of handling SSL options:
> **Quote**
>
> *Improved error checking and handling of ssl options.*

(source: https://www.erlang.org/news/164#ssl)

specifying unexpected/excess options are not ignored anymore.

As `customize_hostname_check` is only valid for `client`, in Erlang 25 following configuration
will be "valid", as it will ignore `customize_hostname_check` in `server` section:

```
[
  {server, [
    ...
    {customize_hostname_check, [
      {match_fun, public_key:pkix_verify_hostname_match_fun(https)}
    ]}
  ]}
```

But in Erlang 26 it will error out, and it will skip loading `server` section of `inter_node_tls.config`.

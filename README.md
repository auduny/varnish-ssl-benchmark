# Introduction

This is a docker compose setup to test the performance of the different combinations of varnish-cache sandwitches

## Howto

### Create SSL-certs
` ./bin/self-signed-tls ` (generate SSL certs with ./etc/ssl-managed/dns.ext as source)

### Launch tls-proxy
` docker-compose up `

### Install certs

If you want to install cert in your browser:

https://www.google.no/search?&q=install+self+signed+cert+osx+keychain

## What does it do

Well. This is sort of a testsetup with varnish 6, h2-enabled. With different combinations
of frontends/ssl-balancers:

|port|what|
|----|----|
|80| Backend
|8081| Varnish directly (http)
|8082| Varnish receiver (proxy-protocol)
|8084| haproxy -> varnish
|8443| hitch -> varnish
|8444| nginx -> varnish
|8445| haproxy -> varnish(http)
|8446| haproxy -> varnish(proxy-protocol)
|8447| haproxy -> UDS -> varnish
|8448| haproxy tcp -> UDS -> varnish
|8449| envoy -> varnish(http)
|8450| traefik -> varnish(http)

Backend is a nginx running owasp modsecurity for fun and profit

## Benchmarking

`bin/benchmark.sh` or `docker-compose up benchmarker`

### H2Load

We use [h2load](https://nghttp2.org/documentation/h2load.1.html#) from the
[nghttp2 package](https://github.com/nghttp2/nghttp2) from [our benchmark script](benchmark.sh)

#### Install Ubuntu

`sudo apt-get install nghttp2-client`

#### Install Centos
`sudo yum install nghttp2`

#### Install OS X
`brew install nghttp2`

## Other tools

### Vegeta

#### Install Ubuntu / Centos

`go get -u github.com/tsenart/vegeta`

#### Install OS X

`brew install vegeta`

# Results

## Macbook Air 

|what   |time   |reqs   |bw     |
|-----|---|---|---|
|Client->(H1)->Varnish on port 8081|924.60ms|5407.75|1.94GB|
|Client->(H2)->Varnish on port 8081|1.95s|2560.23|940.16MB|
|Client->(H1)->HAProxy->(H1)->Varnish on port 8084|2.02s|2471.65|907.29MB|
|Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|3.31s|1508.43|553.72MB|
|Client->(SSL/H1)Nginx->(H1)->Varnish on port 8445|3.67s|1361.52|499.79MB|
|Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8448|3.86s|1295.88|475.72MB|
|Client->(SSL/H1)Haproxy->(H1)->Varnish on port 8445|3.98s|1256.31|461.17MB|
|Client->(SSL/H2)Haproxy->(H1)->Varnish on port 8445|4.22s|1184.89|435.09MB|
|Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish on port 8448|4.25s|1176.82|432.15MB|
|Client->(SSL/TCP)->Hitch->(H1)->Varnish on port 8443|4.43s|1129.68|414.71MB|
|Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|4.55s|1098.10|403.09MB|
|Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|4.55s|1097.71|403.08MB|
|Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|4.82s|1038.17|381.22MB|
|Client->(SSL/H2)Envoy->(H2)->Varnish on port 8449|5.20s|960.99|352.81MB|
|Client->(SSL/H2)Nginx->(H2)->Varnish on port 8445|5.28s|946.12|347.42MB|
|Client->(SSL/H1)Envoy->(H2)->Varnish on port 8449|5.35s|935.25|343.36MB|
|Client->(SSL/TCP)->Hitch->(UDS/H2)->Varnish on port 8444|5.37s|931.95|342.23MB|
|Client->(SSL/TCP)->Hitch->(USD/H1)->Varnish on port 8444|5.48s|911.94|334.77MB|
|Client->(SSL/H1)Traefik->(H1)->Varnish on port 8450|5.79s|863.74|317.06MB|
|Client->(SSL/H1)H2O->(H1)->Varnish on port 8451|6.63s|754.05|276.83MB|
|Client->(SSL/TCP)->Hitch->(H2)->Varnish on port 8443|6.94s|720.28|264.50MB|
|Client->(SSL/H2)H2O->(H1)->Varnish on port 8452|7.03s|711.03|261.01MB|
|Client->(SSL/H2)Traefik->(H1)->Varnish on port 8450|8.80s|568.15|208.56MB|
|Client->(H1)->Backend(Nginx) on port 8080|22.95s|217.88|79.96MB|

## Hardcore machine

|what	|time	|reqs	|bw	|
|-----|---|---|---|
|Client->(H1)->Varnish on port 8081|593.22ms|8428.65|3.02GB|
|Client->(H1)->HAProxy->(H1)->Varnish on port 8084|695.61ms|7187.97|2.58GB|
|Client->(H2)->Varnish on port 8081|918.74ms|5442.23|1.95GB|
|Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|1.52s|3294.94|1.18GB|
|Client->(SSL/H1)Nginx->(H1)->Varnish on port 8445|1.56s|3210.38|1.15GB|
|Client->(SSL/H1)Haproxy->(H1)->Varnish on port 8445|1.57s|3178.71|1.14GB|
|Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|1.59s|3147.33|1.13GB|
|Client->(H1)->Backend(Nginx) on port 8080|1.59s|3145.30|1.13GB|
|Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish on port 8448|1.61s|3100.10|1.11GB|
|Client->(SSL/H2)Nginx->(H2)->Varnish on port 8445|1.70s|2949.27|1.06GB|
|Client->(SSL/H1)Traefik->(H1)->Varnish on port 8450|1.71s|2923.19|1.05GB|
|Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8448|1.71s|2917.13|1.05GB|
|Client->(SSL/H2)H2O->(H1)->Varnish on port 8452|1.98s|2521.95|925.75MB|
|Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|2.04s|2456.86|902.16MB|
|Client->(SSL/H2)Haproxy->(H1)->Varnish on port 8445|2.08s|2404.16|882.81MB|
|Client->(SSL/H2)Traefik->(H1)->Varnish on port 8450|2.22s|2256.07|828.16MB|
|Client->(SSL/H1)H2O->(H1)->Varnish on port 8451|2.37s|2107.87|773.85MB|
|Client->(SSL/H1)Envoy->(H2)->Varnish on port 8449|2.54s|1964.97|721.39MB|
|Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|2.65s|1885.07|692.20MB|
|Client->(SSL/TCP)->Hitch->(UDS/H1)->Varnish on port 8444|4.14s|1208.74|443.73MB|
|Client->(SSL/TCP)->Hitch->(H1)->Varnish on port 8443|4.29s|1164.37|427.44MB|
|Client->(SSL/TCP)->Hitch->(UDS/H2)->Varnish on port 8444|4.42s|1132.08|415.72MB|
|Client->(SSL/TCP)->Hitch->(H2)->Varnish on port 8443|4.49s|1114.79|409.37MB|
|Client->(SSL/H2)Envoy->(H2)->Varnish on port 8449|4.71s|1060.48|389.33MB|

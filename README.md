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

Running with 20 clients and 5000 requests

### Client->(H1)->Varnish on port 8081
Application protocol: http/1.1
finished in 1.10s, 4552.46 req/s, 1.63GB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(H2)->Varnish on port 8081
Application protocol: h2c
finished in 1.65s, 3024.34 req/s, 1.08GB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(H1)->HAProxy->(H1)->Varnish on port 8084
Application protocol: http/1.1
finished in 1.75s, 2860.03 req/s, 1.03GB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/TCP)->Hitch->(H1)->Varnish on port 8443
Application protocol: http/1.1
finished in 3.86s, 1294.25 req/s, 475.12MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/TCP)->Hitch->(H2)->Varnish on port 8443
Application protocol: h2
finished in 3.99s, 1252.40 req/s, 459.90MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/TCP)->Hitch->(USD/H1)->Varnish on port 8444
Application protocol: http/1.1
finished in 4.02s, 1243.21 req/s, 456.39MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/TCP)->Hitch->(UDS/H2)->Varnish on port 8444
Application protocol: h2
finished in 4.43s, 1129.06 req/s, 414.61MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H1)Haproxy->(H1)->Varnish on port 8445
Application protocol: http/1.1
finished in 3.12s, 1603.43 req/s, 588.59MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H2)Haproxy->(H1)->Varnish on port 8445
Application protocol: h2
finished in 3.28s, 1523.19 req/s, 559.32MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446
Application protocol: http/1.1
finished in 3.21s, 1556.43 req/s, 571.34MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446
Application protocol: h2
finished in 3.30s, 1514.69 req/s, 556.20MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447
Application protocol: http/1.1
finished in 3.37s, 1482.71 req/s, 544.27MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447
Application protocol: h2
finished in 3.60s, 1387.22 req/s, 509.39MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8448
Application protocol: http/1.1
finished in 3.48s, 1438.45 req/s, 528.06MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish on port 8448
Application protocol: h2
finished in 3.92s, 1275.08 req/s, 468.23MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H1)Envoy->(H2)->Varnish on port 8449
Application protocol: http/1.1
finished in 5.24s, 954.16 req/s, 350.30MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H2)Envoy->(H2)->Varnish on port 8449
Application protocol: http/1.1
finished in 5.02s, 995.55 req/s, 365.50MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H1)Traefik->(H1)->Varnish on port 8450
Application protocol: http/1.1
finished in 6.22s, 803.47 req/s, 294.94MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H2)Traefik->(H1)->Varnish on port 8450
Application protocol: h2
finished in 9.72s, 514.14 req/s, 188.73MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H1)H2O->(H1)->Varnish on port 8451
Application protocol: http/1.1
finished in 7.22s, 692.48 req/s, 254.22MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H2)H2O->(H1)->Varnish on port 8452
Application protocol: h2
finished in 7.45s, 670.91 req/s, 246.28MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H1)Nginx->(H1)->Varnish on port 8445
Application protocol: http/1.1
finished in 4.04s, 1238.06 req/s, 454.47MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout
### Client->(SSL/H2)Nginx->(H2)->Varnish on port 8445
Application protocol: h2
finished in 4.20s, 1191.06 req/s, 437.36MB/s
requests: 5000 total, 5000 started, 5000 done, 5000 succeeded, 0 failed, 0 errored, 0 timeout

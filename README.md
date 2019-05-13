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

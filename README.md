# Introduction

This is a docker compose setup to test the performance of the different combinations of varnish-cache sandwitches

## Howto

### Create SSL-certs
` ./bin/self-signed-tls ` (generate SSL certs with ./etc/ssl-managed/dns.ext as source)

### Launch tls-proxy
` docker-compose up `

### Install certs
https://www.google.no/search?&q=install+self+signed+cert+osx+keychain

## What does it do

Well. This is sort of a testsetup with varnish 6, h2-enabled. With NGINX, Hitch and haproxy as frontend ssl-balances

|port|what|
|----|----|
|443|haproxy -> varnish port 80 normal http|
|444|haproxy proxy-protocol -> Varnish port 81 proxy-protocol|
|445|haproxy proxy-protocol over UDS (Unix Domain Socket) -> Varnish UDS proxy protocol|
|446|nginx -> varnish
|447|hitch proxy-protocol -> Varnish port 81 proxy-protocol|

Backend is a nginx running owasp modsecurity for fun and profit

## Benchmarking

### H2Load

Please use h2load or similar tool to benchmark the setup

#### Install Ubuntu

`sudo apt-get install nghttp2-client`

#### Install Centos
`sudo yum install nghttp2`

#### Install OS X
`brew install nghttp2`

### Vegeta

#### Install Ubuntu / Centos

`go get -u github.com/tsenart/vegeta`

#### Install OS X

`brew install vegeta`




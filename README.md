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

Well. This is sort of a testsetup with varnish 6, h2-enabled. With NGINX, Hitch and haproxy as frontend ssl-balancers

|port|what|
|----|----|
|80| Varnish directly
|81| Varnish reciver for proxy-protocol
|81| haproxy -> varnish
|443|hithch -> varnish 
|444|nginx -> varnish
|445|haproxy -> varnish:80
|446|haproxy -> varnish:81
|447|haproxy -> UDS -> varnish
|448|haproxy tcp -> UDS -> vanrish

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




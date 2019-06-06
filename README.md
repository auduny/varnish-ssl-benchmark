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

## Hardcore machine with 64 Cores.

|what   |time   |reqs   |bw     |request|connect|1stbyte|savings|
|-----|---|---|---|---|---|----|---|
|Client->(H1)->Varnish on port 8081|1.31s|7609.58|21.84Gb/s|81.71ms|9.15ms|58.83ms|0.00%|
|Client->(H2)->Varnish on port 8081|1.63s|6117.56|17.52Gb/s|18.21ms|192.93ms|224.32ms|0.00%|
|Client->(H1)->HAProxy->(H1)->Varnish on port 8084|1.65s|6071.66|17.44Gb/s|31.72ms|11.07ms|49.42ms|20.00%|
|Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8448|3.33s|3001.08|8.64Gb/s|73.92ms|129.49ms|196.90ms|23.11%|
|Client->(SSL/H1)Haproxy->(H1)->Varnish on port 8445|3.34s|2989.77|8.56Gb/s|222.68ms|332.76ms|376.25ms|19.91%|
|Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|3.35s|2984.72|8.56Gb/s|67.24ms|140.16ms|191.31ms|23.22%|
|Client->(SSL/H1)Traefik->(H1)->Varnish on port 8450|3.43s|2918.20|8.4Gb/s|85.58ms|119.85ms|249.97ms|0.00%|
|Client->(SSL/H2)Haproxy->(H1)->Varnish on port 8445|3.57s|2800.34|8Gb/s|62.94ms|121.97ms|170.93ms|0.00%|
|Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish on port 8448|3.67s|2728.37|8015.28Mb/s|62.50ms|124.80ms|172.19ms|0.00%|
|Client->(SSL/H2)Nginx->(H2)->Varnish on port 8445|3.83s|2613.12|7676.32Mb/s|77.24ms|157.24ms|219.03ms|0.00%|
|Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|3.90s|2563.54|7530.72Mb/s|69.25ms|137.56ms|184.08ms|0.00%|
|Client->(H1)->Backend(Nginx) on port 8080|4.14s|2413.30|7086.72Mb/s|||||
|Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|4.36s|2292.56|6732.48Mb/s|103.97ms|185.22ms|240.15ms|23.11%|
|Client->(SSL/H2)Traefik->(H1)->Varnish on port 8450|4.53s|2209.38|6488.24Mb/s|64.64ms|136.02ms|192.64ms|0.00%|
|Client->(SSL/H1)Nginx->(H1)->Varnish on port 8445|5.14s|1944.24|5709.52Mb/s|104.41ms|212.85ms|851.08ms|85.09%|
|Client->(SSL/H2)Envoy->(H2)->Varnish on port 8449|5.93s|1619.34|4648.32Mb/s|76.10ms|95.39ms|209.46ms|0.00%|
|Client->(SSL/H1)H2O->(H1)->Varnish on port 8451|6.68s|1496.53|4395.28Mb/s|86.78ms|126.18ms|201.26ms|90.77%|
|Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|6.92s|1444.67|4243.92Mb/s|62.97ms|122.32ms|175.99ms|0.00%|
|Client->(SSL/H2)H2O->(H1)->Varnish on port 8452|8.00s|1250.64|3672.72Mb/s|92.69ms|222.44ms|347.02ms|0.00%|
|Client->(SSL/TCP)->Hitch->(UDS/H2)->Varnish on port 8444|11.58s|863.35|2536.32Mb/s|224.16ms|322.87ms|374.22ms|0.00%|
|Client->(SSL/TCP)->Hitch->(UDS/H1)->Varnish on port 8444|11.65s|858.71|2521.92Mb/s|249.38ms|340.85ms|387.99ms|19.91%|
|Client->(SSL/TCP)->Hitch->(H1)->Varnish on port 8443|11.78s|849.15|2493.84Mb/s|30.82ms|9.80ms|50.07ms|0.00%|
|Client->(SSL/TCP)->Hitch->(H2)->Varnish on port 8443|12.93s|773.54|2272.48Mb/s|226.25ms|347.63ms|401.93ms|0.00%|

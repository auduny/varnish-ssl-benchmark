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

|Nr|Port|What   |Time   |REQs   |BW     |Request|Connect|1stbyte|Savings|
|---|---|---|---|---|---|---|---|---|---|
|1|8081|(H1)->Varnish|1.31s|7613.79|21.84Gb/s|18.24ms|193.64ms|230.05ms|0.00%|
|2|8084|(H1)->HAProxy->(H1)->Varnish|1.46s|6856.60|19.68Gb/s|28.32ms|10.67ms|62.95ms|0.00%|
|3|8081|(H2)->Varnish|1.72s|5813.14|16.64Gb/s|33.45ms|11.16ms|49.44ms|20.00%|
|4|8445|(SSL/H1)Haproxy->(H1)->Varnish|3.25s|3081.48|8.8Gb/s|61.30ms|115.66ms|164.95ms|0.00%|
|5|8446|(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish|3.27s|3062.76|8.8Gb/s|61.65ms|124.95ms|175.73ms|0.00%|
|6|8445|(SSL/H2)Haproxy->(H1)->Varnish|3.32s|3008.29|8.64Gb/s|61.94ms|161.77ms|214.42ms|23.22%|
|7|8450|(SSL/H1)Traefik->(H1)->Varnish|3.44s|2908.85|8.32Gb/s|61.33ms|213.69ms|267.59ms|0.00%|
|8|8080|(H1)->Backend(Nginx)|3.44s|2903.35|8.32Gb/s|67.72ms|9.94ms|45.21ms|0.00%|
|9|8447|(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|3.50s|2855.27|8.16Gb/s|66.43ms|112.32ms|164.41ms|0.00%|
|10|8448|(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish|3.61s|2772.21|8144.08Mb/s|68.25ms|123.98ms|178.36ms|19.81%|
|11|8446|(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish|3.69s|2709.16|7958.48Mb/s|70.10ms|117.46ms|169.82ms|23.11%|
|12|8447|(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|3.74s|2674.59|7856.96Mb/s|70.92ms|119.09ms|173.74ms|23.11%|
|13|8450|(SSL/H2)Traefik->(H1)->Varnish|4.50s|2222.63|6527.12Mb/s|86.25ms|120.85ms|189.18ms|90.79%|
|14|8448|(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|4.96s|2015.08|5917.92Mb/s|76.80ms|164.97ms|205.45ms|0.00%|
|15|8449|(SSL/H2)Envoy->(H2)->Varnish|5.07s|1846.27|5274.48Mb/s|76.24ms|103.54ms|218.07ms|0.00%|
|16|8445|(SSL/H2)Nginx->(H2)->Varnish|5.57s|1796.41|5277.12Mb/s|81.02ms|162.28ms|204.87ms|23.34%|
|17|8445|(SSL/H1)Nginx->(H1)->Varnish|5.96s|1677.96|4927.52Mb/s|87.00ms|176.67ms|220.43ms|0.00%|
|18|8451|(SSL/H1)H2O->(H1)->Varnish|6.18s|1617.10|4749.36Mb/s|88.58ms|192.12ms|281.07ms|0.00%|
|19|8452|(SSL/H2)H2O->(H1)->Varnish|8.86s|1128.30|3313.44Mb/s|118.47ms|199.18ms|982.81ms|84.99%|
|20|8449|(SSL/H1)Envoy->(H2)->Varnish|9.20s|1050.69|3001.44Mb/s|174.46ms|156.83ms|397.59ms|0.00%|
|21|8443|(SSL/TCP)->Hitch->(H1)->Varnish|11.51s|869.13|2552.48Mb/s|220.94ms|339.96ms|385.78ms|0.00%|
|22|8444|(SSL/TCP)->Hitch->(UDS/H1)->Varnish|11.68s|855.92|2513.68Mb/s|225.24ms|309.79ms|361.42ms|0.00%|
|23|8444|(SSL/TCP)->Hitch->(UDS/H2)->Varnish|11.98s|835.04|2453.12Mb/s|229.75ms|371.14ms|418.71ms|19.91%|
|24|8443|(SSL/TCP)->Hitch->(H2)->Varnish|12.67s|789.00|2317.84Mb/s|243.66ms|356.16ms|397.60ms|19.91%|


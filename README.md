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

|what   |time   |reqs   |bw     |request|connect|1stbyte|savings|
|-----|---|---|---|---|---|----|---|----|
|Client->(H1)->Varnish on port 8081|1.35s|7431.09|2.66GB|83.82ms|10.20ms|57.97ms|0.00%|
|Client->(H1)->HAProxy->(H1)->Varnish on port 8084|1.57s|6359.07|2.28GB|18.68ms|11.26ms|49.59ms|20.00%|
|Client->(H2)->Varnish on port 8081|1.75s|5718.80|2.05GB|18.68ms|197.69ms|225.60ms|0.00%|
|Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish on port 8448|3.46s|2891.51|1.04GB|72.08ms|157.73ms|204.76ms|0.00%|
|Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|3.51s|2852.78|1.02GB|70.68ms|143.66ms|200.88ms|23.11%|
|Client->(SSL/H1)Traefik->(H1)->Varnish on port 8450|3.54s|2822.24|1.01GB|109.05ms|125.90ms|287.24ms|0.00%|
|Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|3.58s|2791.24|1.00GB|71.25ms|128.20ms|181.60ms|23.22%|
|Client->(SSL/H1)Nginx->(H1)->Varnish on port 8445|3.75s|2668.94|979.71MB|124.04ms|204.85ms|1.36s|85.48%|
|Client->(SSL/H2)Nginx->(H2)->Varnish on port 8445|3.77s|2655.49|975.10MB|69.43ms|167.78ms|223.38ms|0.00%|
|Client->(SSL/H2)Haproxy->(H1)->Varnish on port 8445|3.77s|2653.68|974.44MB|101.88ms|190.82ms|246.45ms|0.00%|
|Client->(H1)->Backend(Nginx) on port 8080|4.27s|2340.87|859.25MB|||||
|Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|4.34s|2302.06|845.32MB|68.51ms|107.46ms|160.87ms|0.00%|
|Client->(SSL/H2)Traefik->(H1)->Varnish on port 8450|4.35s|2298.51|843.75MB|63.05ms|232.16ms|281.91ms|0.00%|
|Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8448|4.71s|2121.23|778.71MB|78.87ms|146.02ms|207.07ms|23.11%|
|Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|5.15s|1943.29|713.58MB|64.27ms|175.12ms|245.26ms|0.00%|
|Client->(SSL/H1)Haproxy->(H1)->Varnish on port 8445|6.53s|1531.60|562.22MB|249.02ms|396.64ms|445.23ms|19.91%|
|Client->(SSL/H1)H2O->(H1)->Varnish on port 8451|6.87s|1455.52|534.36MB|83.20ms|124.37ms|191.22ms|90.82%|
|Client->(SSL/H2)H2O->(H1)->Varnish on port 8452|9.09s|1100.35|403.92MB|91.78ms|221.42ms|321.03ms|0.00%|
|Client->(SSL/TCP)->Hitch->(H1)->Varnish on port 8443|12.25s|816.26|299.65MB|30.34ms|9.93ms|100.61ms|0.00%|
|Client->(SSL/TCP)->Hitch->(UDS/H2)->Varnish on port 8444|12.97s|771.03|283.14MB|254.85ms|405.35ms|466.21ms|0.00%|
|Client->(SSL/TCP)->Hitch->(UDS/H1)->Varnish on port 8444|13.26s|753.92|276.77MB|299.80ms|403.51ms|451.13ms|19.91%|
|Client->(SSL/TCP)->Hitch->(H2)->Varnish on port 8443|15.54s|643.52|236.31MB|235.53ms|351.59ms|396.13ms|0.00%|

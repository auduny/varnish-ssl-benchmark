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
|Client->(H1)->HAProxy->(H1)->Varnish on port 8084|1.46s|6852.40|19.68Gb/s|29.20ms|9.67ms|48.21ms|20.02%|
|Client->(H1)->Varnish on port 8081|1.75s|5698.67|16.32Gb/s|71.29ms|9.71ms|60.06ms|0.00%|
|Client->(H2)->Varnish on port 8081|1.97s|5073.68|14.56Gb/s|29.20ms|10.64ms|315.38ms|0.00%|
|Client->(SSL/H1)Traefik->(H1)->Varnish on port 8450|3.35s|2987.40|8.56Gb/s|114.89ms|147.72ms|332.11ms|0.00%|
|Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8448|3.36s|2976.86|8.56Gb/s|66.26ms|138.20ms|192.46ms|23.11%|
|Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|3.41s|2929.71|8.4Gb/s|65.02ms|124.87ms|175.51ms|23.14%|
|Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|3.46s|2893.18|8.32Gb/s|64.04ms|156.47ms|206.68ms|0.00%|
|Client->(SSL/H1)Haproxy->(H1)->Varnish on port 8445|3.49s|2865.41|8.24Gb/s|222.69ms|320.87ms|360.37ms|19.91%|
|Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish on port 8447|3.54s|2826.85|8.08Gb/s|64.21ms|124.95ms|171.71ms|0.00%|
|Client->(SSL/H1)Nginx->(H1)->Varnish on port 8445|3.59s|2783.65|8174.64Mb/s|105.43ms|197.83ms|913.42ms|85.04%|
|Client->(SSL/H2)Haproxy->(H1)->Varnish on port 8445|3.61s|2773.72|8148.16Mb/s|65.70ms|129.39ms|182.81ms|0.00%|
|Client->(H1)->Backend(Nginx) on port 8080|3.63s|2757.64|8097.84Mb/s|||||
|Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish on port 8446|3.65s|2739.89|8046.08Mb/s|68.28ms|120.18ms|170.54ms|23.22%|
|Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish on port 8448|3.77s|2652.88|7793.52Mb/s|63.15ms|125.77ms|173.29ms|0.00%|
|Client->(SSL/H2)Traefik->(H1)->Varnish on port 8450|4.38s|2285.35|6711.36Mb/s|63.37ms|130.60ms|188.84ms|0.00%|
|Client->(SSL/H1)H2O->(H1)->Varnish on port 8451|7.67s|1303.80|3829.2Mb/s|83.67ms|127.24ms|198.27ms|90.75%|
|Client->(SSL/H2)Envoy->(H2)->Varnish on port 8449|7.06s|1294.21|3608.16Mb/s|74.79ms|100.98ms|220.05ms|0.00%|
|Client->(SSL/H2)H2O->(H1)->Varnish on port 8452|8.10s|1234.74|3626Mb/s|100.78ms|203.00ms|706.03ms|0.00%|
|Client->(SSL/H2)Nginx->(H2)->Varnish on port 8445|9.73s|1027.89|3019.6Mb/s|65.94ms|149.49ms|211.53ms|0.00%|
|Client->(SSL/TCP)->Hitch->(UDS/H1)->Varnish on port 8444|11.05s|905.13|2658.24Mb/s|241.87ms|329.26ms|368.97ms|19.91%|
|Client->(SSL/TCP)->Hitch->(UDS/H2)->Varnish on port 8444|11.57s|864.57|2539.84Mb/s|212.26ms|318.84ms|358.53ms|0.00%|
|Client->(SSL/TCP)->Hitch->(H1)->Varnish on port 8443|11.59s|862.76|2533.76Mb/s|28.09ms|15.50ms|43.58ms|0.00%|
|Client->(SSL/TCP)->Hitch->(H2)->Varnish on port 8443|12.54s|797.33|2342.32Mb/s|222.82ms|329.01ms|369.73ms|0.00%|
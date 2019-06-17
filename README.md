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


### H2Load

We use [h2load](https://nghttp2.org/documentation/h2load.1.html#) from the
[nghttp2 package](https://github.com/nghttp2/nghttp2) from [our benchmark script](benchmark.sh)

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

# Run 2

|Nr|Port|What   |Time   |REQs   |BW     |Request|Connect|1stbyte|Savings|
|---|---|---|---|---|---|---|---|---|---|
|1|8081|(H1)->Varnish|1.32s|7562.82|21.68Gb/s|25.72ms|11.32ms|44.08ms|0.00%|
|2|8081|(H2)->Varnish|1.96s|5094.16|14.64Gb/s|37.97ms|11.48ms|49.33ms|20.00%|
|3|8084|(H1)->HAProxy->(H1)->Varnish|2.17s|4614.62|13.2Gb/s|32.77ms|14.48ms|41.64ms|0.00%|
|4|8445|(SSL/H1)Nginx->(H1)->Varnish|3.31s|3023.13|8.64Gb/s|62.54ms|118.88ms|168.97ms|0.00%|
|5|8450|(SSL/H1)Traefik->(H1)->Varnish|3.42s|2920.73|8.4Gb/s|65.11ms|122.08ms|174.36ms|0.00%|
|6|8445|(SSL/H1)Haproxy->(H1)->Varnish|3.45s|2899.87|8.32Gb/s|64.98ms|127.65ms|177.87ms|0.00%|
|7|8445|(SSL/H2)Nginx->(H2)->Varnish|3.61s|2773.84|8148.48Mb/s|68.01ms|126.87ms|180.06ms|23.22%|
|8|8447|(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|3.72s|2689.92|7899.36Mb/s|67.40ms|143.45ms|197.89ms|0.00%|
|9|8080|(H1)->Backend(Nginx)|4.06s|2463.18|7233.2Mb/s|79.99ms|9.55ms|57.24ms|0.00%|
|10|8450|(SSL/H2)Traefik->(H1)->Varnish|4.39s|2280.03|6695.76Mb/s|84.17ms|116.64ms|189.42ms|90.68%|
|11|8447|(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|4.76s|2098.92|6165.84Mb/s|73.36ms|143.70ms|186.49ms|23.11%|
|12|8449|(SSL/H2)Envoy->(H2)->Varnish|4.83s|2068.31|6074.72Mb/s|73.13ms|102.09ms|201.03ms|0.00%|
|13|8449|(SSL/H1)Envoy->(H2)->Varnish|4.88s|1959.12|5704.24Mb/s|72.71ms|107.18ms|210.48ms|0.00%|
|14|8445|(SSL/H2)Haproxy->(H1)->Varnish|5.79s|1726.15|5070.8Mb/s|87.58ms|169.64ms|216.78ms|23.22%|
|15|8452|(SSL/H2)H2O->(H1)->Varnish|7.07s|1414.67|4154.4Mb/s|99.64ms|191.18ms|359.35ms|85.27%|
|16|8446|(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish|7.13s|1402.15|4117.6Mb/s|111.97ms|208.73ms|256.03ms|0.00%|
|17|8448|(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|7.72s|1295.26|3804Mb/s|140.02ms|257.78ms|304.65ms|0.00%|
|18|8451|(SSL/H1)H2O->(H1)->Varnish|7.86s|1271.64|3734.72Mb/s|104.60ms|219.24ms|677.29ms|0.00%|
|19|8448|(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish|8.42s|1188.05|3490.16Mb/s|156.78ms|269.31ms|334.04ms|19.78%|
|20|8446|(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish|8.72s|1147.25|3370.24Mb/s|142.87ms|216.51ms|307.24ms|23.11%|
|21|8444|(SSL/TCP)->Hitch->(UDS/H1)->Varnish|11.41s|876.49|2574.08Mb/s|219.20ms|330.27ms|366.15ms|0.00%|
|22|8443|(SSL/TCP)->Hitch->(H1)->Varnish|11.69s|855.59|2512.72Mb/s|224.76ms|336.06ms|378.58ms|0.00%|
|23|8444|(SSL/TCP)->Hitch->(UDS/H2)->Varnish|11.72s|852.97|2505.76Mb/s|225.74ms|323.94ms|363.69ms|19.91%|
|24|8443|(SSL/TCP)->Hitch->(H2)->Varnish|12.58s|795.16|2336Mb/s|241.99ms|345.62ms|385.75ms|19.91%|

# Run 3 with better hithc

|Nr|Port|What   |Time   |REQs   |BW     |Request|Connect|1stbyte|Savings|
|---|---|---|---|---|---|---|---|---|---|
|1|8081|(H1)->Varnish|1.28s|7840.47|22.48Gb/s|17.45ms|187.97ms|213.93ms|0.00%|
|2|8084|(H1)->HAProxy->(H1)->Varnish|1.44s|6929.78|19.84Gb/s|32.90ms|256.37ms|309.90ms|0.00%|
|3|8081|(H2)->Varnish|1.70s|5887.20|16.88Gb/s|32.90ms|11.70ms|51.03ms|20.00%|
|4|8446|(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish|3.36s|2976.68|8.56Gb/s|63.23ms|128.33ms|179.16ms|0.00%|
|5|8445|(SSL/H1)Haproxy->(H1)->Varnish|3.36s|2973.02|8.56Gb/s|63.49ms|119.11ms|169.61ms|0.00%|
|6|8445|(SSL/H1)Nginx->(H1)->Varnish|3.40s|2943.87|8.48Gb/s|64.18ms|131.98ms|193.51ms|0.00%|
|7|8448|(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|3.47s|2884.12|8.24Gb/s|65.37ms|136.07ms|185.18ms|0.00%|
|8|8450|(SSL/H1)Traefik->(H1)->Varnish|3.49s|2861.94|8.24Gb/s|61.85ms|242.44ms|298.07ms|0.00%|
|9|8447|(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|3.55s|2818.20|8.08Gb/s|65.67ms|130.99ms|182.77ms|0.00%|
|10|8445|(SSL/H2)Nginx->(H2)->Varnish|3.60s|2774.09|8149.2Mb/s|67.86ms|145.85ms|208.85ms|23.11%|
|11|8080|(H1)->Backend(Nginx)|3.99s|2505.44|7357.28Mb/s|78.66ms|10.10ms|51.18ms|0.00%|
|12|8443|(SSL/TCP)->Hitch->(H1)->Varnish|4.02s|2486.02|7300.96Mb/s|75.40ms|123.67ms|181.69ms|0.00%|
|13|8445|(SSL/H2)Haproxy->(H1)->Varnish|4.09s|2446.98|7188.32Mb/s|74.38ms|126.94ms|179.02ms|23.22%|
|14|8443|(SSL/TCP)->Hitch->(H2)->Varnish|4.23s|2366.59|6952.4Mb/s|75.04ms|127.68ms|178.79ms|19.94%|
|15|8444|(SSL/TCP)->Hitch->(UDS/H2)->Varnish|4.41s|2265.37|6655.04Mb/s|80.86ms|138.93ms|225.83ms|19.91%|
|16|8450|(SSL/H2)Traefik->(H1)->Varnish|4.53s|2205.72|6477.52Mb/s|86.91ms|122.29ms|192.15ms|90.78%|
|17|8446|(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish|4.56s|2192.85|6441.76Mb/s|71.09ms|156.73ms|205.89ms|23.11%|
|18|8449|(SSL/H1)Envoy->(H2)->Varnish|4.35s|2153.85|6116.8Mb/s|70.62ms|97.84ms|206.49ms|0.00%|
|19|8447|(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|4.74s|2108.37|6193.6Mb/s|65.67ms|168.61ms|221.82ms|23.11%|
|20|8444|(SSL/TCP)->Hitch->(UDS/H1)->Varnish|5.12s|1954.78|5740.88Mb/s|78.51ms|147.33ms|198.88ms|0.00%|
|21|8448|(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish|5.37s|1860.56|5465.84Mb/s|82.59ms|164.83ms|210.98ms|19.81%|
|22|8449|(SSL/H2)Envoy->(H2)->Varnish|5.49s|1784.53|4938.88Mb/s|85.89ms|122.39ms|246.22ms|0.00%|
|23|8451|(SSL/H1)H2O->(H1)->Varnish|6.81s|1467.43|4309.84Mb/s|89.91ms|201.85ms|375.65ms|0.00%|
|24|8452|(SSL/H2)H2O->(H1)->Varnish|9.06s|1103.21|3239.76Mb/s|124.76ms|199.36ms|1.12s|84.90%|
ay@oa68-node-01:~/

# Threaded benchmark

|Nr|Port|What   |Time   |REQs   |BW     |Request|Connect|1stbyte|Savings|
|---|---|---|---|---|---|---|---|---|---|
|1|8081|(H2)->Varnish|316.73ms|31572.53|90.56Gb/s|156.55ms||26.74ms|20.00%|
|2|8445|(SSL/H1)Nginx->(H1)->Varnish|501.24ms|19950.40|57.2Gb/s|32.37ms|36.50ms|54.84ms|0.00%|
|3|8446|(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish|509.69ms|19619.92|56.24Gb/s|31.11ms|44.86ms|63.81ms|0.00%|
|4|8448|(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish|514.96ms|19419.10|55.68Gb/s|33.47ms|34.28ms|55.33ms|19.81%|
|5|8448|(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|525.67ms|19023.27|54.56Gb/s|31.38ms|34.89ms|55.68ms|0.00%|
|6|8447|(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|535.51ms|18673.72|53.6Gb/s|32.78ms|37.84ms|59.64ms|23.14%|
|7|8445|(SSL/H1)Haproxy->(H1)->Varnish|539.19ms|18546.48|53.2Gb/s|34.36ms|53.66ms|65.88ms|0.00%|
|8|8444|(SSL/TCP)->Hitch->(UDS/H1)->Varnish|556.66ms|17964.25|51.52Gb/s|32.33ms|25.54ms|35.82ms|0.00%|
|9|8443|(SSL/TCP)->Hitch->(H1)->Varnish|557.93ms|17923.23|51.44Gb/s|33.40ms|26.12ms|41.61ms|0.00%|
|10|8443|(SSL/TCP)->Hitch->(H2)->Varnish|602.28ms|16603.63|47.6Gb/s|35.91ms|25.00ms|34.02ms|20.00%|
|11|8444|(SSL/TCP)->Hitch->(UDS/H2)->Varnish|696.79ms|14351.46|41.2Gb/s|35.17ms|26.90ms|46.92ms|20.00%|
|12|8445|(SSL/H2)Nginx->(H2)->Varnish|722.72ms|13836.64|39.68Gb/s|33.79ms|41.02ms|62.17ms|23.11%|
|13|8450|(SSL/H2)Traefik->(H1)->Varnish|778.06ms|12852.53|36.88Gb/s|53.39ms|55.31ms|126.11ms|90.93%|
|14|8447|(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|923.80ms|10824.90|31.04Gb/s|33.52ms|49.45ms|68.99ms|0.00%|
|15|8084|(H1)->HAProxy->(H1)->Varnish|1.15s|8705.87|24.96Gb/s|156.55ms||280.11ms|0.00%|
|16|8081|(H1)->Varnish|1.16s|8598.02|24.64Gb/s|156.55ms||212.23ms|0.00%|
|17|8446|(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish|1.27s|7855.89|22.56Gb/s|31.11ms|40.05ms|124.32ms|23.22%|
|18|8450|(SSL/H1)Traefik->(H1)->Varnish|1.30s|7693.17|22.08Gb/s|35.31ms|156.78ms|183.32ms|0.00%|
|19|8445|(SSL/H2)Haproxy->(H1)->Varnish|1.33s|7498.05|21.52Gb/s|34.36ms|32.19ms|167.26ms|23.33%|
|20|8080|(H1)->Backend(Nginx)|3.50s|2859.95|8.24Gb/s|156.55ms||1.40s|0.00%|
|21|8452|(SSL/H2)H2O->(H1)->Varnish|5.85s|1708.26|5016.56Mb/s|351.63ms|103.50ms|1.27s|85.91%|
|22|8451|(SSL/H1)H2O->(H1)->Varnish|7.20s|1388.69|4078.56Mb/s|452.57ms|135.12ms|311.93ms|0.00%|

# Final Run

|Nr|Port|What   |Time   |REQs   |BW     |Request|Connect|1stbyte|Savings|
|---|---|---|---|---|---|---|---|---|---|
|1|8081|(H2)->Varnish|269.57ms|37095.70|106.4Gb/s|18.35ms|1.06ms|21.67ms|20.00%|
|2|8445|(SSL/H1)Haproxy->(H1)->Varnish|588.57ms|16990.25|48.72Gb/s|29.95ms|57.54ms|65.88ms|0.00%|
|3|8448|(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|616.19ms|16228.79|46.56Gb/s|27.19ms|42.56ms|56.76ms|0.00%|
|4|8443|(SSL/TCP)->Hitch->(H1)->Varnish|630.63ms|15857.21|45.44Gb/s|30.63ms|18.40ms|33.97ms|0.00%|
|5|8444|(SSL/TCP)->Hitch->(UDS/H1)->Varnish|638.71ms|15656.53|44.88Gb/s|30.13ms|18.90ms|22.20ms|0.00%|
|6|8446|(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish|645.85ms|15483.42|44.4Gb/s|29.68ms|34.45ms|43.73ms|0.00%|
|7|8445|(SSL/H1)Nginx->(H1)->Varnish|658.85ms|15177.96|43.52Gb/s|28.65ms|26.04ms|35.33ms|0.00%|
|8|8447|(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|749.68ms|13339.02|38.24Gb/s|31.64ms|28.58ms|42.79ms|23.11%|
|9|8450|(SSL/H2)Traefik->(H1)->Varnish|752.62ms|13286.86|38.08Gb/s|53.20ms|45.20ms|92.04ms|90.92%|
|10|8446|(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish|805.00ms|12422.30|35.6Gb/s|33.12ms|26.37ms|45.50ms|23.22%|
|11|8445|(SSL/H2)Nginx->(H2)->Varnish|813.81ms|12287.94|35.28Gb/s|30.71ms|25.66ms|41.91ms|23.11%|
|12|8443|(SSL/TCP)->Hitch->(H2)->Varnish|820.75ms|12183.95|34.96Gb/s|37.24ms|18.68ms|26.00ms|20.00%|
|13|8444|(SSL/TCP)->Hitch->(UDS/H2)->Varnish|834.42ms|11984.43|34.4Gb/s|35.37ms|19.65ms|50.21ms|20.00%|
|14|8448|(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish|878.12ms|11387.95|32.64Gb/s|33.68ms|29.15ms|43.92ms|19.81%|
|15|8447|(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish|1.01s|9914.66|28.4Gb/s|36.03ms|35.32ms|45.17ms|0.00%|
|16|8081|(H1)->Varnish|1.15s|8729.39|25.04Gb/s|11.33ms|176.32ms|208.10ms|0.00%|
|17|8084|(H1)->HAProxy->(H1)->Varnish|1.18s|8444.49|24.24Gb/s|17.17ms|259.10ms|306.82ms|0.00%|
|18|8450|(SSL/H1)Traefik->(H1)->Varnish|1.21s|8242.77|23.6Gb/s|34.55ms|144.77ms|174.04ms|0.00%|
|19|8445|(SSL/H2)Haproxy->(H1)->Varnish|1.47s|6822.11|19.6Gb/s|36.92ms|27.52ms|162.52ms|23.33%|
|20|8080|(H1)->Backend(Nginx)|3.35s|2981.73|8.56Gb/s|118.44ms|224.28ms|1.45s|0.00%|
|21|8452|(SSL/H2)H2O->(H1)->Varnish|5.71s|1750.15|5139.6Mb/s|343.01ms|92.05ms|1.31s|85.73%|
|22|8451|(SSL/H1)H2O->(H1)->Varnish|6.93s|1443.46|4239.44Mb/s|442.08ms|137.30ms|320.20ms|0.00%|

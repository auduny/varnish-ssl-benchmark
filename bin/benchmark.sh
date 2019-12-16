#!/bin/bash -x

sleep 10


CLIENTSLIST="100 500"
REQUESTSLIST="500 1000"

CLIENTS=${BENCH_CLIENTS:-200}
REQUESTS=${BENCH_REQUESTS:-10000}
CORES=`grep -c ^processor /proc/cpuinfo`

RED='\033[0;31m'
NC='\033[0m' # No Color

rm /tmp/bin/output.txt
echo | tee -a /tmp/bin/output.txt
echo "=====================================================" |tee -a /tmp/bin/output.txt
echo "Running with $CLIENTS clients and $REQUESTS requests on $CORES cores" | tee -a /tmp/bin/output.txt


TYPES="
Client->(H1)->Backend(Nginx):8080:--h1
Client->(H1)->Varnish:8081:--h1 
Client->(H2)->Varnish:8081
Client->(H1)->HAProxy->(H1)->Varnish:8084:--h1
Client->(SSL/TCP)->Hitch->(H1)->Varnish:8443:--h1
Client->(SSL/TCP)->Hitch->(H2)->Varnish:8443:
Client->(SSL/TCP)->Hitch->(UDS/H1)->Varnish:8444:--h1
Client->(SSL/TCP)->Hitch->(UDS/H2)->Varnish:8444:
Client->(SSL/H1)Haproxy->(H1)->Varnish:8445:--h1
Client->(SSL/H2)Haproxy->(H1)->Varnish:8445:
Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish:8446:--h1
Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish:8446
Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:8447:--h1
Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:8447:
Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:8448:--h1
Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish:8448
Client->(SSL/H1)Traefik->(H1)->Varnish:8450:--h1
Client->(SSL/H2)Traefik->(H1)->Varnish:8450
Client->(SSL/H1)H2O->(H1)->Varnish:8451:--h1
Client->(SSL/H2)H2O->(H1)->Varnish:8452
Client->(SSL/H1)Nginx->(H1)->Varnish:8445:--h1
Client->(SSL/H2)Nginx->(H2)->Varnish:8445:
"

FAILED="
Client->(SSL/H1)Envoy->(H2)->Varnish:8449:--h1
Client->(SSL/H2)Envoy->(H2)->Varnish:8449
"


for type in $TYPES; do
    text=$(echo $type | cut -f1 -d:)
    port=$(echo $type | cut -f2 -d:)
    opts=$(echo $type | cut -f3 -d:)
    echo -e "${RED}$text on port $port${NC}" | tee -a /tmp/bin/output.txt
    if [ "$port" == "8080" ] || [ "$port" == "8081" ] || [ "$port" == "8084" ]; then
        url=http://127.0.0.1
    else
        url=https://127.0.0.1
    fi
    h2load -t $CORES $opts $url:$port -c $CLIENTS -n $REQUESTS | grep -v progress |tee -a /tmp/bin/output.txt
    echo | tee -a /tmp/bin/output.txt
done

exit

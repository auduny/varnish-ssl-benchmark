#!/bin/bash -x

CLIENTSLIST="100 500"
REQUESTSLIST="500 1000"

CLIENTS=100
REQUESTS=2000

RED='\033[0;31m'
NC='\033[0m' # No Color

TYPES="
Client->(H1)->Varnish:8081:--h1 
Client->(H2)->Varnish:8081
Client->(H1)->HAProxy->(H1)->Varnish:8084:--h1
Client->(SSL/TCP)->Hitch->(H1)->Varnish:8443:--h1
Client->(SSL/TCP)->Hitch->(H2)->Varnish:8443:
Client->(SSL/H1)->Nginx->(H1)->Varnish:8444:--h1
Client->(SSL/H2)->Nginx->(H1)->Varnish:8444:
Client->(SSL/H1)Haproxy->(H1)->Varnish:8445:--h1
Client->(SSL/H2)Haproxy->(H1)->Varnish:8445:
Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish:8446:--h1
Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish:8446
Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:8447:--h1
Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:8447:
Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:8448:--h1
Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish:8448
Client->(SSL/H1)Envoy->(H2)->Varnish:8449:--h1
Client->(SSL/H2)Envoy->(H2)->Varnish:8449
Client->(SSL/H1)Traefik->(H1)->Varnish:8450:--h1
Client->(SSL/H2)Traefik->(H1)->Varnish:8450
"



for type in $TYPES;do
    text=$(echo $type | cut -f1 -d:)
    port=$(echo $type| cut -f2 -d:)
    opts=$(echo $type | cut -f3 -d:)
    echo -e "${RED}$text${NC}"
    if [ "$port" == "8081" ] || [ "$port" == "8084" ];then
        url=http://localhost
    else
        url=https://localhost
    fi
    h2load $opts $url:$port -c $CLIENTS -n $REQUESTS |grep -v progress |egrep '^(finished|request|Application)'
done

exit;





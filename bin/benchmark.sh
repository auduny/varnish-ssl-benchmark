#!/bin/bash

CLIENTSLIST="100 500"
REQUESTSLIST="500 1000"

CLIENTS=100
REQUESTS=500

RED='\033[0;31m'
NC='\033[0m' # No Color

TYPES="
Client->(H1)->Varnish:80:--h1 
Client->(H2)->Varnish:80
Client->(H1)->HAProxy->(H1)->Varnish:82:--h1
Client->(SSL/TCP)->Hitch->(H1)->Varnish:443:--h1
Client->(SSL/TCP)->Hitch->(H2)->Varnish:443:
Client->(SSL/H1)->Nginx->(H1)->Varnish:444:--h1
Client->(SSL/H2)->Nginx->(H1)->Varnish:444:
Client->(SSL/H1)Haproxy->(H1)->Varnish:445:--h1
Client->(SSL/H2)Haproxy->(H1)->Varnish:445:
Client->(SSL/H1)Haproxy->(H1/Proxy-Protocol)->Varnish:446:--h1
Client->(SSL/H2)Haproxy->(H1/Proxy-Protocol)->Varnish:446
Client->(SSL/H1)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:447:--h1
Client->(SSL/H2)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:447:
Client->(SSL/TCP)Haproxy->(UDS/H1/Proxy-Protocol)->Varnish:448:--h1
Client->(SSL/TCP)Haproxy->(UDS/H2/Proxy-Protocol)->Varnish:448
Client->(SSL/H1)Envoy->(H2)->Varnish:449:--h1
Client->(SSL/H2)Envoy->(H2)->Varnish:449:
"



for type in $TYPES;do
    text=$(echo $type | cut -f1 -d:)
    port=$(echo $type| cut -f2 -d:)
    opts=$(echo $type | cut -f3 -d:)
    echo -e "${RED}$text${NC}"
    if [ "$port" == "80" ] || [ "$port" == "82"];then
        url=http://localhost
    else
        url=https://localhost
    fi
    h2load $opts $url:$port -c $CLIENTS -n $REQUESTS |grep -v progress |egrep '^(finished|request|Application)'
done

exit;





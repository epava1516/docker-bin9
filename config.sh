#!/bin/bash

set -xeu


NAMED_CONF=/etc/bind/named.conf
DEF_CONF=/var/named/default.conf
ZONE_DIR=/var/named/zones.d
ZONE_FILE=$ZONE_DIR/$ZONE

mkdir -p $ZONE_DIR

cat > $NAMED_CONF <<EOF
options {
  directory "/var/named";
  pid-file "/var/run/named/named.pid";

  recursion yes;
  allow-recursion { any; };
  allow-query { any; };

  dnssec-enable yes;
  dnssec-validation yes;

  auth-nxdomain no;
  listen-on { any; };
  forwarders { 
    $NET_GATEWAY;
  };
};

include "$DEF_CONF";
EOF

if [[ ! -f "$DEF_CONF" ]]; then
cat > $DEF_CONF <<EOF
zone "$ZONE" IN {
  type master;
  file "zones.d/$ZONE";
};
EOF
fi

if [[ ! -f "$ZONE_FILE" ]]; then
cat > $ZONE_FILE <<EOF
\$TTL 86400

@ IN SOA $ZONE. root.$ZONE. (
  2017062705
  3600
  900
  604800
  86400
)

@      IN NS dns.$ZONE.
dns    IN A  $DNS_IP
EOF
fi

named -c $NAMED_CONF -g -u bind

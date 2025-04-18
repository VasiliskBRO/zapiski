#!/bin/bash
ZONE_DOMAIN="au-team.irpo"
REVERSE_ZONE_11="11.168.192.in-addr.arpa" # Для 192.168.11.0/26
REVERSE_ZONE_12="12.168.192.in-addr.arpa" # Для 192.168.12.0/28
REVERSE_ZONE_21="21.168.192.in-addr.arpa" # Для 192.168.21.0/27

NAMED_CONF_OPTIONS="/etc/bind/named.conf.options"
NAMED_CONF_DEFAULT_ZONES="/etc/bind/named.conf.default-zones"
ZONE_DIR="/etc/bind"

FORWARD_ZONE_FILE="$ZONE_DIR/$ZONE_DOMAIN"
REVERSE_ZONE_FILE_11="$ZONE_DIR/11.168.192"
REVERSE_ZONE_FILE_12="$ZONE_DIR/12.168.192"
REVERSE_ZONE_FILE_21="$ZONE_DIR/21.168.192"

HQ_SRV_IP="192.168.11.1"
HQ_CLI_IP_STATIC="192.168.12.1" # Начальный IP до DHCP
HQ_RTR_IP_VLAN100="192.168.11.61"
HQ_RTR_IP_VLAN200="192.168.12.14"
BR_SRV_IP="192.168.21.1"
BR_RTR_IP="192.168.21.30"

# Email администратора для SOA (замените @ на .)
ADMIN_EMAIL="admin.$ZONE_DOMAIN."
# Имя основного NS сервера для зон
PRIMARY_NS="hq-srv.$ZONE_DOMAIN."

apt update
apt install -y bind9 dnsutils

sleep 2

cat << EOF > $NAMED_CONF_OPTIONS
options {
        directory "/var/cache/bind";

        forwarders {
                8.8.8.8;
        };

        dnssec-validation yes;
        recursion yes;
        allow-query { any; };
        listen-on { any; };
};
EOF

sleep 2

cat << EOF >> $NAMED_CONF_DEFAULT_ZONES

zone "$ZONE_DOMAIN" {
        type master;
        file "$FORWARD_ZONE_FILE";
};

zone "$REVERSE_ZONE_11" {
        type master;
        file "$REVERSE_ZONE_FILE_11";
};

zone "$REVERSE_ZONE_12" {
        type master;
        file "$REVERSE_ZONE_FILE_12";
};

zone "$REVERSE_ZONE_21" {
        type master;
        file "$REVERSE_ZONE_FILE_21";
};
EOF

sleep 2

cat << EOF > $FORWARD_ZONE_FILE
\$TTL    604800 ; 1 week
@       IN      SOA     $PRIMARY_NS $ADMIN_EMAIL (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $PRIMARY_NS
hq-srv          IN      A       $HQ_SRV_IP
hq-cli          IN      A       $HQ_CLI_IP_STATIC 
hq-rtr          IN      A       $HQ_RTR_IP_VLAN100 
hq-rtr          IN      A       $HQ_RTR_IP_VLAN200 
br-srv          IN      A       $BR_SRV_IP
br-rtr          IN      A       $BR_RTR_IP
moodle          IN      CNAME   hq-srv.$ZONE_DOMAIN.
wiki            IN      CNAME   br-srv.$ZONE_DOMAIN. 
mon             IN      A       $HQ_SRV_IP 

EOF

sleep 2

cat << EOF > $REVERSE_ZONE_FILE_11
\$TTL    604800
@       IN      SOA     $PRIMARY_NS $ADMIN_EMAIL (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $PRIMARY_NS
1       IN      PTR     hq-srv.$ZONE_DOMAIN.
61      IN      PTR     hq-rtr.$ZONE_DOMAIN. 
EOF

sleep 2

cat << EOF > $REVERSE_ZONE_FILE_12
\$TTL    604800
@       IN      SOA     $PRIMARY_NS $ADMIN_EMAIL (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $PRIMARY_NS
1       IN      PTR     hq-cli.$ZONE_DOMAIN. 
14      IN      PTR     hq-rtr.$ZONE_DOMAIN. 
EOF

sleep 2

cat << EOF > $REVERSE_ZONE_FILE_21
\$TTL    604800
@       IN      SOA     $PRIMARY_NS $ADMIN_EMAIL (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $PRIMARY_NS

1       IN      PTR     br-srv.$ZONE_DOMAIN.
30      IN      PTR     br-rtr.$ZONE_DOMAIN.
EOF

sleep 2

chgrp bind $FORWARD_ZONE_FILE
chgrp bind $REVERSE_ZONE_FILE_11
chgrp bind $REVERSE_ZONE_FILE_12
chgrp bind $REVERSE_ZONE_FILE_21
chmod 640 $FORWARD_ZONE_FILE
chmod 640 $REVERSE_ZONE_FILE_11
chmod 640 $REVERSE_ZONE_FILE_12
chmod 640 $REVERSE_ZONE_FILE_21

systemctl restart bind9

sleep 2

systemctl status bind9

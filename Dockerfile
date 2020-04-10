FROM debian:buster-slim
MAINTAINER epava1516@github.com
COPY config.sh /tmp/config.sh
RUN apt update && \
    apt install -y bind9 && \
    chmod +x /tmp/config.sh
ENV NET_GATEWAY=192.168.1.1 \
    ZONE=example.com \
    DNS_IP=127.0.0.1
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/tmp/config.sh"]

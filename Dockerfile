FROM alpine:latest

ADD ./run.sh ./entrypoint.sh /

VOLUME /opt/rancher/bin

ENTRYPOINT ["/entrypoint.sh"]

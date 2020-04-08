FROM blacklabelops/volumerize

RUN apk add --no-cache \
    mysql-client pv

COPY postexecute /postexecute
COPY preexecute /preexecute
COPY scripts/ /etc/volumerize/
VOLUME ["/restore"]
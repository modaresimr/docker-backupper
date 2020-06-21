FROM blacklabelops/volumerize

RUN apk add --no-cache \
    mysql-client pv

RUN apk upgrade &&\
	apk add postgresql

COPY postexecute /postexecute
COPY preexecute /preexecute
COPY scripts/ /etc/volumerize/
VOLUME ["/restore"]
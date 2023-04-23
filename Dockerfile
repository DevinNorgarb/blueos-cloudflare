

FROM ubuntu:20.04

RUN apt-get update -qq && apt-get install openssl git make golang -y

RUN go version

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN git clone https://github.com/cloudflare/cloudflared.git

RUN #cd cloudflared && make cloudflared
WORKDIR /cloudflared

RUN go mod vendor

RUN make cloudflared-deb

RUN #mv /root/cloudflared/cloudflared /usr/bin/cloudflared
#FROM debian
#ARG TARGETARCH
#ENV TARGETARCH $TARGETARCH
#RUN apt-get update; apt-get install curl tar gzip ca-certificates -y; apt-get clean
#RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$TARGETARCH.deb
#RUN dpkg -i cloudflared.deb

WORKDIR /
COPY web /web

RUN cd web && pip install .

HEALTHCHECK --interval=1s CMD bash /healthcheck.sh


LABEL version="1.0"
LABEL permissions '\
{\
    "NetworkMode":"host"\
    ,"HostConfig":{\
        "Privileged": true,\
        "NetworkMode":"host",\
        "CapAdd":["SYS_ADMIN","NET_ADMIN"],\
        "Binds":[""],\
        "Devices":[\
            {\
                "PathOnHost":"/dev/net/tun",\
                "PathInContainer":"/dev/net/tun",\
                "CgroupPermissions":"rwm"\
            }\
        ]\
    }\
} '
LABEL authors '[\
    {\
        "name": "Devin Norgarb",\
        "email": "dnorgarb@gmail.com"\
    }\
]'
LABEL docs ''
LABEL company '{\
        "about": "",\
        "name": "Symbytech",\
        "email": "support@symbytech.com"\
    }'
LABEL readme 'https://raw.githubusercontent.com/Williangalvani/ZeroTierOne/{tag}/README.md'
LABEL website 'https://github.com/williangalvani/zerotierone'
LABEL support 'https://github.com/williangalvani/zerotierone'

LABEL requirements="core >= 1"


CMD []
ENTRYPOINT ["/entrypoint.sh"]

#ARG CLOUDFLARED_VERSION=2021.8.2
#
#FROM --platform=${BUILDPLATFORM:-linux/amd64} tonistiigi/xx:golang AS xgo
#FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.16-alpine3.14 AS builder
#
#COPY --from=xgo / /
#
#RUN apk --update --no-cache add \
#    bash \
#    build-base \
#    gcc \
#    git \
#  && rm -rf /tmp/* /var/cache/apk/*
#
#ARG CLOUDFLARED_VERSION
#RUN git clone --branch ${CLOUDFLARED_VERSION} https://github.com/cloudflare/cloudflared /go/src/github.com/cloudflare/cloudflared
#WORKDIR /go/src/github.com/cloudflare/cloudflared
#
#ARG TARGETPLATFORM
#ENV GO111MODULE=on
#ENV CGO_ENABLED=0
#RUN go build -v -mod vendor -ldflags "-w -s -X 'main.Version=${CLOUDFLARED_VERSION}' -X 'main.BuildTime=${BUILD_DATE}'" github.com/cloudflare/cloudflared/cmd/cloudflared
#
#FROM alpine:3.14
#
#ENV TZ="UTC" \
#  TUNNEL_METRICS="0.0.0.0:49312" \
#  TUNNEL_DNS_ADDRESS="0.0.0.0" \
#  TUNNEL_DNS_PORT="5053" \
#  TUNNEL_DNS_UPSTREAM="https://1.1.1.1/dns-query,https://1.0.0.1/dns-query"
#
#RUN apk --update --no-cache add \
#    bind-tools \
#    ca-certificates \
#    openssl \
#    shadow \
#    tzdata \
#  && addgroup -g 1000 cloudflared \
#  && adduser -u 1000 -G cloudflared -s /sbin/nologin -D cloudflared \
#  && rm -rf /tmp/* /var/cache/apk/*
#
#COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/cloudflared
#RUN cloudflared --no-autoupdate --version
#
#USER cloudflared
#
#EXPOSE 5053/udp
#EXPOSE 49312/tcp
#
#ENTRYPOINT [ "/usr/local/bin/cloudflared", "--no-autoupdate" ]
#CMD [ "proxy-dns" ]
#
#HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
##  CMD dig +short @127.0.0.1 -p $TUNNEL_DNS_PORT cloudflare.com A || exit 1

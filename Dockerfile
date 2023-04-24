FROM alpine:3.15 AS builder

ARG VERSION="2023.4.1"

ARG TARGETARCH

ARG URL="https://github.com/cloudflare/cloudflared/releases/download/${VERSION}/cloudflared-linux-${TARGETARCH}"

RUN apk update \
  && apk add curl \
  && curl -L ${URL} -o cloudflared

FROM alpine:3.15

WORKDIR /usr/local/bin

COPY --from=builder cloudflared .
RUN chmod +x cloudflared

ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]

#
#
#FROM ubuntu:20.04
#ENV TZ=Europe/Paris
#ARG DEBIAN_FRONTEND=noninteractive
#ENV DEBIAN_FRONTEND=noninteractive
#
#
#FROM ubuntu:latest
#
### install dependecies
##RUN apt update && apt upgrade -y
##RUN apt install -y git make golang
##
### clone the cloudflared repo
##RUN git clone https://github.com/cloudflare/cloudflared.git
##
### build cloudflared
##WORKDIR /cloudflared
##RUN make cloudflared
##RUN go install github.com/cloudflare/cloudflared/cmd/cloudflared
##
### command / entrypoint of container
##ENTRYPOINT ["./cloudflared", "--no-autoupdate"]
##CMD ["version"]
#
#RUN apt-get update -qq && apt-get install openssl git make wget -y
#ENV PATH="/usr/local/go/bin:${PATH}"
#
## Specify the platforms that this Dockerfile will support
## Here we support amd64, armv7 and arm64 architectures
## You can add or remove architectures as needed
#ARG TARGETPLATFORM
#RUN echo "Building for $TARGETPLATFORM"
## if statement for different architecture
#RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
#    wget https://go.dev/dl/go1.20.3.linux-amd64.tar.gz -o go1.20.3.linux-amd64.tar.gz && \
#         cat ./go1.20.3.linux-amd64.tar.gz && \
#         go version \
##    ; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
##     wget https://go.dev/dl/go1.20.3.linux-arm64.tar.gz -o go1.20.3.linux-arm64.tar.gz && \
##        tar -C /usr/local -xzf ./go1.20.3.linux-arm64.tar.gz && \
##         go version \
##       # packages for armv7 architecture
##    ; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
##     wget https://go.dev/dl/go1.20.3.linux-arm64.tar.gz -o go1.20.3.linux-arm64.tar.gz && \
##         tar -C /usr/local -xzf ./go1.20.3.linux-arm64.tar.gz && \
##         go version \
#    ; else \
#       echo "Unsupported platform: $TARGETPLATFORM" \
#       exit 1 \
#    ; fi
#
#
#RUN go version
#
#COPY entrypoint.sh /entrypoint.sh
#RUN chmod 755 /entrypoint.sh
#
#RUN git clone https://github.com/cloudflare/cloudflared.git
##
#RUN cd cloudflared  && make cloudflared
##WORKDIR /cloudflared
###
###RUN #go mod vendor
###
###RUN make cloudflared-deb
#
#RUN #mv /root/cloudflared/cloudflared /usr/bin/cloudflared
##FROM debian
##ARG TARGETARCH
##ENV TARGETARCH $TARGETARCH
##RUN apt-get update; apt-get install curl tar gzip ca-certificates -y; apt-get clean
##RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$TARGETARCH.deb
##RUN dpkg -i cloudflared.deb
#
#WORKDIR /
#COPY web /web
#
#RUN cd web && pip install .
#
#HEALTHCHECK --interval=1s CMD bash /healthcheck.sh
#
#
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
#
##ARG CLOUDFLARED_VERSION=2021.8.2
##
##FROM --platform=${BUILDPLATFORM:-linux/amd64} tonistiigi/xx:golang AS xgo
##FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.16-alpine3.14 AS builder
##
##COPY --from=xgo / /
##
##RUN apk --update --no-cache add \
##    bash \
##    build-base \
##    gcc \
##    git \
##  && rm -rf /tmp/* /var/cache/apk/*
##
##ARG CLOUDFLARED_VERSION
##RUN git clone --branch ${CLOUDFLARED_VERSION} https://github.com/cloudflare/cloudflared /go/src/github.com/cloudflare/cloudflared
##WORKDIR /go/src/github.com/cloudflare/cloudflared
##
##ARG TARGETPLATFORM
##ENV GO111MODULE=on
##ENV CGO_ENABLED=0
##RUN go build -v -mod vendor -ldflags "-w -s -X 'main.Version=${CLOUDFLARED_VERSION}' -X 'main.BuildTime=${BUILD_DATE}'" github.com/cloudflare/cloudflared/cmd/cloudflared
##
##FROM alpine:3.14
##
##ENV TZ="UTC" \
##  TUNNEL_METRICS="0.0.0.0:49312" \
##  TUNNEL_DNS_ADDRESS="0.0.0.0" \
##  TUNNEL_DNS_PORT="5053" \
##  TUNNEL_DNS_UPSTREAM="https://1.1.1.1/dns-query,https://1.0.0.1/dns-query"
##
##RUN apk --update --no-cache add \
##    bind-tools \
##    ca-certificates \
##    openssl \
##    shadow \
##    tzdata \
##  && addgroup -g 1000 cloudflared \
##  && adduser -u 1000 -G cloudflared -s /sbin/nologin -D cloudflared \
##  && rm -rf /tmp/* /var/cache/apk/*
##
##COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/cloudflared
##RUN cloudflared --no-autoupdate --version
##
##USER cloudflared
##
##EXPOSE 5053/udp
##EXPOSE 49312/tcp
##
##ENTRYPOINT [ "/usr/local/bin/cloudflared", "--no-autoupdate" ]
##CMD [ "proxy-dns" ]
##
##HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
###  CMD dig +short @127.0.0.1 -p $TUNNEL_DNS_PORT cloudflare.com A || exit 1

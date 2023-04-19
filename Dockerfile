


# Build container
ARG GOVERSION=1.19.8
ARG ALPINEVERSION=3.17

FROM --platform=${BUILDPLATFORM} \
    golang:$GOVERSION-alpine${ALPINEVERSION} AS build

WORKDIR /src
RUN apk --no-cache add git build-base

ENV GO111MODULE=on \
    CGO_ENABLED=0

ARG VERSION=2023.4.0
RUN git clone https://github.com/cloudflare/cloudflared --depth=1 --branch ${VERSION} .
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make cloudflared

# Runtime container

#

FROM bluerobotics/companion-base:v0.0.5

RUN apt-get update -qq && apt-get install openssl libssl1.1 -y

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

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




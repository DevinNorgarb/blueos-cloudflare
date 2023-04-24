FROM alpine:3.15 AS builder

ARG VERSION="2023.4.1"

ARG TARGETARCH

ARG URL="https://github.com/cloudflare/cloudflared/releases/download/${VERSION}/cloudflared-linux-${TARGETARCH}"

RUN apk update \
  && apk add curl py-pip \
  && curl -L ${URL} -o cloudflared

FROM debian
COPY --from=builder cloudflared /usr/local/bin/cloudflared
RUN chmod +x /usr/local/bin/cloudflared
COPY web /web
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
RUN apt-get update; apt-get install curl tar gzip ca-certificates python3-pip python3 -y;
WORKDIR /
RUN cd web && pip install .

HEALTHCHECK --interval=1s CMD bash /healthcheck.sh
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


#CMD [""]
ENTRYPOINT ["/entrypoint.sh"]

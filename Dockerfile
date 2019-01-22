#
# Builder
#
FROM abiosoft/caddy:builder as builder

ARG version="0.11.2"
ARG plugins="dnspod,realip,ratelimit,ipfilter"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} /bin/sh /usr/bin/builder.sh

#
# Final stage
#
FROM alpine:3.8
LABEL thanks maintainer "Abiola Ibrahim <abiola89@gmail.com>"
LABEL maintainer "Muyuballs  <muyuballs@breezes.info>"

ARG version="0.11.2"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="true"
# DNSPOD KEY
ENV DNSPOD_API_KEY=""
# Let's Encrypt Email
ENV EMAIL=""

RUN apk add --no-cache openssh-client git

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /root/.caddy /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]

ARG EXIST_BASE=dev6-nonroot-j8

FROM debian:12-slim as builder

ARG CRYPTO_VERSION=6.0.1
ARG JWT_VERSION=2.0.0
ARG PUBLISHER_LIB_VERSION=4.0.1
ARG ROUTER_VERSION=1.8.1
ARG TEMPLATING_VERSION=1.2.1


WORKDIR /tmp/

RUN curl -L -o 001.xar https://exist-db.org/exist/apps/public-repo/public/expath-crypto-module-${CRYPTO_VERSION}.xar
RUN curl -L -o 002.xar http://exist-db.org/exist/apps/public-repo/public/jwt-${JWT_VERSION}.xar
RUN curl -L -o 003.xar http://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar
RUN curl -L -o 004.xar http://exist-db.org/exist/apps/public-repo/public/roaster-${ROUTER_VERSION}.xar
RUN curl -L -o 005.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar

FROM duncdrum/existdb:${EXIST_BASE} as conf

FROM eplusorg/xml:main as mod

COPY conf-transform.xsl /tmp
COPY --from=conf /exist/etc/conf.xml /tmp
COPY --from=conf /exist/etc/log4j2.xml /tmp

RUN java -jar /opt/saxon/run.sh -s:/tmp/conf.xml -xsl:/tmp/conf-transform.xsl -o:/tmp/conf_prod.xml



FROM duncdrum/existdb:${EXIST_BASE}

ARG USR=nonroot
ARG NER_ENDPOINT=http://localhost:8001
ENV CONTEXT_PATH=auto
ENV PROXY_CACHING=false

USER ${USR}

# Copy eXist-db
COPY --from=builder --chown=${USR} /tmp/*.xar /exist/autodeploy
COPY --from=mod --chown=${USR} /tmp/log4j2.xml /exist/etc
COPY --from=mod --chown=${USR} /tmp/conf_prod.xml /exist/etc/conf.xml

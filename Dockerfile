ARG EXIST_BASE=6.4.0-nonroot-j8

FROM debian:12-slim AS builder

ARG PUBLISHER_LIB_VERSION=4.0.2
ARG ROUTER_VERSION=1.8.1
ARG TEMPLATING_VERSION=1.2.1


WORKDIR /tmp/

RUN curl -L -o 001.xar http://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar
RUN curl -L -o 002.xar http://exist-db.org/exist/apps/public-repo/public/roaster-${ROUTER_VERSION}.xar
RUN curl -L -o 003.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar

FROM duncdrum/existdb:${EXIST_BASE} AS conf

FROM eplusorg/xml:main AS mod

COPY conf-transform.xsl /tmp
COPY --from=conf /exist/etc/conf.xml /tmp
COPY --from=conf /exist/etc/log4j2.xml /tmp

RUN java -jar /opt/saxon/run.sh -s:/tmp/conf.xml -xsl:/tmp/conf-transform.xsl -o:/tmp/conf_prod.xml



FROM duncdrum/existdb:${EXIST_BASE}

ARG USR=nonroot

USER ${USR}

# Copy eXist-db
COPY --from=builder --chown=${USR} /tmp/*.xar /exist/autodeploy
COPY --from=mod --chown=${USR} /tmp/log4j2.xml /exist/etc
COPY --from=mod --chown=${USR} /tmp/conf_prod.xml /exist/etc/conf.xml

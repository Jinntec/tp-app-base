ARG EXIST_BASE=6.4.0-nonroot-j8

FROM duncdrum/existdb:${EXIST_BASE} AS conf

FROM debian:12-slim AS builder

ARG PUBLISHER_LIB_VERSION=4.0.2
ARG ROUTER_VERSION=1.9.1
ARG TEMPLATING_VERSION=1.2.1

RUN apt-get update && apt-get -y install apt-utils && apt-get -y dist-upgrade && apt-get install -y --no-install-recommends \
    xsltproc \
    curl

WORKDIR /tmp

RUN curl -L -o 001.xar http://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar
RUN curl -L -o 002.xar http://exist-db.org/exist/apps/public-repo/public/roaster-${ROUTER_VERSION}.xar
RUN curl -L -o 003.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar

COPY --from=conf /exist/etc/conf.xml conf.xml 
COPY --from=conf /exist/etc/webapp/WEB-INF/web.xml web.xml  

# Copy XSLT files
COPY xslt/conf-transform.xsl conf-transform.xsl
COPY xslt/web-transform.xsl web-transform.xsl

# Apply security transformations
RUN xsltproc conf-transform.xsl conf.xml > conf_prod.xml
RUN xsltproc web-transform.xsl web.xml > web_prod.xml

FROM duncdrum/existdb:${EXIST_BASE}

ARG USR=nonroot

USER ${USR}

# Copy eXist-db
COPY --from=builder --chown=${USR} /tmp/*.xar /exist/autodeploy
COPY --from=builder --chown=${USR} /tmp/conf_prod.xml /exist/etc/conf.xml
COPY --from=builder --chown=${USR} /tmp/web_prod.xml /exist/etc/webapp/WEB-INF/web.xml

ARG EXIST_BASE=6.4.0

FROM duncdrum/existdb:${EXIST_BASE} AS conf

# RUN ["busybox", "rm", "-rf", "/exist/autodeploy/"]

FROM debian:12-slim AS builder


RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get -y install apt-utils && apt-get -y dist-upgrade && apt-get install -y --no-install-recommends \
    xsltproc

WORKDIR /tmp

COPY --from=conf /exist/etc/conf.xml conf.xml 
COPY --from=conf /exist/etc/webapp/WEB-INF/web.xml web.xml  

# Copy XSLT files
COPY xslt/conf-transform.xsl conf-transform.xsl
COPY xslt/web-transform.xsl web-transform.xsl

# Apply security transformations
RUN xsltproc conf-transform.xsl conf.xml > conf_prod.xml
RUN xsltproc web-transform.xsl web.xml > web_prod.xml

FROM duncdrum/existdb:${EXIST_BASE}-nonroot-slim

ARG PUBLISHER_LIB_VERSION=4.0.2
ARG ROUTER_VERSION=1.9.1
ARG TEMPLATING_VERSION=1.2.1

ARG USR=nonroot

USER ${USR}

# Copy EXPATH dependencies
ADD --chown=${USR} http://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar /exist/autodeploy/001.xar
ADD --chown=${USR} http://exist-db.org/exist/apps/public-repo/public/roaster-${ROUTER_VERSION}.xar /exist/autodeploy/002.xar
ADD --chown=${USR} http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar /exist/autodeploy/003.xar

# Copy configuration files
COPY --from=builder --chown=${USR} /tmp/conf_prod.xml /exist/etc/conf.xml
COPY --from=builder --chown=${USR} /tmp/web_prod.xml /exist/etc/webapp/WEB-INF/web.xml
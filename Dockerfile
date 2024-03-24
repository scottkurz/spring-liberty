# Stage and thin the application 
FROM icr.io/appcafe/open-liberty:full-java21-openj9-ubi-minimal as staging

ARG APPNAME=spring-liberty-0.0.1-SNAPSHOT.war
COPY --chown=1001:0 target/$APPNAME \
  /staging/$APPNAME

RUN springBootUtility thin \
 --sourceAppPath=/staging/$APPNAME \
 --targetThinAppPath=/staging/thin-$APPNAME \
 --targetLibCachePath=/staging/lib.index.cache

FROM icr.io/appcafe/open-liberty:kernel-slim-java21-openj9-ubi-minimal

ARG APPNAME=spring-liberty-0.0.1-SNAPSHOT.war
ARG VERSION=1.0
ARG REVISION=SNAPSHOT
COPY --chown=1001:0 src/main/liberty/config/server.xml /config/server.xml

RUN features.sh

COPY --chown=1001:0 --from=staging /staging/lib.index.cache /lib.index.cache
COPY --chown=1001:0 --from=staging /staging/thin-$APPNAME \
                    /config/apps/thin-$APPNAME

RUN configure.sh 


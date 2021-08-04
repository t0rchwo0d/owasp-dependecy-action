FROM azul/zulu-openjdk-alpine:11 AS jlink

RUN $JAVA_HOME/bin/jlink --compress=2 --module-path /opt/java/openjdk/jmods --add-modules java.base,java.compiler,java.datatransfer,jdk.crypto.ec,java.desktop,java.instrument,java.logging,java.management,java.naming,java.rmi,java.scripting,java.security.sasl,java.sql,java.transaction.xa,java.xml,jdk.unsupported --output /jlinked

FROM mcr.microsoft.com/dotnet/core/runtime:2.2-alpine3.9

ENV JAVA_HOME=/opt/jdk
ENV JAVA_OPTS=-Danalyzer.assembly.dotnet.path=/usr/bin/dotnet -Danalyzer.bundle.audit.path=/usr/bin/bundle-audit

COPY --from=jlink /jlinked /opt/jdk/

RUN wget -O /tmp/current.txt https://jeremylong.github.io/DependencyCheck/current.txt && version=$(cat /tmp/current.txt) && wget https://github.com/jeremylong/DependencyCheck/releases/download/v$version/dependency-check-$version-release.zip && unzip dependency-check-$version-release.zip && mv dependency-check /

VOLUME "/src"
VOLUME "/reports"

RUN pwd
ENTRYPOINT ["/dependency-check/bin/dependency-check.sh"]

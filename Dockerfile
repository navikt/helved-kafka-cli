FROM eclipse-temurin:21-jre-ubi10-minimal

RUN microdnf update -y && microdnf install -y jq vim-enhanced && microdnf clean all

ENV KAFKA_URL=https://dlcdn.apache.org/kafka/4.1.2/kafka_2.13-4.1.2.tgz
ENV KAFKA_DOWNLOAD=/download/kafka.tgz
ENV KAFKA_WORKDIR=/cli/kafka
ENV PATH=${KAFKA_WORKDIR}/bin:${PATH}:/scripts
ENV AIVEN_CONF=/cli/kafka/config/aiven.conf
# Kafka 4.1.2 bundles versions of these libs that scanners flag.
# Keep overrides centralized and remove this block once upstream fixes them.
ENV KAFKA_JACKSON_CORE_VERSION=2.21.1
ENV KAFKA_JETTY_VERSION=12.0.32

RUN curl ${KAFKA_URL} --create-dirs -o ${KAFKA_DOWNLOAD}
RUN mkdir -p ${KAFKA_WORKDIR}
RUN tar -xvzpf ${KAFKA_DOWNLOAD} --strip-components=1 -C ${KAFKA_WORKDIR} && rm ${KAFKA_DOWNLOAD}
# Replace vulnerable Kafka-bundled jars in-place.
# Old jars are removed first to avoid duplicate versions on the classpath.
RUN set -eux; \
    cd ${KAFKA_WORKDIR}/libs; \
    rm -f jackson-core-*.jar; \
    curl -fsSL "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/${KAFKA_JACKSON_CORE_VERSION}/jackson-core-${KAFKA_JACKSON_CORE_VERSION}.jar" -o "jackson-core-${KAFKA_JACKSON_CORE_VERSION}.jar"; \
    for artifact in jetty-alpn-client jetty-client jetty-http jetty-io jetty-security jetty-server jetty-session jetty-util; do \
      rm -f "${artifact}-"*.jar; \
      curl -fsSL "https://repo1.maven.org/maven2/org/eclipse/jetty/${artifact}/${KAFKA_JETTY_VERSION}/${artifact}-${KAFKA_JETTY_VERSION}.jar" -o "${artifact}-${KAFKA_JETTY_VERSION}.jar"; \
    done; \
    for artifact in jetty-ee10-servlet jetty-ee10-servlets; do \
      rm -f "${artifact}-"*.jar; \
      curl -fsSL "https://repo1.maven.org/maven2/org/eclipse/jetty/ee10/${artifact}/${KAFKA_JETTY_VERSION}/${artifact}-${KAFKA_JETTY_VERSION}.jar" -o "${artifact}-${KAFKA_JETTY_VERSION}.jar"; \
    done

WORKDIR ${KAFKA_WORKDIR}

COPY entrypoint.sh /cli/
COPY scripts /scripts

RUN chmod +x /scripts/* /cli/entrypoint.sh
RUN touch ${AIVEN_CONF}
RUN chmod 777 ${AIVEN_CONF}

CMD ["/cli/entrypoint.sh"]

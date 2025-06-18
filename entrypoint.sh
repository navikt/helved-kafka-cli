#!/bin/bash
set -euo pipefail

if [[ -z "$KAFKA_BROKERS" ]]; then
    echo "missing required variable KAFKA_BROKERS"
    exit 1
fi

if [[ -z "$KAFKA_CREDSTORE_PASSWORD" ]]; then
    echo "missing required variable KAFKA_CREDSTORE_PASSWORD"
    exit 1
fi

cat <<EOF > "$AIVEN_CONF"
security.protocol=SSL
ssl.keystore.type=PKCS12
ssl.keystore.location=/var/run/secrets/other-app/kafka/client.keystore.p12
ssl.keystore.password=$KAFKA_CREDSTORE_PASSWORD
ssl.truststore.location=/var/run/secrets/other-app/kafka/client.truststore.jks
ssl.truststore.password=$KAFKA_CREDSTORE_PASSWORD
bootstrap.servers=$KAFKA_BROKERS
EOF

tail -f /dev/null

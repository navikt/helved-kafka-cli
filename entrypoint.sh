#!/bin/bash

if [[ -z "$KAFKA_BROKERS" ]]; then
    echo "missing required variable KAFKA_BROKERS"
fi

if [[ -z "$KAFKA_CREDSTORE_PASSWORD" ]]; then
    echo "missing required variable KAFKA_CREDSTORE_PASSWORD"
fi

echo "
security.protocol=SSL
ssl.keystore.type=PKCS12
ssl.keystore.location=/var/run/secrets/other-app/kafka/client.keystore.p12
ssl.keystore.password=$KAFKA_CREDSTORE_PASSWORD
ssl.truststore.location=/var/run/secrets/other-app/kafka/client.truststore.jks
ssl.truststore.password=$KAFKA_CREDSTORE_PASSWORD
" >> "$AIVEN_CONF"

cat "$AIVEN_CONF"

tail -f /dev/null

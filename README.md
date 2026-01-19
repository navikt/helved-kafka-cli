### Config

### Reset streams application
Reset topologi (kafka strømmen), application-id er laget av nais og finnes som env-var i poden
```shell
kubectl exec -i deploy/kafka-cli -- kafka-streams-application-reset \
 --application-id helved.abetal_stream_ \
 --input-topics helved.saker.v1
```

### Show consumers in a group
```shell
kubectl exec -i deploy/kafka-cli -- kafka-consumer-groups \
 --group helved.abetal_stream_ \
 --describe
```

### List consumer groups
```shell
kubectl exec -i deploy/kafka-cli -- kafka-consumer-groups --list
```

### SHOW EARLIEST OFFSET
```shell
k exec -i deploy/kafka-cli -- kafka-get-offsets \
--topic helved.utbetalinger.v1 --time -2
```

### SHOW LATEST OFFSET
```shell
k exec -i deploy/kafka-cli -- kafka-get-offsets \
--topic ktable-helved.utbetalinger.v1-repartition --time -1
```

### consume topic
```shell
k exec -i deploy/kafka-cli -- kafka-console-consumer \
--topic helved.abetal_stream_-ktable-helved.utbetalinger.v1-repartition \
--from-beginning \
--property print.key=true \
--property print.partition=true \
--property key.separator=" | " \
--max-messages 500
```
### Interactive shell commands
Use scripts from /scripts to include brokers and aiven config, e.g:

### List topics
```shell
kubectl exec -i deploy/kafka-cli -- kafka-consumer-groups --list | grep "helved"
```

```shell
kubectl exec -i deploy/kafka-cli -- kafka-topics --describe --topic helved.utbetalinger.v1 
```

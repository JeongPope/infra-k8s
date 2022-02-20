# Elastic cloud on Kubernetes
ECK Operator, CRD를 활용해 Elasticsearch, Kibana를 인프라에 구성한다.

* [Official : Elasticsearch on ECK](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-elasticsearch-specification.html)
* [Official : Kibana on ECK](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-kibana.html)


### How to use
```bash
$ k apply -f . // elasticsearch, kibana 동시에 설치
```

### Elasticsearch
Elasticsearch는 기본적으로 모든 데이터를 indexing하여 저장하고, 검색, 분석 등의 역할을 한다

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: eck-elasticsearch
spec:
  version: 8.0.0    # 버전 지정
  nodeSets:
    - name: nodes   # <.metadata.name>-es- 이후에 붙는 suffix
      count: 3      # elasticsearch node replicas
      config:
        node.roles:
          - master
          - data
      podTemplate:
        spec:
          initContainers:
            # elasticsearch는 OS를 통해 index file을 virtual memory에 mapping하고 filesystem cache를 생성한다.
            # 단, linux는 한번에 너무 많은 파일을 열거나 많은 메모리를 매핑하는것을 방지하는 제한이 있는데,
            # vm.max_map_count로 관리하므로, elasticsearch에서 최소값으로 제안하는 '262,144'로 지정한다
            - name: increase-vm-max-map
              image: busybox
              command: ["sysctl", "-w", "vm.max_map_count=262144"]
              securityContext:
                privileged: true
          containers:
            - name: elasticsearch
              resources:
                requests:
                  memory: 1Gi
                  cpu: 500m
                limits:
                  memory: 3Gi
                  cpu: 1500m
      # AWS EBS를 Persistent volume으로 사용한다
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data
          spec:
            storageClassName: aws-gp2-retain
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 50Gi
  # TLS 를 disabled 한다.
  http:
    tls:
      selfSignedCertificate:
        disabled: true
```
<br>

### Kibana
Elasticsearch에서 문서, 집계 결과 등을 불러와 시각화하는 도구

```yaml
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: eck-kibana
spec:
  version: 8.0.0
  count: 1
  elasticsearchRef:
    name: eck-elasticsearch # elasticsearch의 .metadata.name을 ref로 준다
  podTemplate:
    spec:
      containers:
        - name: kibana
          resources:
            requests:
              memory: 1Gi
              cpu: 0.5
            limits:
              memory: 2Gi
              cpu: 2
  # TLS 를 disabled 한다.
  http:
    tls:
      selfSignedCertificate:
        disabled: true
```

### Initial credential
최초 ID는 `elastic`이고, PW는 다음 명령어를 통해 확인할 수 있다.

```bash
$ kubectl get secret {{<elasticsearch의 .metadata.name>-es-elastic-user}} \
    -n {{ namespace }} \
    -o go-template='{{.data.elastic | base64decode}}'
```
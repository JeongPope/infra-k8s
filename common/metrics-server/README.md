# kube metric server
클러스터 메트릭 수집 도구

```bash
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

환경에 따라 다음 YAML을 사용한다.
* OnPremise : metricserver-kubelet-insecure.yaml
* AWS : metricserver.yaml

### Need to check
* `metric-server` 의 args flag에 `--kubelet-insecure-tls=true` 옵션 유무

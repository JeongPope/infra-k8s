# Helm chart (feat. Operator)

### ArgoCD (Continuous Delivery)
```bash
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm fetch argo/argo-cd
$ tar zxvf argo-cd-{{ version }}.tgz
```

HA mode with scaling을 할 것이므로 `values.yaml`를 다음과같이 변경한다.
```yaml
redis-ha:
  enabled: true

controller:
  enableStatefulSet: true

server:
  autoscaling:
    enabled: true
    minReplicas: 2

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2
```
```bash
$ helm install argocd . -n argocd --create-namespace
```

* Install CLI (MacOS)
```bash
$ brew install argocd
```

* ArgoCD 초기 계정인 `admin`의 password 가져오기
```bash
$ kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

<br>

### VPA(Vertical Pod Autoscaler)
```bash
$ helm repo add fairwinds-stable https://charts.fairwinds.com/stable
$ helm fetch fairwinds-stable/vpa
$ tar zxvf vpa-{{ version }}.tgz
```

updater 기능을 사용하지 않을 것이므로, `enable: false` 로 수정
```yaml
...
updater:
  enabled: false
...
```

```bash
$ helm install vpa . -n vpa --create-namespace
```

<br>

### Goldilocks (Dashboard for viewing resource recommendations)
Goldilocks는 리소스 설정하는 방법에 대한 recommend를 제공하는 대시보드를 제공하는 Kubernetes 컨트롤러
```bash
$ helm repo add fairwinds-stable https://charts.fairwinds.com/stable
$ helm fetch fairwinds-stable/goldilocks
$ tar zxvf goldilocks-{{ version }}.tgz
$ helm install goldilocks . -n vpa
```

VPA Recommender를 적용할 namespace에 label를 추가한다.
```bash
$ kubectl label ns {{ namespace }} goldilocks.fairwinds.com/enabled=true
```
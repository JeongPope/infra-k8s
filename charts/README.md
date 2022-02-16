# Helm chart (feat. Operator)

#### VPA(Vertical Pod Autoscaler)
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

#### Goldilocks (Dashboard for viewing resource recommendations)
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

namespace가 sidecar auto-injection이 되었다면 virtualservice,  
그렇지 않다면 port-forwarding으로 `svc/goldilocks-dashboard`를 확인할 수 있다.
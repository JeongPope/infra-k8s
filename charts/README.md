# Helm chart (feat. Operator)
Boilerplate에서 활용하는 모든 Helm chart

#### How to use
```bash
$ helm install {{ Release name }} {{ chart path }} -n {{namespace}}
```
<br>

### ECK (Elastic Cloud on Kubernetes)
Operator ECK를 활용하여 elasticsearch, kibana 를 관리한다.  

* [Official](https://www.elastic.co/guide/en/cloud-on-k8s/master/index.html)
* [Operatorhub](https://operatorhub.io/operator/elastic-cloud-eck)
* [Example CRD of Elasticsearch, Kibana](https://github.com/JeongPope/infra-k8s/tree/master/kubernetes/common/devops/eck)

##### Manual
```bash
$ helm repo add elastic https://helm.elastic.co
$ helm repo update

// Install 
$ helm install elastic-operator . -n {{ namespace }}

// watch log
$ kubectl logs -n {{ namespace }} sts/elastic-operator

// Uninstall
kubectl delete -n elastic-system \
    serviceaccount/elastic-operator \
    secret/elastic-webhook-server-cert \
    clusterrole.rbac.authorization.k8s.io/elastic-operator \
    clusterrole.rbac.authorization.k8s.io/elastic-operator-view \
    clusterrole.rbac.authorization.k8s.io/elastic-operator-edit \
    clusterrolebinding.rbac.authorization.k8s.io/elastic-operator \
    service/elastic-webhook-server \
    configmap/elastic-operator \ 
    statefulset.apps/elastic-operator \
    validatingwebhookconfiguration.admissionregistration.k8s.io/elastic-webhook.k8s.elastic.co
```
<br>

### ArgoCD (Continuous Delivery)
* [Official](https://argo-cd.readthedocs.io/en/stable/)

##### Manual
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

// Install CLI (MacOS)
$ brew install argocd

// Get Initial admin password
$ kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```
<br>

### VPA(Vertical Pod Autoscaler)
* [Github](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)

##### Manual
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
// Install
$ helm install vpa . -n {{ namespace }}
```
<br>

### Goldilocks (Dashboard for viewing resource recommendations)
리소스 설정(Request, Limit)에 대한 recommend를 제공하는 대시보드를 제공하는 오픈소스

* [Official](https://goldilocks.docs.fairwinds.com/#how-can-this-help-with-my-resource-settings)
* [Github](https://github.com/FairwindsOps/goldilocks)

##### Manual
```bash
$ helm repo add fairwinds-stable https://charts.fairwinds.com/stable
$ helm fetch fairwinds-stable/goldilocks
$ tar zxvf goldilocks-{{ version }}.tgz
$ helm install goldilocks . -n vpa

// VPA Recommender를 적용할 namespace에 label를 추가한다.
$ kubectl label ns {{ namespace }} goldilocks.fairwinds.com/enabled=true
```
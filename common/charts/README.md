# Helm chart
Boilerplate에서 활용하는 모든 Helm chart

#### How to use
```bash
$ helm install {{ release_name }} {{ package path }} -n {{ namespace }} -f {{ custom your chart value }}
```
<br>

### ECK (Elastic Cloud on Kubernetes)
Operator ECK를 활용하여 elasticsearch, kibana 를 관리한다.  

* [Official](https://www.elastic.co/guide/en/cloud-on-k8s/master/index.html)
* [Operatorhub](https://operatorhub.io/operator/elastic-cloud-eck)
* [Example CRD of Elasticsearch, Kibana](https://github.com/JeongPope/infra-k8s/tree/master/kubernetes/common/devops/eck)

##### Uninstall
```
// Uninstall
$ kubectl delete -n {{ namespace }} \
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

### Fluentd (aggregator)
* [Official Docs](https://docs.fluentd.org)
* [Github : Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/fluentd/)

##### custom value : fluentd.yaml
* forwarder 사용하지 않으므로 `enabled: false`
* aggregator replicas 수정
* output으로 elasticsearch를 사용하기 위해, envVar 설정
```bash
$ k get secret {{ elasticsearch CRD .metadata.name }}-es-elastic-user -n monitoring \
    -o go-template='{{.data.elastic | base64decode}}'
```
* configmap 수정( Input -> Filter -> Output )

<br>

### Fluentbit (Log collector)
* [Docs](https://docs.fluentbit.io/manual/v/1.3/)
* [Github](https://github.com/fluent/helm-charts/tree/main/charts/fluent-bit)

##### custom value : fluentbit.yaml
* log aggregator를 fluentd로 사용하므로, fluentd svc를 env로 설정
* flush interval 설정
* config 설정


<br>

### ArgoCD (Continuous Delivery)
* [Official](https://argo-cd.readthedocs.io/en/stable/)

##### custom value
* HA mode with scaling을 위한 설정 변경
* AWS ALB 사용을 위해 service type을 NodePort로 변경

##### Get Argocd credentials
```bash
// Install CLI (MacOS)
$ brew install argocd

// Get Initial admin password
$ kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```
<br>

### VPA(Vertical Pod Autoscaler)
* [Github](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)

##### custom value
* updater 기능을 사용하지 않을 것이므로, `updater.enable: false` 로 수정
<br>

### Goldilocks (Dashboard for viewing resource recommendations)
리소스 설정(Request, Limit)에 대한 recommend를 제공하는 대시보드를 제공하는 오픈소스

* [Official](https://goldilocks.docs.fairwinds.com/#how-can-this-help-with-my-resource-settings)
* [Github](https://github.com/FairwindsOps/goldilocks)

##### custom value
* `replicas=1` 로 변경
* AWS ALB 사용을 위해 service type을 NodePort로 변경

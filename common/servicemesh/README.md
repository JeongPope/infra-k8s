# Servicemesh : Istio
* [Official Document](https://istio.io/latest/docs/setup/install/operator/#install-istio-with-the-operator)

### 1. Deploy the istio operator
```bash
$ istioctl operator init
```

### 2. Install istio with the operator
```bash
$ kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio-controlplane
  namespace: istio-system
spec:
  profile: default
EOF
```
* 위와 같이 생성하게 되면 LoadBalancer는 `CLB(Classic Load Balancer)`로 생성된다.
* CLB는 권장되지 않으므로 `NLB(Network Load Balancer)` 또는 `ALB(Application Load Balancer)`로 변경해야한다.
* 기본적으로 `AWS WAF`를 사용한다는 가정하에 `ALB`를 사용한다.
<br>

### 3. Service type, annotation
##### 1) AWS ALB가 Healthcheck를 위해 사용할 istio ingress gateway의 nodePort를 확인
```bash
$ kubectl get service istio-ingressgateway -n istio-system \
    -o jsonpath='{.spec.ports[?(@.name=="status-port")].nodePort}'
```

##### 2) 확인된 nodePort를 가지고 istio-ingressgateway 를 그에 맞게 수정한다.
```yaml
# default operator
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio-controlplane
  namespace: istio-system
spec:
  profile: default
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
        # Need to update field
        k8s:
          service:
            type: NodePort
          serviceAnnotations:
            alb.ingress.kubernetes.io/healthcheck-path: /healthz/ready
            alb.ingress.kubernetes.io/healthcheck-port: "{{ Nodeport }}"
```
<br>

### 4. Namespace lable을 통한 sidecar auto injection 설정
```bash
$ kubectl label namespace {{ your workspace }} istio-injection=enabled
```
<br>

이후 traffic management 방법에 따라 적용한다.
<br>

### Uninstall
```
$ istioctl manifest generate | kubectl delete -f -
$ kubectl delete ns istio-system --grace-period=0 --force
$ istioctl operator remove
```
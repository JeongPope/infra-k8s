# LoadBalancer

### AWS LoadBalancer Controller
1. IAM Policy
```bash
$ curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json
```
* 공식 문서에 따라 `IAM`을 생성하지 않고, `Terraform`에서 생성한 Role을 사용할 수도 있다.
* [Terraform : IAM Policy](https://github.com/JeongPope/infra-terraform/blob/master/workspace/3-iam/policy/worker-alb.json)
<br>

2. Cert Manager
```bash
$ kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml

// 또는
$ kubectl apply -f cert-manager.yaml
```
<br>

3. AWS ALB Controller
##### 1) Deployment spec에서 `--cluster-name` 을 수정해야합니다.
```yaml
apiVersion: apps/v1
kind: Deployment
. . .
name: aws-load-balancer-controller
namespace: kube-system
spec:
    . . .
    template:
        spec:
            containers:
                - args:
                    - --cluster-name=<INSERT_CLUSTER_NAME>
```
##### 2) 리소스 생성
```bash
$ kubectl apply -f aws-alb-controller.yaml
```
<br>

4. Create LoadBalancer
```bash
// 생성된 ALB 확인 방법
$ kubectl get ingress aws-alb-ingress -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].hostname}"
```

* 일정 시간이 지났음에도 ALB가 생성되지 않는다면, ALB Controller Pod의 로그를 확인한다.
* 로그 필드 중, `"level":"error"`가 발생한다면 다음을 확인한다.
* https://aws.amazon.com/ko/premiumsupport/knowledge-center/eks-load-balancer-controller-subnets/
<br>

### Reference
* [ALB Ingress Controller : Official](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/deploy/installation/)
* [ALB Ingress Controller : Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v1.1/guide/ingress/annotation/#subnets)
* [Cert Manager](https://cert-manager.io/docs/installation/)

---

### Nginx ingress controller (for AWS)
#### Reference
* [Official](https://kubernetes.github.io/ingress-nginx/)
* [무중단 업데이트](https://www.letmecompile.com/kubernetes-nlb-nginx-ingress-update/)

---

### MetalLB
* On-Premise k8s 환경에서 외부 L4 switch 없이 로드밸런싱 기능 제공
* MetalLB Pod가 Restart되면 서비스에는 영향 없으나, ARP를 할당하는 노드가 down되면 10초 내외 down 발생할 수 있다.

1. Install
```bash
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
```

2. IP Pool (layer2)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.100.11.10-10.100.11.210 # IP Range
```

#### Reference
* https://metallb.universe.tf/installation/
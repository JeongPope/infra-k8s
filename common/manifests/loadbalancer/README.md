# AWS ALB Ingress Controller
### 1. IAM Policy
```bash
$ curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json
```
* 공식 문서에 따라 `IAM`을 생성하지 않고, `Terraform`에서 생성한 Role을 사용할 수도 있다.
* [Terraform : IAM Policy](https://github.com/JeongPope/infra-terraform/blob/master/workspace/3-iam/policy/worker-alb.json)
<br>

### 2. Cert Manager
```bash
$ kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml

// 또는
$ kubectl apply -f cert-manager.yaml
```
<br>

### 3. AWS ALB Controller
#### 1) Deployment spec에서 `--cluster-name` 을 수정해야합니다.
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
#### 2) 리소스 생성
```bash
$ kubectl apply -f aws-alb-controller.yaml
```
<br>

### 4. Create LoadBalancer
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
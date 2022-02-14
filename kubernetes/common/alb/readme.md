# AWS ALB Ingress Controller
### 1. IAM Policy
```bash
$ curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json
```
* 공식 문서에 따라 `IAM`을 생성하지 않고, `Terraform`에서 생성
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
$ kubectl apply -f ingress.yaml

// 생성된 ALB 확인 방법
$ kubectl get ingress aws-alb-ingress -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].hostname}"
```

### Reference
* [ALB Ingress Controller : Official](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/deploy/installation/)
* [ALB Ingress Controller : Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v1.1/guide/ingress/annotation/#subnets)
* [Cert Manager](https://cert-manager.io/docs/installation/)
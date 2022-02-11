# AWS ALB Ingress Controller

### Install
* [ALB Ingress Controller : Official](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/deploy/installation/)
* [Cert Manager](https://cert-manager.io/docs/installation/)

### IAM Policy
```bash
$ curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json
```
* 공식 문서에 따라 IAM Role이 생성하지 않고, Terraform에서 생성했습니다.

### Cert Manager
```bash
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml
```


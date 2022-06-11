## External DNS
* [Official](https://github.com/kubernetes-sigs/external-dns)
* [Official : Setting up on aws](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md)

1. Create IAM Policy
```bash
$ aws iam create-policy --policy-name {{ policy name }} \
    --policy-document file://dns-policy.json
```

2. Create IRSA using `eksctl`
```bash
$ eksctl create iamserviceaccount \
    --name external-dns \
    --namespace {{ namespace }} \
    --cluster {{ cluster name }} \
    --attach-policy-arn {{ IAM Policy ARN }} \
    --approve \
    --override-existing-serviceaccounts
```
* `rbac-deploy.yaml`에서 다음을 수정한다.
- namespace
- annotations
- deployment containers arg : domain-filter, txt-owner-id

3. kubectl apply
- namespace.yaml
- rbac-deploy.yaml

#### How to use
`.metadata.annotations` 에 다음과 같이 추가한다.

```yaml
metadata:
    name: component
    annotations:
        external-dns.alpha.kubernetes.io/hostname: foo.bar.com
```
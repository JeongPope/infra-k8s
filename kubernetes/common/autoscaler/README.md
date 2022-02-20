# Autoscaler

#### Metric Server
클러스터 메트릭 수집 도구
```bash
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
<br>

#### Autoscaler
Cluster node의 리소스 부족으로 파드의 Scheduling이 pending되면, horizontal scaling을 한다.

1. nodegroup asg의 maxsize를 적절히 수정한다
* AWSCLI를 통한 확인 방법
```bash
$ aws autoscaling describe-auto-scaling-groups \
	--query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='changename']].[AutoScalingGroupName,MinSize,MaxSize,DesiredCapacity]" \
	--output table
```

2. IAM Policy 를 생성한다
- Autoscaling 정보를 조회하고, Desired 를 변경하는 권한이 필요
```bash
$ aws iam create-policy \
	--policy-name {{ policy name }} \
	--policy-document file://autoscaler-policy.json
```

3. EKS OIDC를 통해 IRSA 생성
- OIDC : OpenID Connect
- IRSA : IAM Role for Service Account
- [Create an IAM OIDC provider for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)

4. autoscaler yaml에서 cluster name으로 수정
```bash
$ curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

```yaml
command:
  - ./cluster-autoscaler
  - --v=4
  - --stderrthreshold=info
  - --cloud-provider=aws
  - --skip-nodes-with-local-storage=false
	- --expander=least-waste
	- --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/**k8s-project-dev**
```

```bash
$ kubectl apply -f cluster-autoscaler-autodiscover.yaml
```

5. Annotation 을 통해 IAM ARN 전달
```bash
$ kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::{{ account }}:role/{{ role name }}
```

6. deployment/cluster-autoscaler eviction 방지 설정
```bash
$ kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

// 또는

$ kubectl -n kube-system annotate deployment/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
```

7. Cluster version에 맞는 cluster-autoscaler 버전 사용하도록 변경

```yaml
containers:
        - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.20.1
          name: cluster-autoscaler
```

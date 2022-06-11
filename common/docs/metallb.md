### MetalLB
* https://metallb.universe.tf/installation/
* On-Premise k8s 환경에서 외부 L4 switch 없이 로드밸런싱 기능 제공
* MetalLB Pod가 Restart되면 서비스에는 영향 없으나, ARP를 할당하는 노드가 down되면 10초 내외 down 발생할 수 있다.

##### Installation by Manifest
```bash
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
```

###### IP Pool (layer2)
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
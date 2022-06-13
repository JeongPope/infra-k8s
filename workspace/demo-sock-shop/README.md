# Demo MSA : Socks-shop

### Reference
* [Weaveworks : Sock Shop](https://microservices-demo.github.io/docs/quickstart.html)
* [microservice-demo](https://github.com/microservices-demo/microservices-demo/tree/master/deploy/kubernetes)
* [gasida/KANS](https://github.com/gasida/KANS/blob/main/msa/sock-shop-demo.yaml)

### Deploy
```bash
# 1. Jaeger
$ kubectl apply -f jaeger.yaml

# 2. Apps
# $ kubectl apply -k {{ kustomization.yaml path in overlay folder }}
$ kubectl apply -k ./carts/overlays/dev
```
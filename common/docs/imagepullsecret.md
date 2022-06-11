## Private registry에서 Image pull을 위한 `ImagePullSecret`

```bash
$ kubectl create secret docker-registry {{ resource_name }} \
  -n {{ namespace }}
  --docker-server={{ harbor.server }} \
  --docker-username={{ harbor.username }} \
  --docker-password={{ harbor.password }} --dry-run=client -o yaml > harbor.yaml
```
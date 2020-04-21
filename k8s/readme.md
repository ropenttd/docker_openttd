# Kubernetes Manifests

Use these manifests as a jumping off point for deploying your own server on your cluster.

Remember, the configmap is readonly, so things like bans or variable changes won't be written back to it, and as such won't be read on container re-init.

If you don't know what any of this means, you're probably better off sticking to standard Docker deployment.

### Kustomize
These manifests are ready to go with Kustomize: you could use a `kustomization.yaml` in your own project like the following:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
 - github.com/ropenttd/docker_openttd/k8s

namespace: openttd
namePrefix: s1-

commonLabels:
  app: openttd-game

configMapGenerator:
- name: config
  namespace: openttd
  behavior: replace
  files:
  - openttd.cfg

images:
- name: redditopenttd/openttd
  newTag: testing
```

Then simply sit a valid `openttd.cfg` next to it, run `kubectl apply -k .`, and marvel as your server is magically created.

If you want to change the ports that are mounted (or use NodePort services), simply override the services with something like the following:

```yaml
patchesStrategicMerge:
  - services.yaml
```
# Example kubernetes manifests

Use these manifests as a jumping off point for deploying your own server on your cluster.

You'll want to change a few things, such as adding a namespace to them, and adding your configuration into the configmap.

Remember, the configmap is readonly, so things like bans or variable changes won't be written back to it, and as such won't be read on container re-init.


If you don't know what any of this means, you're probably better off sticking to standard Docker deployment.
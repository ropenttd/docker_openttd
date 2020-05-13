# OpenTTD in Docker
__An image brought to you by /r/openttd__

![Build and Push Latest Versions](https://github.com/ropenttd/docker_openttd/workflows/Build%20and%20Push%20Latest%20Versions/badge.svg?branch=master)
[![](https://images.microbadger.com/badges/image/redditopenttd/openttd.svg)](https://microbadger.com/images/redditopenttd/openttd "Get your own image badge on microbadger.com")

Built from OpenTTD source to provide the leanest, meanest image you'll come across for putting trainsets in containers.


## Using this Container on Docker

```
docker run -d -p 3979:3979/tcp -p 3979:3979/udp redditopenttd/openttd:latest
```

The container is set by default to start a fresh game every time you restart the container. You can, however, change this behaviour with the `loadgame` envvar:
```
-e "loadgame={false|last-autosave|exit|(savename)}"
```
where:
* false: standard behaviour, just start a new game
* last-autosave: load the last chronological autosave
* exit: try to load autosave/exit.sav, otherwise default to a new game
* (savename): full name of a save file in config/saves

You'll probably want stuff to be persistant between container rebuilds, so we've got the `/config` volume for exactly that purpose.

```
-v /home/{username}/.openttd:/config:rw
```
**Heads up:** If we can't find an `openttd.cfg` in `/config`, we'll attempt to ask OpenTTD to start a new configuration directory there. We strongly recommend that if you're starting fresh, you stop the container and configure openttd.cfg as per [the wiki](https://wiki.openttd.org/Openttd.cfg).

If you don't want the entire `.openttd` directory to be copied to your local FS statically, you may want to consider mounting files / directories directly like so:

```
-v /home/{username}/.openttd/openttd.cfg:/config/openttd.cfg:ro
-v /home/{username}/.openttd/save/:/config/save:rw
```
The easiest way to play with NewGRF's is to first download and configure them how you want on a local machine with a GUI. Then in the config/ directory copy the folder from local machine named content_downloaded to the server. Next update the openttd.cfg file from your local machine, this is to ensure that when you create a new server your NewGRF settings will be copied across.

### An example command to start a server
```
docker run -it -p 3979:3979/tcp -p 3979:3979/udp -v /home/{username}/.openttd:/config:rw -e "loadgame=game.sav" redditopenttd/openttd:latest
```
This will start a server with the console accessible due to ```-it``` in the command line, to run in the background use ```-d```.

## Running on Kubernetes

Because OpenTTD is quite heavily stateful, we have written some handy helper containers for you to use as init containers and sidecars. Please see the [openttd_k8s-helpers](https://github.com/ropenttd/openttd_k8s-helpers) repo for more information.

## Tags
We'll automatically build a new tag every time a new beta or release candidate is released. If you'd like nightlies as well, please contact us, and I'll work it into our build scripts.

* `stable` and `latest` track the latest stable release of OpenTTD.
* `testing` tracks the latest _unstable_ release of OpenTTD. This includes betas and release candidates.
* **`rc` and `beta` are deprecated** in favour of `testing`.
* The `nightly` tag is reserved for nightly builds (but is not currently functional).

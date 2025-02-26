# Containerised OpenTTD
__An image brought to you by /r/openttd__

![Build](https://github.com/ropenttd/docker_openttd/actions/workflows/build.yml/badge.svg)

Built from OpenTTD source to provide the leanest, meanest image you'll come across for putting trainsets in containers.


## Important Changes

### 2025.1.1

A workaround to use existing game folder locations, if present, was added. New installations of the container will use `/config` by default - and whilst it is recommended to migrate when possible, this provides backwards compatibility.

### 2025.1
The location of saved games / content was moved back to `/config` as originally intended. This incorrect functionality has been present for quite some time, but is now fixed.

~~**This may well break existing installations**.~~ If it does, move the contents of `{config}/.local/share/` to `{config}` - done correctly, your existing `openttd.cfg` and `save` directories (among others) should exist in `/config` in the container.

## Image Names & Tags

The CI system will automatically build the current latest versions at 3AM every day. This is a little hacky, but it does mean we get new builds within 24 hours of release.

You can find the images at the following locations:

| Registry | URI |
| -------- | --- |
| **prefer** Github Container Registry | [ghcr.io/ropenttd/openttd:{tag}](https://github.com/orgs/ropenttd/packages/container/package/docker_openttd)  |
| **deprecated** Docker Hub  | docker.io/redditopenttd/openttd:{tag}  |

**Please prefer the Github Container registry for new deployments.** It's 100% compatible with your Docker installation.

| Tag(s) | Description |
| --- | ----------- |
| stable, latest | The latest stable release of OpenTTD. |
| _Major Version_ | The latest stable release for this major version (i.e _7_ may point to _7.1.2_) |
| testing | The latest _unstable_ release of OpenTTD, including betas and release candidates. |
| nightly | _Reserved_ (if you need this, raise an issue!) |

### Architectures

Images are built for _AMD64_ (x86_64, i.e 64bit PC) and _ARM64_ (modern ARM, i.e Raspberry Pi 3 running 64-bit OS).

If you need an architecture not listed above, please raise an issue.

## Using this Container
### Docker

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
    * Please make sure `autosave_on_exit = true` in your _openttd.cfg_ for this to work.
* (savename): full name of a save file in config/saves

You'll probably want stuff to be persistent between container rebuilds, so we've got the `/config` volume for exactly that purpose.

```
-v /home/{username}/.openttd:/config:rw
```

> [!IMPORTANT]  
> If we can't find an `openttd.cfg` in `/config`, we'll attempt to ask OpenTTD to start a new configuration directory there.
> We strongly recommend that if you're starting fresh, you stop the container and configure `openttd.cfg` as per [the wiki](https://wiki.openttd.org/Openttd.cfg).

> [!WARNING]  
> Separately mounting sub-directories of `/config` (such as `/save`) is unsupported, and may result in
> strange behavior (in particular, saves failing). If things seem funky, try just mounting `/config`.

The easiest way to play with NewGRF's is to first download and configure them how you want on a local machine with a GUI. Then in the config/ directory copy the folder from local machine named content_downloaded to the server. Next update the openttd.cfg file from your local machine, this is to ensure that when you create a new server your NewGRF settings will be copied across.

#### An example command to start a server
```
docker run -it -p 3979:3979/tcp -p 3979:3979/udp -v /home/{username}/.openttd:/config:rw -e "loadgame=game.sav" redditopenttd/openttd:latest
```
This will start a server with the console accessible due to ```-it``` in the command line, to run in the background use ```-d```.

### podman

Replace all of the `docker` commands in the _docker_ section with `podman`. If you're having issues, please raise an issue.

### Kubernetes

Because OpenTTD is quite heavily stateful, we have written some handy helper containers for you to use as init containers and sidecars. Please see the [openttd_k8s-helpers](https://github.com/ropenttd/openttd_k8s-helpers) repo for more information.

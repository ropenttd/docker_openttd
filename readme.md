# OpenTTD in Docker
__An image brought to you by /r/openttd__

Built with Alpine Linux and from OpenTTD source to provide the leanest, meanest container you'll come across for putting trainsets in containers.

## Using this Container
```
docker run -d -p 3979:3979/tcp -p 3979:3979/udp redditopenttd/openttd:latest
```

The container is set by default to start a fresh game every time you restart the container. You can, however, change this behaviour with the `savegame` envvar:
```
-e savegame={false|autosave|exit|(savename)}
```
where:
* false: standard behaviour, just start a new game
* autosave: load the last chronological autosave
* exit: try to load exit.sav
* (savename): full name of a save file in config/saves

You'll probably want stuff to be persistant between container rebuilds, so we've got the `/config` volume for exactly that purpose.

```
-v /home/{username}/.openttd:/config:rw
```
**Heads up:** If we can't find an `openttd.cfg` in `/config`, we'll ask OpenTTD to start a new configuration directory there. We strongly recommend that if you're starting fresh, you stop the container and configure openttd.cfg as per [the wiki](https://wiki.openttd.org/Openttd.cfg).

## Tags
We'll automatically build a new tag every time a new beta or release candidate is released. If you'd like nightlies as well, please contact us, and I'll work it into our build scripts.

* `latest` currently tracks `stable`, but this may change in future to track nightly releases.
* `stable` tracks the latest stable release of OpenTTD.
* `testing` tracks the latest release candidate or beta build of OpenTTD, falling back to the latest stable if it's newer.

The build scripts are also set up to also tag with the version number, in case you want to pin to a specific version: check the tags for a full lineup.

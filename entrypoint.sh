#!/bin/bash

# This script is based off bateau84/openttd's. Thanks, man!
savepath="/config/save"

if [ ! -f /config/openttd.cfg ]; then
  # we start the server then kill it quickly to write a config file
  # yes this is a horrific hack but whatever
  echo "No config file found: generating one"
  timeout -t 3 /app/bin/openttd -D > /dev/null 2>&1
fi

autosave_target=""
savegame_target="${savepath}/${loadgame:=exit}"
case ${loadgame} in
  'exit')
    savegame_target="${savepath}/autosave/exit.sav"
    ;&
  'last-autosave')
    autosave_target="${savepath}/autosave/$(ls -1rt ${savepath}/autosave/ | tail -n1)"
    # IFF the the exit savegame is older than the autosave, we're recovering from a crash.
    # Also handles the not-found case - A nonexistent file is older than an existing file.
    if [[ "${savegame_target}" -ot "${autosave_target}" ]]; then
      savegame_target="${autosave_target}"
    fi
    ;;&
  *)
    if [ -f "${savegame_target}" ]; then
      echo "Loading ${savegame_target}"
      exec /app/bin/openttd -D -g "${savegame_target}" -x -d "${DEBUG}"
    else
      if [[ ${loadgame} != "false" ]]; then
        echo "${savegame_target} not found..."
      fi
      echo "Creating a new game."
      exec /app/bin/openttd -D -x -d "${DEBUG}"
      exit 1
    fi
    ;;
esac

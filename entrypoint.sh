#!/bin/sh

# This script is based fairly heavily off bateau84/openttd's. Thanks, man!
savepath="/config/save"
LOADGAME_CHECK="${loadgame}x"

if [ ! -f /config/openttd.cfg ]; then
        # we start the server then kill it quickly to write a config file
        # yes this is a horrific hack but whatever
        echo "No config file found: generating one"
        timeout 3 /app/openttd -D > /dev/null 2>&1
fi

if [ ${LOADGAME_CHECK} != "x" ]; then
        case ${loadgame} in
                'false')
                	echo "Creating a new game."
                    exec /app/openttd -D -x -d ${DEBUG}
                    exit 0
                ;;
                'last-autosave')
            		savegame_target=${savepath}/autosave/`ls -rt ${savepath}/autosave/ | tail -n1`

            		if [ -r ${savegame_target} ]; then
                    	echo "Loading from autosave - ${savegame_target}"
                        exec /app/openttd -D -g ${savegame_target} -x -d ${DEBUG}
                        exit 0
            		else
                		echo "${savegame_target} not found..."
                		exit 1
            		fi
                ;;
                'exit')
            		savegame_target="${savepath}/autosave/exit.sav"

            		if [ -r ${savegame_target} ]; then
                    	echo "Loading from exit save"
                        exec /app/openttd -D -g ${savegame_target} -x -d ${DEBUG}
                        exit 0
            		else
                		echo "${savegame_target} not found - Creating a new game."
                		exec /app/openttd -D -x -d ${DEBUG}
                    	exit 0
            		fi
                ;;
                *)
                	savegame_target="${savepath}/${loadgame}"
                    if [ -f ${savegame_target} ]; then
                            echo "Loading ${savegame_target}"
                            exec /app/openttd -D -g ${savegame_target} -x -d ${DEBUG}
                            exit 0
                    else
                            echo "${savegame_target} not found..."
                            exit 1
                    fi
                ;;
        esac
else
        echo "loadgame not set - Creating a new game."
    	exec /app/openttd -D -x -d ${DEBUG}
        exit 0
fi

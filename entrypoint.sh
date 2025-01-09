#!/bin/sh

# This script is based fairly heavily off bateau84/openttd's. Thanks, man!

SAVEPATH="/config/save"
LOADGAME_CHECK="${loadgame}x"
EXTRA_FLAGS="-c /config/openttd.cfg"

# Required to force config to save to /config
if [ -f /config/.config/openttd.cfg ]; then
        export XDG_DATA_HOME=''
        SAVEPATH="/config/.config/save"
        EXTRA_FLAGS="-c /config/.config/openttd.cfg"
        echo "WARN: Using legacy configuration directory /config/.config/ - it is recommended to migrate to all data inside /config/* when possible."
elif [ ! -f /config/openttd.cfg ]; then
        # we start the server then kill it quickly to write a config file
        # yes this is a horrific hack but whatever
        echo "INFO: No config file found: generating one"
        timeout 3 /app/openttd -D ${EXTRA_FLAGS} > /dev/null 2>&1
fi

if [ "${LOADGAME_CHECK}" != "x" ]; then
        case ${loadgame} in
                'false')
                        echo "INFO: Creating a new game."
                        exec /app/openttd -D ${EXTRA_FLAGS} -x  -d ${DEBUG}
                        exit 0
                ;;
                'last-autosave')
            		SAVEGAME_TARGET=`ls -rt ${SAVEPATH}/autosave/*.sav | tail -n1`

            		if [ -r "${SAVEGAME_TARGET}" ]; then
                    	echo "INFO: Loading from latest autosave - ${SAVEGAME_TARGET}"
                        exec /app/openttd -D ${EXTRA_FLAGS} -g ${SAVEGAME_TARGET} -x -d ${DEBUG}
                        exit 0
            		else
                		echo "FATAL: ${SAVEGAME_TARGET} not found"
                		exit 1
            		fi
                ;;
                'exit')
            		SAVEGAME_TARGET="${SAVEPATH}/autosave/exit.sav"

            		if [ -r "${SAVEGAME_TARGET}" ]; then
                    	echo "INFO: Loading from exit save"
                        exec /app/openttd -D ${EXTRA_FLAGS} -g "${SAVEGAME_TARGET}" -x -d ${DEBUG}
                        exit 0
            		else
                		echo "${SAVEGAME_TARGET} not found - Creating a new game."
                		exec /app/openttd -D ${EXTRA_FLAGS} -x -d ${DEBUG}
                    	exit 0
            		fi
                ;;
                *)
                        SAVEGAME_TARGET="${SAVEPATH}/${loadgame}"
                        if [ -r "${SAVEGAME_TARGET}" ]; then
                                echo "INFO: Loading ${SAVEGAME_TARGET}"
                                exec /app/openttd -D ${EXTRA_FLAGS} -g "${SAVEGAME_TARGET}" -x -d ${DEBUG}
                                exit 0
                        else
                                echo "FATAL: ${SAVEGAME_TARGET} not found"
                                exit 1
                        fi
                ;;
        esac
else
        echo "INFO: loadgame not set - Creating a new game."
    	exec /app/openttd -D ${EXTRA_FLAGS} -x -d ${DEBUG}
        exit 0
fi

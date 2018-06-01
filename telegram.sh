#!/bin/bash

### Config ###

# This should be your telegram bot token
token="you should write your token here"

# This is the address where request will be made
base_url="https://api.telegram.org/bot"

# This defines what command files will be executed
path="commands.sh"
# Note : can be set to mutliple files with *
# path="commands/*.sh"

# Please don't change this
offset=0

function post() {

        get_method="$1"
        target="$base_url$token/$get_method"

        declare -A request

        # Catching every argument with = and adding to to an associative aray
        while :; do
                case $2 in
                        '--print-output' | '-o')
                            print_output="true"
                            ;;

                        ?*=?*)
                            request[${2%=*}]="${2%=*}=${2#*=}"
                            ;;

                        *)
                            break
                            ;;
                esac
                shift
        done

        # Sending the request by listing the array
        QUERY=$(curl -s "$target" "${request[@]/#/-d}")

        # Basic response parsing
        if [ $(echo "$QUERY" | jq -cr '.ok') == "true" ]; then

            # Check if the print output argument was used
            if [ "$print_output" = true ]; then
                 echo $(echo "$QUERY" | jq -cr '.result')
            else
                echo "[SENT] method : $get_method"
             fi
        else
            echo "[ERROR] $(echo "$QUERY" | jq -cr '.')"
        fi

}

function parse() {

        # Declare an associative array for the type of request
        declare -A $(echo "$REQUEST" | jq -cr '.result[0] | del(.update_id) | keys | .[]')

        # Parsing and saving every var
        eval "$(echo "$REQUEST" | jq -cr '.result[0] | del(.update_id) | tostream | select(length==2) | .[0] |= map(strings) | flatten | "\(.[:1] |.[])[\(.[1:-1] | join("."))]=\"\(.[-1])\""')"
        
        # Source every file ending with .func.sh
        for file in "$path" ; do
                if [ -f "$file" ] ; then
                        . "$file"
                        echo "$?"
                fi
        done
}

# If not sourced, start long polling
if [ "$0" = "$BASH_SOURCE" ]; then

        echo "Started long polling..."
        while :
        do

                REQUEST=$(curl -s "$base_url$token/getUpdates?offset=$offset&timeout=60&limit=1")

                OFFSET_DATA=$(echo "$REQUEST" | jq -cr '.result|.[0].update_id')

                # Check if new update is detected
                if [ ! "$OFFSET_DATA" == "null" ]; then

                        # Check if jq failed to parse offset
                        if [ ! -z "$OFFSET_DATA" ]; then

                            # If jq was okay, continue parsing
                            offset=$((OFFSET_DATA+1))
                            echo "[RECEIVED] update $offset"

                            # Start a child process and parse
                            parse &
                        else

                            # Handles exception by skipping the request
                            offset=$((offset+1))
                            echo "[ERROR] couldn't parse $offset, skipping..."
                        fi

                fi
        done
fi

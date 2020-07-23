#!/usr/bin/env bash

_TEXT="${BASEDIR}/configurations/greet.txt"
#_TEXT="configurations/greet.txt"

start.message() {
    local message
    
    message=$(cat ${_TEXT})

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "$(echo -e ${message})" \
                            --parse_mode markdown
}


#!/bin/bash

source ${BASEDIR}/ShellBot.sh
ShellBot.init --token "${TELEGRAM_TOKEN}" --monitor --flush

############ Adicione abaixo botões inline que poderão ser chamados no seu bot ##############
#botao1=''
#
#ShellBot.InlineKeyboardButton --button 'botao1' --line 1 --text 'SIM' --callback_data 'btn_s'
#ShellBot.InlineKeyboardButton --button 'botao1' --line 1 --text 'NAO' --callback_data 'btn_n'
#
#ShellBot.regHandleFunction --function linux.add --callback_data btn_s
#ShellBot.regHandleFunction --function linux.reject --callback_data btn_n
#
#keyboard_accept="$(ShellBot.InlineKeyboardMarkup -b 'botao1')"
###############################################################################################



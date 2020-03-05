#!/bin/bash
#

export BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"
# Importante utils, script que contem o setup de inicialização do bot
source ${BASEDIR}/utils.sh

while :
do
	ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30

	for id in $(ShellBot.ListUpdates)
	do
	(
		ShellBot.watchHandle --callback_data ${callback_query_data[$id]}

		if [[ ${message_entities_type[$id]} != bot_command ]] && [[ -z ${callback_query_data} ]]; then
			listar.compras "${message_text}"
		fi
		case ${callback_query_data[$id]} in
      item_comprado)
			  listar.apagar
			;;
			item_valor)
				listar.preco
      ;;
    esac
	) &
	done
  
done

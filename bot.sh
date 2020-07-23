#!/usr/bin/env bash
#

export BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"
# Importante utils, script que contem o setup de inicialização do bot
source ${BASEDIR}/utils.sh

while :
do
	ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30

	for id in $(ShellBot.ListUpdates); do
	    (
            ShellBot.watchHandle --callback_data ${callback_query_data[$id]}

            if [[ ${message_entities_type[$id]} != bot_command ]] && \
                        [[ -z ${callback_query_data} ]] && \
                        [[ -z ${message_reply_to_message_message_id} ]]; then
                listar.compras "${message_text}"
            fi
            case ${callback_query_data[$id]} in
                item_comprado) listar.apagar ;;
                item_valor) listar.preco ;;
                _concluir) listar.concluir ;;
                _concluir_sim) listar.sim ;;
                _concluir_nao) listar.go_shopping ;;
            esac

            if [[ ${message_entities_type[$id]} == bot_command ]] && [[ -z ${callback_query_data} ]]; then
                case ${message_text[$id]%%@*} in
                    /verlista) listar.go_shopping ;;
                    /start|/help) start.message ;;
                esac
            fi

            if [[ "$(echo ${callback_query_data[$id]} | grep "${_WARN}\|${_OK}\|Refresh")" ]]; then
                listar.go_botoes
            fi

            if [[ ${message_reply_to_message_message_id[$id]} ]]; then
                case ${message_reply_to_message_text[$id]} in
                    'Valor Total da Compra:') listar.valor_total "${message_text[$id]}" ;;
                esac
            fi
	    ) &
    done  
done

#!/usr/bin/env bash

_WARN="⚠️"
_OK="✅"
_LUPA="🔍"
_CART="🛒"
_REFRESH="🔄"
_EDIT="✍️"

listar.compras(){
        local item file_list folder
        item=$1
        
        if [[ ${callback_query_message_chat_id[$id]} ]]; then
            folder="${callback_query_message_chat_id[$id]//-/}"
            file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
        else
            folder="${message_chat_id[$id]//-/}"
            file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
        fi

        if [[ ! -f "${file_list}" ]]; then
            mkdir -p ${file_list%%_*}
        fi
        echo "${_WARN},${item}" >> ${file_list}
                        
        ShellBot.deleteMessage --chat_id ${message_chat_id[$id]} --message_id ${message_message_id[$id]}
}

listar.go_shopping() {
    local file_list folder
    
    if [[ ${callback_query_message_chat_id[$id]} ]]; then
        folder="${callback_query_message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    else
        folder="${message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    fi

    if [[ -f ${file_list} ]]; then
        
        botao_go_shopping=''

        count=1
        while read line; do
            rem=$(( ${count} % 3))
            if [[ ${rem} -eq 0 ]]; then
                count=$((count+1))
                ShellBot.InlineKeyboardButton --button 'botao_go_shopping' --text "$(echo ${line} | tr ',' ' ')" --callback_data "${line}" --line ${count}
            else
                ShellBot.InlineKeyboardButton --button 'botao_go_shopping' --text "$(echo ${line} | tr ',' ' ')" --callback_data "${line}" --line ${count}                
                count=$((count+1))
            fi
        done < ${file_list}
        
        ShellBot.InlineKeyboardButton --button 'botao_go_shopping'\
            --text "${_CART} - Finalizar" \
            --callback_data "_concluir" \
            --line 999
        ShellBot.InlineKeyboardButton --button 'botao_go_shopping'\
            --text "${_REFRESH} - Refresh" \
            --callback_data "Refresh" \
            --line 999
        ShellBot.InlineKeyboardButton --button 'botao_go_shopping'\
            --text "${_EDIT} - Editar" \
            --callback_data "_edit" \
            --line 999

        keyboard_go_shopping="$(ShellBot.InlineKeyboardMarkup -b 'botao_go_shopping')"
        
        if [[ ${message_chat_id[$id]} ]]; then
            ShellBot.deleteMessage --chat_id ${message_chat_id[$id]} --message_id ${message_message_id[$id]}
            ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "*LISTA COMPLETA*" \
                            --parse_mode markdown \
                            --reply_markup "$keyboard_go_shopping"
        else
            ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} --message_id ${callback_query_message_message_id[$id]}
            ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                            --text "*LISTA COMPLETA*" \
                            --parse_mode markdown \
                            --reply_markup "$keyboard_go_shopping"
        fi
    else
        message="*Lista Vazia!*"
        ShellBot.deleteMessage --chat_id ${message_chat_id[$id]} --message_id ${message_message_id[$id]}
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "$(echo -e ${message})" \
                            --parse_mode markdown
    fi      
}

listar.go_botoes() {
    local file_list float_message count folder

    if [[ ${callback_query_message_chat_id[$id]} ]]; then
        folder="${callback_query_message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    else
        folder="${message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    fi
    
    botao_edit_shopping=''

    if [[ -f "${file_list}" ]]; then
        if [[ "$(echo ${callback_query_data[$id]} | grep ${_WARN})" ]]; then
            sed -i "s/${callback_query_data}/${_OK}\,${callback_query_data##*,}/" ${file_list}
            float_message="item comprado..."
        fi
        if [[ "$(echo ${callback_query_data[$id]} | grep ${_OK})" ]]; then
            sed -i "s/${callback_query_data}/${_WARN}\,${callback_query_data##*,}/" ${file_list}
            float_message="item retornado..."
        fi
        
        count=1
        while read line; do
            rem=$(( ${count} % 3))
            if [[ ${rem} -eq 0 ]]; then
                count=$((count+1))
                ShellBot.InlineKeyboardButton --button 'botao_edit_shopping' \
                    --text "$(echo ${line} | tr ',' ' ')" \
                    --callback_data "${line}" --line ${count}
            else
                ShellBot.InlineKeyboardButton --button 'botao_edit_shopping' \
                    --text "$(echo ${line} | tr ',' ' ')" \
                    --callback_data "${line}" --line ${count}                
                count=$((count+1))
            fi
        done < ${file_list}
    fi
    
    ShellBot.InlineKeyboardButton --button 'botao_edit_shopping' \
        --text "${_CART} - Finalizar" \
        --callback_data "_concluir" \
        --line 999
    ShellBot.InlineKeyboardButton --button 'botao_edit_shopping' \
        --text "${_REFRESH} - Refresh" \
        --callback_data "Refresh" \
        --line 999
    ShellBot.InlineKeyboardButton --button 'botao_go_shopping'\
            --text "${_EDIT} - Editar" \
            --callback_data "_edit" \
            --line 999

    keyboard_edit_shopping="$(ShellBot.InlineKeyboardMarkup -b 'botao_edit_shopping')"

    ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "${float_message}"
    ShellBot.editMessageReplyMarkup --chat_id ${callback_query_message_chat_id[$id]} \
                        --message_id ${callback_query_message_message_id[$id]} \
                        --reply_markup "$keyboard_edit_shopping"
}

listar.concluir() {
    local file_list folder
    
    if [[ ${callback_query_message_chat_id[$id]} ]]; then
        folder="${callback_query_message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    else
        folder="${message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    fi
	
    if [[ $(cat ${file_list} | grep "${_OK}") ]]; then

	    botao_confirmar=''

	    ShellBot.InlineKeyboardButton --button 'botao_confirmar' \
        	--text "SIM" \
	        --callback_data "_concluir_sim" \
        	--line 1
	
	    ShellBot.InlineKeyboardButton --button 'botao_confirmar' \
        	--text "NÃO" \
	        --callback_data "_concluir_nao" \
        	--line 1
        
	    keyboard_confirmar="$(ShellBot.InlineKeyboardMarkup -b 'botao_confirmar')"
    
	    ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} \
        	    --text "chega por hoje..."
    
	    ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} \
        	                --message_id ${callback_query_message_message_id[$id]}
    
	    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        	                --text "*Deseja finalizar a compra?*" \
                	        --parse_mode markdown \
                        	--reply_markup "$keyboard_confirmar"
    else
	    ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} \
            --text "nenhum item comprado..."

        ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} \
                                --message_id ${callback_query_message_message_id[$id]}

        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                                --text "Estou *escondendo* a lista, mas pode chamá-la novamente com o comando /verlista" \
                                --parse_mode markdown
    fi
}

listar.sim() {

    ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} --message_id ${callback_query_message_message_id[$id]}    
    message="Valor Total da Compra:"
  	ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e ${message})" \
        				--reply_markup "$(ShellBot.ForceReply)"
}

listar.valor_total() {
    local file_list doc total _chat_id

    total=$1
    folder="${message_chat_id[$id]//-/}"    
    file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    doc=${file_list%%_*}$(date +%Y%m%d-%H%M%S).csv

    while IFS= read -r line || [[ -n "$line" ]]; do
	    if [[ $(echo ${line} | grep ${_OK}) ]]; then
		    echo ${line} >> ${doc}
	    else
		    echo ${line} >> ${file_list}_back
	    fi
    done < ${file_list}

    if [[ -f "${file_list}_back" ]]; then mv ${file_list}_back ${file_list}; fi
    if [[ $(cat ${file_list} | grep "${_WARN}") ]]; then
    	ShellBot.sendMessage --chat_id ${message_reply_to_message_chat_id[$id]} \
                        --text "Não se esquece que ainda há itens na lista!\nPara ver os itens que ainda não foram comprados clique aqui /verlista" \
                        --parse_mode markdown
    else
    	rm -fr ${file_list}
    fi

    ShellBot.deleteMessage --chat_id ${message_reply_to_message_chat_id[$id]} \
                        --message_id ${message_reply_to_message_message_id[$id]}

    echo "Total,${total//,/.}" >> ${doc}

    ShellBot.sendMessage --chat_id ${message_reply_to_message_chat_id[$id]} \
                        --text "*Resumo da compra realizado em $(date +%d) do $(date +%m)*" \
                        --parse_mode markdown
    ShellBot.sendDocument --chat_id ${message_reply_to_message_chat_id[$id]} \
							--document @${doc}
}

listar.editar() {
    local file_list folder message _item float_message

    _item=$1
    
    if [[ ${callback_query_message_chat_id[$id]} ]]; then
        folder="${callback_query_message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    else
        folder="${message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    fi

    if [[ -f "${file_list}" ]] && [[ -z "${_item}" ]]; then
        message="Qual item:"
  	    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e ${message})" \
        				--reply_markup "$(ShellBot.ForceReply)"
    elif [[ ! -f "${file_list}" ]] && [[ -z "${_item}" ]]; then
        float_message="Sem item na lista atual..."
        ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "${float_message}"
    else
        has_item="$(cat ${file_list} | grep "${_item}")"
        if [[ "${has_item}" ]]; then
            echo "${has_item}" >> ${file_list}_edit
            message="Editar para:"
  	        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e ${message})" \
        				--reply_markup "$(ShellBot.ForceReply)"
        fi
    fi

}

listar.aplicar() {
    local file_list folder message _item _new_item float_message

    _new_item=$1
    _item="$(head -1 ${file_list}_edit)"
    rm -fr ${file_list}_edit
    
    if [[ ${callback_query_message_chat_id[$id]} ]]; then
        folder="${callback_query_message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    else
        folder="${message_chat_id[$id]//-/}"
        file_list="${BOT_PRECOS_FILE}/${folder}/_list.log"
    fi

    sed -i "s/${_item}/${_new_item}/" ${file_list}

}

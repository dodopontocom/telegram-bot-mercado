#!/bin/bash
# 

# procura no site do tenda atacado e retorna o primeiro resultado do produto e preço

product.search() {
  local product_name first_found product_price message

  #product_name=${message_text/ /%20}
  product_name=${callback_query_message_text/ /%20}
  echo "site ---> ${TENDA_SUP_URL}/${product_name}"
  echo ${product_name}
  
  first_found="$(curl -sSS ${TENDA_SUP_URL}/${product_name} | grep "escaped-name" | cut -d'>' -f2 | cut -d'<' -f1 | head -1)"
  echo ${first_found}
  product_price="$(curl -sSS ${TENDA_SUP_URL}/${product_name} | grep -A11 "${first_found}" | tail -1 | sed "s:[\t ]::g")"

  echo ${product_price}

  if [[ ${first_found} ]] && [[ ${product_price} ]]; then
          message="Você pode encontrar ${product_name} no *\`TENDA ATACADISTA\`*\n\n"
          message+="*Produto/Marca:* ${first_found//[&#]/}\n\n"
          message+="*Preço:* ---> ${product_price}"

          ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]}
          ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                              --text "$(echo -e ${message})" --parse_mode markdown
  else
          message="Produto não encontrado..."
          ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]}
          ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                              --text "$(echo -e ${message})" --parse_mode markdown
  fi

}

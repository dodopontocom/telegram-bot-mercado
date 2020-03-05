#!/bin/bash

# Helpers

# usage function
helper.usage() {
   cat << USAGE

   Usage: $(basename $0) [--num NUM] [--time TIME_STR] [--verbose] [--dry-run]

   optional arguments:
     -h, --help           show this help message and exit
     -n, --num NUM        pass in a number
     -t, --time T IME_STR  pass in a time string
     -v, --verbose        increase the verbosity of the bash script
     --dry-run            do a dry run, dont change any files

USAGE
}

helper.welcome_message() {
	local message

	message="🆔 [@${message_new_chat_member_username[$id]:-null}]\n"
    	message+="🗣 Olá *${message_new_chat_member_first_name[$id]}*"'!!\n\n'
    	message+="Seja bem-vindo(a) ao *${message_chat_title[$id]}*.\n\n"
    	message+='`Se precisar de ajuda ou informações sobre meus comandos, é só me chamar no privado.`'"[@$(ShellBot.username)]"

	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
		--text "$(echo -e ${message})" --parse_mode markdown

	return 0	
}

exitOnError() {
  # usage: exitOnError <output_message> [optional: code (defaul:exit code)]
  code=${2:-$?}
  if [[ $code -ne 0 ]]; then
      if [ ! -z "$1" ]; then echo -e "ERROR: $1" >&2 ; fi
      echo "Exiting..." >&2
      exit $code
  fi
}

# Verifica se variáveis necessárias estão exportadas no sistema
helper.validate_vars() {
  local vars_list=($@)
        
  for v in $(echo ${vars_list[@]}); do
    export | grep ${v} > /dev/null
    result=$?
    if [[ ${result} -ne 0 ]]; then
      echo "Dependency of ${v} is missing"
      echo "Exiting..."
      exit -1
    fi
  done
}

# Faz 'replace' de variáveis pelo seus valores se foram corretamente declarados
helper.replace_vars() {
  # Lê arquivo.
  conteudo=$(< $1)

  # Grupo
  re='([a-zA-Z0-9_]+)'

  # Lê o contéudo enquanto houver variáveis.
  #
  # Ex: ${var1}, ${var2} ...
  #
  while [[ $conteudo =~ \$\{$re\} ]]; do
      # Substitui a variável casada pelo seu valor (se presente), caso
      # contrário sinaliza com '!' o seu identificador para ser ignorado
      # nas próximas verificações.
      #
      # Ex: ${var_nula} -> !{var_nula}
      #
      [[ ${!BASH_REMATCH[1]} ]]                                   &&
      conteudo=${conteudo//$BASH_REMATCH/${!BASH_REMATCH[1]}}     ||
      conteudo=${conteudo//$BASH_REMATCH/!${BASH_REMATCH#?}}
  done

  # Restaura identificadores ignorados.
  while [[ $conteudo =~ \!\{$re\} ]]; do
      conteudo=${conteudo//$BASH_REMATCH/\$${BASH_REMATCH#?}}
  done

  # Gera o novo arquivo.
  echo "$conteudo" > $2
}

# Faz cálculos com datas
helper.date_arithimetic() {
  #credits https://gist.github.com/alvfig/f04130aef28e30f96b6bb63a5b81ba80

  secs()
  {
      TZ=UTC date --date="$1" '+%s'
  }

  date_diff()
  {
      expr \( `secs "$1"` - "$2" \) / 86400
  }

  days_from_today()
  {
      date_diff $1 "$(date +'%s')"
  }

  date_plus_days()
  {
      date --iso-8601 --date="$1 + $2 days"
  }

  today_plus_days()
  {
      date_plus_days "" $1
  }
  
  function=$1
  shift
  $function "$@"
}

helper.calc_min() {
	awk "BEGIN { print "$*" }"
}

# Remove acentos
helper.remove_acento() {
  local str ret_str sed_file
  sed_acentos=$(cat << EOF
s/ã/a/g
s/Ã/A/g
s/à/a/g
s/À/A/g
s/ô/o/g
s/ô/o/g
s/Õ/O/g
s/é/e/g
s/É/E/g
s/á/a/g
s/ó/o/g
s/Á/A/g
s/Ó/O/g
s/ç/c/g
s/Ç/C/g
s/ê/e/g
s/Ê/E/g
s/ú/u/g
s/Ú/U/g
s/â/a/g
s/Â/A/g
s/í/i/g
s/Í/I/g
s/Ü/U/g
s/ü/u/g
EOF
)
  
  str=$1
  ret_str=$(echo "$str" | sed "${sed_acentos}")
  echo $ret_str
}

helper.get_api() {
	
  local tmp_folder current_version check_new_version

  tmp_folder=/tmp/$(helper.random)
  check_new_version=$(curl -sS ${API_VERSION_RAW_URL} | grep VERSÃO | grep -o [0-9].*)
  current_version=$(cat ${BASEDIR}/ShellBot.sh | grep VERSÃO | grep -o [0-9].*)

  if [[ "${current_version}" != "${check_new_version}" ]]; then

    echo "[INFO] ShellBot API - Getting the newest version '${check_new_version}'"
    git clone ${API_GIT_URL} ${tmp_folder} > /dev/null

    echo "[INFO] Providing the API for the bot's project folder"
    cp ${tmp_folder}/ShellBot.sh ${BASEDIR}/
    rm -fr ${tmp_folder}

  else
    echo "[INFO] ShellBot API version is the same as in the local repository (version: '${current_version}')"
  fi
}

helper.random() {
	#helper.random "1000"		<---- will return a random between 1 and 1000
  #helper.random "file.txt"	<---- will return a random based on the number of lines from the given file
  #helper.random			<---- without passing parameter, means to return a random file name for any usage
  local var reg amount random_number
	
	var=$1
	reg='^[0-9]+$'

	if [[ ! $var =~ $re ]] || [[ -f $var ]]; then
   	amount=$(cat ${var} | wc -l)
		random_number=$(shuf -i 1-${amount} -n 1)
	elif [[ $var =~ $re ]] && [[ ! -z $var ]]; then
		random_number=$(shuf -i 1-${var} -n 1)
	fi
	
	if [[ -z $var ]]; then
		random_number=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 16 | head -n 1)
	fi

	echo "${random_number}"
}

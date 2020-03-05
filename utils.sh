#!/bin/bash

# Script que carrega as configurações iniciais do bot

################################# START - Carregando todas as funções #################################
test -f ${BASEDIR}/.definitions.sh && source ${BASEDIR}/.definitions.sh

function_list=($(find ${BASEDIR}/functions -name "*.sh"))
for f in ${function_list[@]}; do
    source ${f}
done
################################# END - Carregando todas as funções #################################

# Saber se tem o telegram token e ao menos um id de adminitrador exportado como variável de ambiente do sistema
# Essas variáveis devem ser setadas no arquivo .definitions.sh
helper.validate_vars TELEGRAM_TOKEN NOTIFICATION_IDS

helper.get_api
exitOnError "Erro ao tentar baixar API ShellBot" $?

# Fazer source da API só depois de baixá-la
source ${BASEDIR}/configurations/keyboards.sh

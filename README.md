# telegram-bot-mercado
Vai fazer a compra da casa? faça sua lista do mercado e leve o bot com você.

### Como testar ?
- Tenha em mãos o token do seu bot [veja aqui](https://core.telegram.org/bots#6-botfather)

### Inicie o bot em 3 passos
1 - Clone o repositório em seu ambiente linux:
```shell
$ git clone https://github.com/dodopontocom/telegram-bot-mercado.git && cd telegram-bot-mercado
```
2 - Adicione o token e mais algumas informações no arquivo de definições executando o comando abaixo:  
**`Não se esqueça de substituir o TOKEN!!!`**
```shell
$ cat << EOF > .definitions.sh
#!/bin/bash

export TELEGRAM_TOKEN="<TELEGRAM_TOKEN_AQUI>"
export API_GIT_URL="https://github.com/shellscriptx/shellbot.git"
export API_VERSION_RAW_URL="https://raw.githubusercontent.com/shellscriptx/shellbot/master/ShellBot.sh"
export TENDA_SUP_URL="https://www.tendaatacado.com.br"
EOF
```
3 - Execute o bot
```shell
$ chmod +x ./bot.sh && ./bot.sh
```

Agora é só enviar os itens para o seu bot...

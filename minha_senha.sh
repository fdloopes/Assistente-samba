#!/bin/bash
SENHA=""
SENHA=$(dialog --stdout --clear --insecure \
--title "Pressione ESC 3 vezes para sair!" --backtitle "Você tem 3 tentativas para digitar a senha!" --passwordbox "Senha do ROOT:" 10 40 )
op=$?
if [ $op == 0 ]
then
echo $SENHA
else
return
exit
fi

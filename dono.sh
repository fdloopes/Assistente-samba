#!/bin/bash

export SUDO_ASKPASS="/home/felipe/tcc/minha_senha.sh"


Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

Menu() {
caminho=$(dialog --stdout --extra-button --extra-label "Dono/Grupo" \
--ok-label "Navegar" \
--help-button --help-label "Voltar" \
--no-cancel \
--menu "$local: " 65 65 65 .. '' \
	$(for i in $(ls); do\
	test -d $i && echo $i Diretorio
	test -f $i && echo $i Arquivo ;\

done ) )
op=$? # recebe botão pressionado

}

Navegar() {

test -d $caminho && cd $caminho 

}


Dono() {
caminho=$(dialog --stdout --backtitle "Alterar Dono" --menu "Escolha o arquivo" 60 60 60 \
$(for i in $(ls -l); do\
	if test -O $i
	then
	test -O $i && echo $i && echo $USERNAME
	else 
	test -f $i && echo $i && echo "other"
	test -d $i && echo $i && echo "other"
fi 
done ))
op=$?

if [ $op -eq 255 ]
then
return
fi

if [ $op -eq 1 ]
then
return
fi


user=$(dialog --stdout --inputbox "Digite o nome do novo Dono" 8 40 )
op=$?
if [ $op == 0 ]
then
if chown $user $caminho
then
	chown $user $caminho
	Mensagem "Operacao realizada com sucesso"
 	else
	Mensagem "Sem permissao para realizar esta operacao"

	dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?

	if [ $op -eq 255 ]
	then
	return
	fi

	if [ $op -eq 0 ]
	then
	if sudo -k -A chown $user $caminho
	then
		sudo -k -A chown $user $caminho
		Mensagem "Operacao realizada com sucesso"
	else
		Mensagem "Operacao não realizada"


	fi
   fi

fi
fi
}

Grupo() {
caminho=$(dialog --stdout --backtitle "Alterar Grupo" --menu "Escolha o arquivo" 40 40 40 \
$(for i in $(ls -l); do\
	if test -G $i
	then
	test -G $i && echo $i && echo $USERNAME
	else 
	test -f $i && echo $i && echo "other"
	test -d $i && echo $i && echo "other"
fi 
done ))

if [ $op -eq 255 ]
then
return
fi

if [ $op -eq 1 ]
then
return
fi

group=$(dialog --stdout --inputbox "Digite o nome do novo Grupo" 8 40 )
op=$?
if [ $op == 0 ]
then
if chgrp $group $caminho
then
	chgrp $group $caminho
	Mensagem "Operacao realizada com sucesso"
 	else
	Mensagem "Sem permissao para realizar esta operacao"

	dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?

	if [ $op -eq 0 ]
	then
	if sudo -k -A chgrp $group $caminho
	then
		sudo -k -A chgrp $group $caminho
		Mensagem "Operacao realizada com sucesso"
	else
		Mensagem "Operacao não realizada"


	fi
   fi

fi
fi
}

MenuDono(){
opcao=$(dialog --stdout --backtitle "Dono do Arquivo" --menu "Faca sua escolha" 12 28 28 \
	1 "Alterar Dono" \
	2 "Alterar Grupo" \
	0 "Voltar" )

test -z $opcao && opcao=0

CaseDono
}

CaseDono() {
case $opcao in
	1) Dono
	;;
	2) Grupo
	;;
	0) return
	;;
esac
}


Principal() {

op=1

while [ $op != 255 ]
do
local=$(pwd)
Menu

case $op in
	
	3) MenuDono
	;;
	2) 
	clear
	exit
	clear
	;;
	0) Navegar
	;;
	255)
	clear
	exit
	clear

esac
done

}

Principal
clear

#!/bin/bash

export SUDO_ASKPASS="$PWD/minha_senha.sh"


Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

Menu() {
caminho=$(dialog --stdout --backtitle "Navegue entre os diretorios" --extra-button --extra-label "Excluir" \
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

MenuExcluir() {
opcao=$(dialog --stdout --backtitle "Menu Excluir" --menu "Escolha uma opcao" 12 28 28 \
	1 "Excluir Arquivo" \
	2 "Excluir Diretorio" \
	0 "Voltar")

test -z $opcao && opcao=0

CaseExcluir
}

Arquivo() {
arquivo=$(dialog --stdout --backtitle "Excluir Arquivo" --menu "Escolha o arquivo" 40 40 40 \
$(for i in $(ls); do \
	test -f $i && echo $i "Arquivo"

done ))

if rm $arquivo
then
	rm $arquivo
	Mensagem "Operacao realizada com sucesso"
else
	Mensagem "Sem permissao para executar"

	dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46

	op=$?
	if [ $op -eq 255 ]
	then
	return
	fi
	
	if [ $op -eq 0 ]
	then
	if sudo -k -A rm  $arquivo
	then
		sudo -k -A rm $arquivo
		Mensagem "Arquivo excluido com sucesso!"
	else
		Mensagem "Arquivo nao excluido!"
	
        fi
     fi
  fi

}

Diretorio() {
diretorio=$(dialog --stdout --backtitle "Excluir Diretorio" --menu "Escolha o diretorio" 40 40 40 \
$(for i in $(ls); do \
	test -d $i && echo $i "Diretorio"

done ))

if rm -rf $diretorio
then
	rm -r $diretorio
	Mensagem "Diretorio excluido com sucesso"
else
	Mensagem "Sem permissao para executar"

	dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46

	op=$?
	if [ $op -eq 255 ]
	then
	return
	fi
	
	if [ $op -eq 0 ]
	then
	if sudo -k -A rm -r $diretorio
	then
		sudo -k -A rm -r $diretorio
		Mensagem "Diretorio excluido com sucesso!"
	else
		Mensagem "Diretorio não excluido!"
	
        fi
     fi
  fi

}

CaseExcluir() {
case $opcao in
	1) Arquivo
	;;
	2) Diretorio
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
	
	3) MenuExcluir
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

#!/bin/bash

export SUDO_ASKPASS="/home/felipe/tcc/minha_senha.sh"


Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

Menu() {
caminho=$(dialog --stdout --extra-button --extra-label "Permissao" \
--ok-label "Navegar" \
--help-button --help-label "Voltar" \
--no-cancel \
--menu "$local: " 65 65 65 .. '' \
	$(for i in $(ls); do\
	test -d $i && echo $i Diretorio
	test -f $i && echo $i Arquivo ;\

done ) )
op=$? # recebe botão pressionado
OP=$?
}

Navegar() {

test -d $caminho && cd $caminho 

}

Permissao() {

re=$(test -r "$caminho" && echo on || echo off)
wr=$(test -w "$caminho" && echo on || echo off)
ex=$(test -x "$caminho" && echo on || echo off)


perm=$(dialog --stdout --no-cancel --extra-button --extra-label "Voltar" --checklist 'Permissoes: ' 0 0 0 \
r  '' "$re" \
w  '' "$wr" \
x  '' "$ex" )

op=$?

perm=$( echo $perm | tr -d "\"" | tr -d " ")


if [ $op -eq 255 ]
then
return
fi

if [ $op -eq 3 ]
then
return
fi

if chmod 000 $caminho
then 

	if chmod a+$perm $caminho
	then	
	Mensagem "Comando executado com sucesso."
	fi
else
	clear
	Mensagem "Sem permissao para executar esta operacao:"
	
	op1=$( dialog --stdout --title "Pergunta:" --yesno "Dejesa executar este comando como root?" 6 40 )
	op=$?
	if [ $op -eq 0 ]; then 
	if sudo -k -A chmod 000 $caminho
	then
		sudo -k -A chmod a+$perm $caminho
		Mensagem "comando executado com sucesso."
		
	else
		Mensagem "Sem permissao para executar esta operacao!"
		
	fi
    fi

fi

}

Principal() {

op=1

while [ $op != 255 ]
do
local=$(pwd)
Menu

case $op in
	
	0) Navegar
	;;
	2) 
	clear
	exit
	clear
	;;
	3) Permissao
	;;
	255)
	clear
	exit
	clear
	;;

esac
done

}

Principal
clear

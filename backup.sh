#!/bin/bash

export SUDO_ASKPASS="/home/kiko/tcc/minha_senha.sh"


Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

Menu() {
caminho=$(dialog --stdout --extra-button --extra-label "Backup/Restaurar" \
--ok-label "Navegar" \
--help-button --help-label "Voltar" \
--no-cancel \
--menu "$local: " 65 65 65 .. '' \
	$(for i in $(ls); do\
	test -d $i && echo $i Diretorio
	test -f $i && echo $i Arquivo ;\

done ) )
op=$? # recebe botão pressionado
nomebackup=$( echo $caminho | tr -d "HELP" )

}

Navegar() {

test -d $caminho && cd $caminho 

}

Menubackup() {

opcao1=$(dialog --stdout --backtitle "Backup" --menu "Faça sua escolha" 10 20 20 \
	1 "Backup" \
	2 "Restaurar"\
	0 "Voltar" )

test -z $opcao1 && opcao=0

Casebackup
}

Casebackup() {
case $opcao1 in
	1) Backup
	;;
	2) Restaurar
	;;
	0) return
	;;
esac
}

Backup() {

nome=$( dialog --stdout --inputbox "Digite o nome do Backup" 8 40 )
op=$?

if [ $op == 0 ]
then
tar -zcvf "$nome".tar.gz $nomebackup
Mensagem "Backup concluido com sucesso"
else
Mensagem "Backup nao realizado"
fi
}

Restaurar() {
nome=$( dialog --stdout --menu "Escolha o arquivo" 40 40 40 \
$(for i in $(ls *tar.gz); do \

test -d $i && echo $i "Diretorio"
test -f $i && echo $i "Arquivo"

done ))

destino=$( dialog --stdout --title "$local" --inputbox "Digite onde quer restaurar o backup" 8 45 )
op=$?


if [ $op == 0 ]
then
tar -zxvf "$nome" -C "$destino"
Mensagem "Backup restaurado com sucesso"
else
Mensagem "Backup nao restaurado"
fi

if [ $op == 0 ]
then
rm "$nome"
else
return
fi
}


Principal() {

op=1

while [ $op != 255 ]
do
local=$(pwd)
Menu

case $op in
	
	3) Menubackup
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

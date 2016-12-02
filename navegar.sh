#!/bin/bash

export SUDO_ASKPASS="$PWD/minha_senha.sh"


Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

Menu() {
caminho=$(dialog --stdout --extra-button --extra-label "Voltar" \
--ok-label "Navegar/Abrir" \
--no-cancel \
--menu "$local: " 65 65 65 .. '' \
	$(for i in $(dir); do\
	test -d $i && echo $i Diretorio
	test -f $i && echo $i Arquivo ;\

done ) )
op=$? # recebe botão pressionado
}

Navegar() {

test -d $caminho && cd $caminho 
if  test -f $caminho 

then

editar=$( dialog --stdout --editbox $caminho 120 120 )
opcao=$?

if [ $opcao -eq 0 ]

then

echo "$editar" > "$caminho" 
Mensagem "Arquivo salvo com sucesso"
else
Mensagem "Arquivo nao salvo"

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
	3) 
	   clear
           return
	   clear
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


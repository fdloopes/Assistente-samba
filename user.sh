#!/bin/bash

export SUDO_ASKPASS="$PWD/minha_senha.sh"

Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}


AdicionarUser(){

USERNAME=$(dialog --stdout --backtitle "Criar usuario" --inputbox "Digite o nome do novo usuário " 7 40 )

SENHA1=$(dialog --stdout --passwordbox "Digite a senha" 7 40 )
SENHA2=$(dialog --stdout --passwordbox "Digite a senha novamente" 7 40 )

if [ $SENHA1 = $SENHA2 ]
then
dialog --yesno "confirma a criação do usuario $USERNAME ?" 7 45
op=$?
case $op in
0)
if useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME
then
#passwd $USERNAME --> esse comando abaixo substitiu o comando passwd e faz com que o script fique 100% dentro do dialog. Não mostra a mensagem para adicionar novamente a senha do usuario criado.!!
echo "$USERNAME:$SENHA1" | chpasswd
Mensagem "Usuario criado com sucesso!"
else
Mensagem "Voce não tem permissão para criar usuarios!"
dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME
	echo "$USERNAME:$SENHA1" | chpasswd
	Mensagem "Usuario criado com sucesso!"
	else
	Mensagem "Usuario não criado!"	
	fi
fi
;;
esac
else
Mensagem "As senhas são diferentes !"
fi
}

ListarUser(){

cat /etc/passwd | cut -d: -f1 | nl > /tmp/.usuario_lista
dialog --backtitle "Lista Usuarios" --textbox /tmp/.usuario_lista 0 0

}

RemoverUser(){

DELUSER=$(dialog --stdout --backtitle "Remover Usuario" --inputbox "Digite o nome do usuario a ser excluido" 7 50)
dialog --title "Pergunta:" --yesno "Deseja excluir a home de $DELUSER" 6 46
op=$?
 
if [ $op -eq 0 ]
then
if userdel -r $DELUSER
then
Mensagem "O usuario e sua home foram excluidos com sucesso!"
else
Mensagem "Voce não tem permissão para excluir usuarios!"
dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A userdel -r $DELUSER
	Mensagem "O usuario e sua home foram excluidos com sucesso!"
	else
	Mensagem "Usuario não excluido ou inexistente!"
	fi
fi
else
if userdel $DELUSER
then
Mensagem "O usuario foi excluido com sucesso!"
else
Mensagem "Voce não tem permissão para excluir usuarios!"
dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A userdel $DELUSER
	Mensagem "Usuario excluido com sucesso!"
	else
	Mensagem "Usuario não excluido ou inexistente!"
	fi

fi
fi
}


Criar (){
GROUPNAME=$(dialog --stdout --backtitle "Criar novo Grupo" --inputbox "Digite o nome do novo grupo" 7 40 )

op=$?

if [ $op = 0 ]
then
dialog --yesno "confirma a criação do grupo $GROUPNAME ?" 7 45
op=$?

if [ $op = 0 ]
then
if addgroup --quiet $GROUPNAME
then
Mensagem "Grupo criado com sucesso!"
else
Mensagem "Voce não tem permissão para criar grupos"
dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A addgroup --quiet $GROUPNAME
	Mensagem "Grupo criado com sucesso!"
	else
	Mensagem "Grupo não criado ou já existe!"
	fi

fi
else
Mensagem "Grupo não criado!"
fi
else
Mensagem "Grupo não criado!"
fi
}
 
ListarGroup(){

cat /etc/group | cut -d: -f1 | nl > /tmp/.grupo_lista
chmod 777 /tmp/.grupo_lista
dialog --backtitle "Lista Grupos" --textbox /tmp/.grupo_lista 0 0
}

RemoverGroup(){

DELGROUP=$(dialog --stdout --backtitle "Remover grupo" --inputbox "Digite o nome do Grupo a ser excluido" 7 50)
dialog --title "Pergunta:" --yesno "Deseja realmente excluir o Grupo $DELGROUP" 6 46
op=$?
 
if [ $op -eq 0 ]
then
if delgroup --quiet $DELGROUP
then
Mensagem "O Grupo foi excluido com sucesso!"
else
Mensagem "Voce não tem permissao para excluir Grupos!"
dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A delgroup --quiet $DELGROUP
	Mensagem "O Grupo foi excluido com sucesso!"
	else
	Mensagem "Grupo nao excluido!"
	fi
fi
else
Mensagem "Grupo não excluido!"
fi
}

AdicionarGroup() {
USERADD=$(dialog --stdout --backtitle "Adicionar Usuario ao grupo" --inputbox "Digite o nome do usuario a ser adicionado" 7 50)
GROUPADD=$(dialog --stdout --backtitle "Adicionar Usuario ao grupo" --inputbox "Digite o nome do grupo para adicionar o usuario" 7 55)
dialog --title "Pergunta:" --yesno "Deseja realmente adicionar $USERADD ao grupo $GROUPADD" 5 54
op=$?

if [ $op = 0 ]
then
if gpasswd -a $USERADD $GROUPADD
then
Mensagem "Usuario adicionado com sucesso!"
else
dialog --title "Aviso" --msgbox "Voce não tem permissao para adicionar o usuario ao grupo!" 6 63
dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A gpasswd -a $USERADD $GROUPADD
	Mensagem "Usuario adicionado com sucesso!"
	else
	Mensagem "Usuario nao adicionado!"
	fi
fi
else
Mensagem "Usuario nao adicionado!"
fi
}

ListarGroupUser(){
cat /etc/group | cut -d: -f1,4 | tr ':' '=' > /tmp/.lista_GroupUser
chmod 777 /tmp/.lista_GroupUser
dialog --backtitle "Lista a quais grupos cada usuario pertence" --textbox /tmp/.lista_GroupUser 0 0
}

Menu(){
opcao=$(dialog --stdout --backtitle "Gestão de Usuarios e Grupos" --menu "Faca sua escolha" 12 28 28 \
	1 "Usuario" \
	2 "Grupo" \
	0 "Voltar" )

test -z $opcao && opcao=0

}

MenuUsuario() {
opcao=$(dialog --stdout --backtitle "Menu Usuario" --menu "Faca sua escolha" 12 28 28 \
	1 "Adicionar" \
	2 "Listar" \
	3 "Remover" \
	0 "Voltar")

test -z $opcao && opcao=0

CaseMenuUsuario
}


CaseMenuUsuario() {
case $opcao in
	1) AdicionarUser
	;;
	2) ListarUser
	;;
	3) RemoverUser
	;;
	0) return
	;;
esac
}

MenuGrupo() {
opcao=$(dialog --stdout --backtitle "Menu Grupo" --menu "Faca sua escolha" 12 28 28 \
	1 "Criar" \
	2 "Listar" \
	3 "Remover" \
	4 "Adicionar" \
	5 "Listar grupo/usuario" \
	0 "Voltar")

test -z $opcao && opcao=0

CaseMenuGrupo
}

CaseMenuGrupo() {
case $opcao in
	1) Criar
	;;
	2) ListarGroup
	;;
	3) RemoverGroup
	;;
	4) AdicionarGroup
	;;
	5) ListarGroupUser
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

case $opcao in
	
	1)clear
	MenuUsuario
	;;
	2)clear
	MenuGrupo
	;;
	0) clear
	exit
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


#!/bin/bash

export SUDO_ASKPASS="$PWD/minha_senha.sh"


Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

TesteDialog(){
clear
if (dialog &> /dev/null)
	then
	echo " "
else
	echo "O dialog nao esta instalado!"
	sleep 2
	clear
	echo "Deseja instalar o dialog?"
	echo "Digite 1 para sim"
	echo "Digite 2 para nao"
	read op
	while [ $op -lt 1 -o $op -gt 2 ]
	do
	clear
	echo "Opcao inválida! Tente novamente!"
	sleep 2	
	clear
	echo "Deseja instalar o dialog?"
	echo "Digite 1 para sim"
	echo "Digite 2 para nao"
	read op
	done	 
		if [ $op -eq 2 ]
		then
		clear
		echo "Dialog não instalado!"
		sleep 2	
		clear
		exit
		fi
		
		if [ $op -eq 1 ]
		then
			if ( apt-get install dialog )
			then
			apt-get install dialog
			Mensagem "Dialog instalado com sucesso!"
			else
			clear
			echo "Voce nao tem permissao para executar a instalacao do dialog!"
			sleep 2
			clear
			echo "Deseja instalar o dialog como root?"
			echo "Digite 1 para sim"
			echo "Digite 2 para nao"
			read op
			while [ $op -lt 1 -o $op -gt 2 ]
			do
				clear
				echo "Opcao inválida! Tente novamente!"
				sleep 2	
				clear
				echo "Deseja instalar o dialog como root?"
				echo "Digite 1 para sim"
				echo "Digite 2 para nao"
				read op
			done
					if [ $op -eq 2 ]
					then
						clear
						echo "Dialog não instalado!"
						sleep 2
						clear				
						exit					
					fi
			
	if [ $op -eq 1 ]
	then
		if sudo apt-get install dialog
		then
		Mensagem "Dialog instalado com sucesso!"
		else
		echo "Dialog nao instalado!"
		fi
	clear
	else
	clear
	exit
	fi
			
			fi
		fi	

fi
}


Barra(){
dialog --title "   AGUARDE.." --backtitle "$(date) - Felipe Lopes" --gauge '\n  CARREGANDO SISTEMA .' 8 40 $1
}

MenuTeste(){

SemNave=Nada
SemPerm=Nada
SemBack=Nada
SemExc=Nada
SemDon=Nada
SemUs=Nada
SemPost=Nada
SemSmb=Nada

n=0
echo 0 | Barra
test -e navegar.sh && n=$(expr $n + 1) && nave=Navegar || SemNave=Navegar && nave=Navegar
echo 10 | Barra 
test -e permissao.sh && n=$(expr $n + 1) && perm=Permissao || SemPerm=Permissao && perm=Permissao #&& test -e navegar.sh || nave=Backup and perm=Excluir
echo 20 | Barra
test -e backup.sh && n=$(expr $n + 1) && back=Backup || SemBack=Backup && back=Backup
echo 30 | Barra
test -e excluir.sh && n=$(expr $n + 1) && exc=Excluir || SemExc=Excluir && exc=Excluir
echo 40 | Barra
test -e dono.sh && n=$(expr $n + 1) && don=Dono/Grupos || SemDon=Dono/Grupos && don=Dono/Grupos
echo 55 | Barra
test -e user.sh && n=$(expr $n + 1) && us=Usuarios/Grupos || SemUs=Usuarios/Grupos && us=Usuarios/Grupos
echo 67 | Barra
# Teste do arquivo de configuração do postgresql, não totalmente implementado ainda
#test -e banco.sh && n=$(expr $n + 1) && post=Postgres || SemPost=Postgres && post=Postgres
echo 73 | Barra
test -e smb.sh && n=$(expr $n + 1) && smb=Samba || SemSmb=Samba && smb=Samba
echo 100 | Barra


#nave=Navegar 
#perm=Permissao 
#back=Backup
#exc=Excluir 
#don=Dono/Grupos
#us=Usuarios/Grupos
#post=Postgres
#smb=Samba
}


MenuPrincipal() {
opcao1=$(dialog --stdout --no-cancel --backtitle "Menu Principal" --menu "Faca sua escolha" 16 25 25 \
        1 "Tarefas Basicas" \
	2 "Servicos de Redes" \
	0 "Sair" )

if [ $opcao1 -eq 0 ]
then
clear
exit
fi
#CaseMenuPrincipal
}

MenuBasica(){
opcao=$(dialog --stdout --no-cancel --backtitle "Menu Tarefas Basicas" --menu "Faca sua escolha" 16 25 25 \
        1 "$nave" \
	2 "$perm" \
	3 "$back" \
	4 "$exc" \
	5 "$don" \
	6 "$us" \
	0 "Voltar" )


op=$?

}


MenuRedes(){
opcao=$(dialog --stdout --no-cancel --backtitle "Menu Tarefas Basicas" --menu "Faca sua escolha" 16 25 25 \
	1 "$smb" \
	0 "Voltar" )


op=$?

case $opcao in
1)
opcao=7
;;
0)
return
;;
esac

}


Principal() {

TesteDialog

opcao=1

while [ $opcao != 0 ]
do
MenuTeste

opcao1=1
opcao=0

while [ $opcao -eq 0 ]
do

if [ $opcao -eq 0 ]
then
MenuPrincipal
fi

if [ $opcao1 -eq 1 ]
then
MenuBasica
fi
if [ $opcao1 -eq 2 ]
then
MenuRedes
fi
done

case $opcao in
	
	1)clear
	if [ $SemNave = $nave ]
	then 
	Mensagem "O Script de Navegacao não encontrado!"
	else
	"$PWD/navegar.sh"
	fi	
	;;
	2)clear
	if [ $SemPerm = $perm ]
	then 
	Mensagem "O Script de Permissao não encontrado!"
	else
	"$PWD/permissao.sh"
	fi	
	;;
	3)clear
	if [ $SemBack = $back ]
	then 
	Mensagem "O Script de Backup não encontrado!"
	else
	"$PWD/backup.sh"
	fi	
	;;
	4)clear
	if [ $SemExc = $exc ]
	then 
	Mensagem "O Script de Exclusao não encontrado!"
	else	
	"$PWD/excluir.sh"
	fi	
	;;
	5)clear
	if [ $SemDon = $don ]
	then 
	Mensagem "O Script de alterar donos não encontrado!"
	else
	Mensagem "Esta operacao so pode ser executada por root"
	dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A "$PWD/dono.sh"
	fi
	fi	
	;;
	6)clear
	if [ $SemUs = $us ]
	then 
	Mensagem "O Script de usuarios não encontrado!"
	else
	"$PWD/user.sh"
	fi	
	;;
	7) clear
	if [ $SemSmb = $smb ]
	then 
	Mensagem "O Script de configuracao do samba não encontrado!"
	else
	Mensagem "O menu Samba so pode ser executado por root"
	dialog --title "Pergunta:" --yesno "Deseja executar o menu Samba como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A "$PWD/smb.sh"
	fi
	fi
	;; 
	8) clear
	# CASE DO POSTGRESQL, ainda não totalmente implementado
	if [ $SemPost = $post ]
	then 
	Mensagem "O Script de configuraco do postgres não encontrado!"
	else
	Mensagem "Esta operacao so pode ser executada por root"
	dialog --title "Pergunta:" --yesno "Deseja executar esta operacao como root?" 6 46
	op=$?
	if [ $op = 0 ]
	then
	sudo -k -A "$PWD/banco.sh"
	fi
	fi	
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

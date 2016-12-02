#!/bin/bash

export SUDO_ASKPASS="$PWD/minha_senha.sh"

postgress="/etc/postgresql/9.1/main"

Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

TestePostgres(){
clear
dialog --title "   AGUARDE.." --infobox '\n  TESTANDO DEPENDENCIAS!' 5 30

	if ( sudo -k -A psql -U postgres --quiet -c "CREATE DATABASE teste" >> tmp.tmp &> /dev/null )
	then
	echo " "
	psql -U postgres --quiet -c "DROP DATABASE teste" >> tmp.tmp
	else
	Mensagem "O Postgres nao esta instalado!"
	dialog --title "Pergunta:" --yesno "Deseja instalar o postgres?" 6 46
	op=$?

	test -z $op && op = 1

		if [ $op -eq 0 ]
		then
		dialog --title "   AGUARDE.." --infobox '\n  ISTO SO VAI LEVAR ALGUNS MINUTOS' 5 40
		
			if ( apt-get -qy install postgresql > tmp.tmp )
			then
			dialog --title "   AGUARDE.." --infobox '\n  TERMINANDO INSTALACAO' 5 30
			sleep 2
			Mensagem "Postgres instalado com sucesso!"
			else
			clear
		        Mensagem "Voce nao tem permissao para executar a instalacao do postgres!"
			dialog --title "Pergunta:" --yesno "Deseja instalar o postgres como root?" 6 46
			op=$?
		
			test -z $op && op = 1
	
		if [ $op -eq 0 ]
		then
		if sudo apt-get -qy install postgresql > tmp.tmp
		then
		Mensagem "Postgres instalado com sucesso!"
		else
		echo "postgres nao instalado!"
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

Menu(){
opcao=$(dialog --stdout --no-cancel --backtitle "Menu Postgres" --menu "Faca sua escolha" 15 25 25 \
        1 "Editar" \
	2 "Autenticacao" \
	3 "Iniciar/Parar" \
	0 "Voltar" )

test -z $opcao && opcao=0

}


MenuServico(){
opcao=$(dialog --stdout --no-cancel --backtitle "Menu Servico" --menu "Faca sua escolha" 15 25 25 \
        1 "Iniciar" \
	2 "Reiniciar" \
	3 "Parar" \
	0 "voltar" )

test -z $opcao && opcao=0
CaseMenuServico
}

CaseMenuServico() {
case $opcao in
	1) iniciar
	;;
	2) restart
	;;
	3) parar
	;;
	0) return
	;;
esac
}

listar(){
cat "$postgress/pg_hba.conf" | grep -v "^#" > post.tmp	
editar=$( dialog --stdout --editbox "post.tmp" 120 120 )
opcao=$?
clear
if [ $opcao -eq 0 ]
then
echo "$editar" > post.tmp 
Mensagem "Arquivo salvo com sucesso"
return
else
Mensagem "Arquivo nao salvo"
return
fi
}

autenticar() {
aut="trust"
cat "$postgress/pg_hba.conf" | grep -v "^#" > post.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Pg_hba.conf" --textbox "post.tmp" 0 0
primeira="local   all             all                                     "
segunda="host    all             all             127.0.0.1/32            "
terceira="host    all             all             ::1/128                 "
n1="# "local" is for Unix domain socket connections only"
n2="# IPv4 local connections:"
n3="# IPv6 local connections:"
aut=$(dialog --stdout --backtitle "Adicionar novas regras" --inputbox "Informe o nivel de autenticacao Local" 7 50)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $n1 > post.tmp
echo $primeira $aut >> post.tmp
echo $n2 >> post.tmp
aut=$(dialog --stdout --backtitle "Adicionar novas regras" --inputbox "Informe o nivel de autenticacao das outras redes" 7 60)
if [ $op -eq 1 ]
then
return
fi
echo $segunda $aut >> post.tmp
echo $n3 >> post.tmp
echo $terceira $aut >> post.tmp
n4="# Allow replication connections from localhost, by a user with the replication privilege."
n5="#local   replication     postgres                                trust"
n6="#host    replication     postgres        127.0.0.1/32            trust"
n7="#host    replication     postgres        ::1/128                 trust"
echo $n4 >> post.tmp
echo $n5 >> post.tmp
echo $n6 >> post.tmp
echo $n7 >> post.tmp
cat post.tmp > "$postgress/pg_hba.conf"
sleep 4
dialog --title "Configuracao Atual" --backtitle "Configuração Pg_hba.conf" --textbox "$postgress/pg_hba.conf" 0 0
}

iniciar(){
if (service postgresql start &> /dev/null)
then
Mensagem "Servico iniciado com sucesso!"
else
Mensagem "Servico nao iniciado!"
fi
}

parar(){
if (service postgresql stop &> /dev/null)
then
Mensagem "Servico parado com sucesso!"
else
Mensagem "Impossivel parar o servico!"
fi
}

restart(){
if (service postgresql restart &> /dev/null)
then
Mensagem "Servico reiniciado com sucesso!"
else
Mensagem "Servico nao reiniciado!"
fi
}

Principal() {
opcao=1
clear
TestePostgres

while [ $opcao != 0 ]
do

Menu

case $opcao in
	
	1) clear 
	listar 
	;;
	2) clear
	autenticar
	;; 
	3) clear
	MenuServico
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
rm -rf post.tmp
rm -rf tmp.tmp
clear

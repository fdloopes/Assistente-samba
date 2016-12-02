#!/bin/bash

export SUDO_ASKPASS="$PWD/minha_senha.sh"

caminho="/etc/samba"

Mensagem() {
  dialog --title "Mensagem" --msgbox "$1" 6 50
}

TesteSamba(){
clear
dialog --title "   AGUARDE.." --infobox '\n  TESTANDO DEPENDENCIAS!' 5 30
sleep 2 
	if ( service smbd restart &> /dev/null )
	then
	echo " "
	else
	Mensagem "O Samba nao esta instalado!"
	dialog --title "Pergunta:" --yesno "Deseja instalar o samba?" 6 46
	op=$?

	test -z $op && op = 1

		if [ $op -eq 0 ]
		then
		dialog --title "   AGUARDE.." --infobox '\n  ISTO SO VAI LEVAR ALGUNS MINUTOS' 5 40
		sleep 2
			if ( apt-get -qy install samba &> /dev/null )
			then
			dialog --title "   AGUARDE.." --infobox '\n  TERMINANDO INSTALACAO' 5 30
			sleep 2
			Mensagem "Samba instalado com sucesso!"
			else
			clear
		        Mensagem "Voce nao tem permissao para executar a instalacao do samba!"
			dialog --title "Pergunta:" --yesno "Deseja instalar o samba como root?" 6 46
			op=$?
		
			test -z $op && op = 1
	
		if [ $op -eq 0 ]
		then
		if sudo -k -A apt-get -qy install samba &> /dev/null
		then
		Mensagem "Samba instalado com sucesso!"
		else
		echo "Samba nao instalado!"
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
opcao=$(dialog --stdout --no-cancel --backtitle "Menu Samba" --menu "Faca sua escolha" 14 32 32 \
        1 "Edicao Manual" \
	2 "Modos de Configuracao" \
	3 "Gerencia Usuarios" \
	4 "Iniciar/Parar" \
	0 "Voltar" )

test -z $opcao && opcao1=0

}

MenuConfiguracao(){
opcao1=$(dialog --stdout --no-cancel --backtitle "Menu Configuracao" --menu "Escolha um dos modos:" 11 25 25 \
        1 "Basica" \
	2 "Avancada" \
	0 "Voltar" )

test -z $opcao1 && opcao1=0

CaseMenuConfiguracao
}

CaseMenuConfiguracao() {
case $opcao1 in
	1) MenuBasica
	;;
	2) MenuAvancada
	;;
	0) return
	;; 
esac
}

MenuUsuario(){
opcao1=$(dialog --stdout --no-cancel --backtitle "Menu Usuario" --menu "Escolha uma das opcoes:" 14 35 35 \
        1 "Adicionar usuario c/shell" \
	2 "Adicionar usuario s/shell" \
	3 "Listar usuarios samba" \
	4 "Alterar senha usuario" \
	5 "Alterar senha root" \
	6 "Remover usuario" \
	0 "Voltar" )


CaseMenuUsuario
}

CaseMenuUsuario() {
case $opcao1 in
	1) ComLogin
	;;
	2) SemLogin
	;;
	3) Listar
	;;
	4) Alterar
	;;
	5) SenhaRoot
	;;
	6) Remover
	;;
	0) return
	;;
esac
}

MenuBasica(){
opcao1=$(dialog --stdout --no-cancel --backtitle "Menu Configuracao" --menu "Escolha uma secao:" 11 25 25 \
        1 "Global" \
	2 "Compatilhamento" \
	0 "Voltar" )


CaseMenuBasica
}

CaseMenuBasica() {
case $opcao1 in
	1) global
	;;
	2) compartilhamento
	;;
	0) return
	;;
esac
}

MenuAvancada(){
opcao1=$(dialog --stdout --no-cancel --backtitle "Menu Configuracao" --menu "Escolha uma secao:" 13 25 25 \
        1 "Global" \
	2 "Profiles" \
	3 "NetLogon" \
	4 "Home" \
	5 "Compartilhamento" \
	0 "Voltar" )

CaseMenuAvancada
}

CaseMenuAvancada() {
case $opcao1 in
	1) globalAvancado
	;;
	2) profilesAvancado
	;;	
	3) netlogonAvancado
	;;
	4) homeAvancado
	;; 	
	5) compartilhamentoAvancado
	;;
	0) return
	;;
esac
}




MenuServico(){
opcao1=$(dialog --stdout --no-cancel --backtitle "Menu Servico" --menu "Faca sua escolha" 15 25 25 \
        1 "Iniciar" \
	2 "Reiniciar" \
	3 "Parar" \
	0 "voltar" )


CaseMenuServico
}

CaseMenuServico() {
case $opcao1 in
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

editar(){
cat "$caminho/smb.conf" > smb.tmp	
editar=$( dialog --stdout --editbox "smb.tmp" 120 120 )
opcao1=$?
clear
if [ $opcao1 -eq 0 ]
then
dialog --title "Pergunta:" --yesno "Voce tem certeza que quer salvar?" 6 46
op=$?
	if [ $op -eq 0 ]
	then
	cp $caminho/smb.conf $caminho/smb.confBACKUP
	echo "$editar" > smb.tmp
	cat smb.tmp > $caminho/smb.conf 
	Mensagem "Arquivo salvo com sucesso!"
	else
	Mensagem "Arquivo não salvo!"
	fi
else
Mensagem "Arquivo nao salvo!"
return
fi
}

SenhaRoot() {

SENHA1=$(dialog --stdout --backtitle "Digite a nova senha de root para o samba" --passwordbox "Informe a nova senha:" 8 40 )
op=$?
if [ $op -eq 1 ]
then
return
fi

SENHA2=$(dialog --stdout --backtitle "Digite a nova senha de root para o samba" --passwordbox "Informe a nova senha:" 8 40 )
op=$?
if [ $op -eq 1 ]
then
return
fi

	dialog --yesno "Deseja realmente alterar a senha do usuário root para o samba?" 7 45
	op=$?
case $op in
0)
	if [ $SENHA1 = $SENHA2 ]
	then
		if (echo $SENHA1; echo $SENHA1) | smbpasswd -s -a root &> /dev/null
		then
		Mensagem "Senha alterada com sucesso!"
		else
		Mensagem "Voce nao conseguiu alterar a senha de root!"
		fi	
	else	
	Mensagem "As senhas são diferentes !"
	fi	
;;
esac
}

ComLogin() {

USERNAME=$(dialog --stdout --backtitle "Adicionando usuarios" --inputbox "Informe o login do usuario:" 7 50)
op=$?
if [ $op -eq 1 ]
then
return
fi
SENHA1=$(dialog --stdout --passwordbox "Digite a senha" 8 40 )
op=$?
if [ $op -eq 1 ]
then
return
fi
SENHA2=$(dialog --stdout --passwordbox "Digite a senha novamente" 8 40 )
op=$?
if [ $op -eq 1 ]
then
return
fi

	dialog --yesno "Deseja que o usuario $USERNAME tenha acesso via SSH apenas ao assistente?" 7 45
	op=$?
case $op in
0)
		if [ $SENHA1 = $SENHA2 ]
		then
		dialog --yesno "confirma a criação do usuario $USERNAME ?" 7 45
		op=$?
		if [ $op -eq 0 ]
		then
		mkdir -p /home/$USERNAME		
		if ( cd /home/$USERNAME/tcc &> /dev/null )
		then
		cd $HOME/tcc
		else	
		cp -R $HOME/tcc /home/$USERNAME/
		fi
		if useradd -d /home/$USERNAME/tcc -s /usr/bin/assistente $USERNAME &> /dev/null
		then
		#passwd $USERNAME --> esse comando abaixo substitiu o comando passwd e faz com que o script fique 100% dentro do dialog. Não mostra a 			#mensagem para adicionar novamente a senha do usuario criado.!!
		echo "$USERNAME:$SENHA1" | chpasswd
		(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null	
		chown -R $USERNAME:$USERNAME /home/$USERNAME		
		if (cd /home/$USERNAME/profile.pds &> /dev/null)
		then
		cd $HOME/tcc
		else	
		mkdir -p /home/$USERNAME/profile.pds
		chown -R $USERNAME:$USERNAME /home/$USERNAME/profiles.pds	
		fi	
		Mensagem "Usuario criado com sucesso!"
		else
		Mensagem "Voce nao tem permissao para criar usuarios!"
		dialog --title "Pergunta:" --yesno "Deseja executar este comando como root?" 6 46
		op=$?
			
		if [ $op -eq 0 ]
		then
		mkdir -p /home/$USERNAME
		if (cd /home/$USERNAME/tcc &> /dev/null)
		then
		cd $HOME/tcc
		else	
		cp -R $HOME/tcc /home/$USERNAME/
		fi
			if sudo useradd -d /home/$USERNAME/tcc -s /usr/bin/assistente $USERNAME &> /dev/null
			then
			echo "$USERNAME:$SENHA1" | chpasswd
			(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null			
			chown -R $USERNAME:$USERNAME /home/$USERNAME			
			if (cd /home/$USERNAME/profile.pds &> /dev/null)
			then
			cd $HOME/tcc
			else	
			mkdir -p /home/$USERNAME/profile.pds
			chown -R $USERNAME:$USERNAME /home/$USERNAME/profiles.pds	
			fi	
			if (cd /home/$USERNAME/tcc &> /dev/null)
			then
			cd $HOME/tcc
			else	
			cp -R $HOME/tcc /home/$USERNAME/
			fi
			Mensagem "Usuario criado com sucesso!"
			else
			Mensagem "Usuario não criado!"
			fi	
		fi
		fi
		fi	
	else	
	Mensagem "As senhas são diferentes !"
	fi	
;;
1)	
	if [ $SENHA1 = $SENHA2 ]
	then
	dialog --yesno "confirma a criação do usuario $USERNAME ?" 7 45
	op=$?
	if [ $op -eq 0 ]
	then
	if useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME &> /dev/null
	then
	#passwd $USERNAME --> esse comando abaixo substitiu o comando passwd e faz com que o script fique 100% dentro do dialog. Não mostra a 		#mensagem para adicionar novamente a senha do usuario criado.!!
	echo "$USERNAME:$SENHA1" | chpasswd
	(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null	
	if (cd /home/$USERNAME/profile.pds &> /dev/null)
	then
	cd $HOME/tcc
	else	
	mkdir -p /home/$USERNAME/profile.pds
	chown -R $USERNAME:$USERNAME /home/$USERNAME/profiles.pds	
	fi	
	if (cd /home/$USERNAME/tcc &> /dev/null)
	then
	cd $HOME/tcc
	else	
	cp -R $HOME/tcc /home/$USERNAME/
	fi
	Mensagem "Usuario criado com sucesso!"
	else
	Mensagem "Voce nao tem permissao para criar usuarios!"
	dialog --title "Pergunta:" --yesno "Deseja executar este comando como root?" 6 46
	op=$?
		
	test -z $op && op = 1
	
		if [ $op -eq 0 ]
		then
			if sudo useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME &> /dev/null
			then
			echo "$USERNAME:$SENHA1" | chpasswd
			(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null			
			if (cd /home/$USERNAME/profile.pds &> /dev/null)
			then
			cd $HOME/tcc
			else	
			mkdir -p /home/$USERNAME/profile.pds
			chown -R $USERNAME:$USERNAME /home/$USERNAME/profiles.pds	
			fi	
			if (cd /home/$USERNAME/tcc &> /dev/null)
			then
			cd $HOME/tcc
			else	
			cp -R $HOME/tcc /home/$USERNAME/
			fi		
			Mensagem "Usuario criado com sucesso!"
			else
			Mensagem "Usuario não criado!"
			fi
		fi
	fi
	fi	
	else	

Mensagem "As senhas são diferentes !"
fi
;;	
esac	
	
}


SemLogin() {
USERNAME=$(dialog --stdout --backtitle "Adicionando usuarios" --inputbox "Informe o login do usuario:" 7 50)

SENHA1=$(dialog --stdout --passwordbox "Digite a senha" 8 40 )
SENHA2=$(dialog --stdout --passwordbox "Digite a senha novamente" 8 40 )

op=$?
if [ $op -eq 1 ]
then
return
fi

	if [ $SENHA1 = $SENHA2 ]
	then
	dialog --yesno "confirma a criação do usuario $USERNAME ?" 7 45
	op=$?
	case $op in
	0)
	if useradd -m -s /bin/false $USERNAME &> /dev/null
	then
	#passwd $USERNAME --> esse comando abaixo substitiu o comando passwd e faz com que o script fique 100% dentro do dialog. Não mostra a 		#mensagem para adicionar novamente a senha do usuario criado.!!
	echo "$USERNAME:$SENHA1" | chpasswd
	(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null	
	if (cd /home/$USERNAME/profile.pds &> /dev/null)
	then
	cd $HOME/tcc
	else	
	mkdir -p /home/$USERNAME/profile.pds
	chown -R $USERNAME:$USERNAME /home/$USERNAME/profiles.pds	
	fi	
	Mensagem "Usuario criado com sucesso!"
	else
	Mensagem "Voce nao tem permissao para criar usuarios!"
	dialog --title "Pergunta:" --yesno "Deseja executar este comando como root?" 6 46
	op=$?
		
	test -z $op && op = 1
	
		if [ $op -eq 0 ]
		then
			if sudo useradd -m -s /bin/false $USERNAME
			then
			echo "$USERNAME:$SENHA1" | chpasswd
			(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null			
			if (cd /home/$USERNAME/profile.pds)
			then
			cd $HOME/tcc
			else	
			mkdir -p /home/$USERNAME/profile.pds
			chown -R $USERNAME:$USERNAME /home/$USERNAME/profiles.pds	
			fi	
			Mensagem "Usuario criado com sucesso!"
			else
			Mensagem "Usuario não criado!"
			fi
		fi
	fi
	;;
	esac
	else
	Mensagem "As senhas são diferentes !"
fi
}


Alterar() {
USERNAME=$(dialog --stdout --backtitle "Alterar Senha" --inputbox "Informe o nome do usuario que deseja alterar a senha:" 8 62)

						
existe=`cat /etc/passwd | cut -d : -f 1 | grep ^$USERNAME$`

	if [ $existe ==NULL  ]; then

	Mensagem "Usuario $USERNAME nao existe!"
	return
	
	else

	SENHA1=$(dialog --stdout --passwordbox "Digite a senha" 7 40 )
	SENHA2=$(dialog --stdout --passwordbox "Digite a senha novamente" 7 40 )

        if [ $SENHA1 = $SENHA2 ]
	then
	dialog --yesno "confirma a alteracao da senha de $USERNAME ?" 7 45
	op=$?
	case $op in
	0)
	if usermod -p `echo $SENHA1` $USERNAME
	then
	#passwd $USERNAME --> esse comando abaixo substitiu o comando passwd e faz com que o script fique 100% dentro do dialog. Não mostra a 		#mensagem para adicionar novamente a senha do usuario criado.!!
	(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null	
	Mensagem "Senha alterada com sucesso!"
	else
	Mensagem "Voce nao tem permissao para alterar senhas!"
	dialog --title "Pergunta:" --yesno "Deseja executar este comando como root?" 6 46
	op=$?
		
	test -z $op && op = 1
	
		if [ $op -eq 0 ]
		then
			if sudo usermod -p `echo $SENHA1` $USERNAME
			then
			(echo $SENHA1; echo $SENHA1) | smbpasswd -s -a $USERNAME &> /dev/null			
			Mensagem "Senha alterada com sucesso!"
			else
			Mensagem "Senha não alterada!"
			fi
		fi
	fi
	;;
	esac
	else
	Mensagem "As senhas são diferentes!"
fi
fi
}

Listar(){


cat /etc/samba/smbpasswd | cut -d: -f1 | nl > /tmp/.smb_lista
dialog --backtitle "Lista Usuarios Samba" --textbox /tmp/.smb_lista 10 24		
}


Remover() {
USERNAME=$(dialog --stdout --backtitle "Remover Usuario" --inputbox "Informe o nome do usuario que deseja remover:" 8 62)
						
existe=`cat /etc/passwd | cut -d : -f 1 | grep ^$USERNAME$`

	if [ $existe ==NULL  ]; then

	Mensagem "Usuario $USERNAME nao existe!"
	return
	
	else
	dialog --yesno "Confirma a exclusao do usuario $USERNAME ?" 7 45
	op=$?
	case $op in
	0)
	
		if smbpasswd -x $USERNAME &> /dev/null
		then

		userdel -r $USERNAME &> /dev/null

		Mensagem "Usuario $USERNAME excluido com sucesso!"	

		else
		Mensagem "Voce nao tem permissao para remover usuarios!"
		dialog --title "Pergunta:" --yesno "Deseja executar este comando como root?" 6 46
		op=$?
			
		test -z $op && op = 1
		
		if [ $op -eq 0 ]
		then
			if sudo smbpasswd -x $USERNAME &> /dev/null
			then
			sudo userdel -r $USERNAME &> /dev/null			
			Mensagem "Usuario excluido com sucesso!"
			else
			Mensagem "Usuario nao excluido!"
			fi
		fi
	fi
	;;
	esac
fi
}


globalAvancado() {
as="#################################"
rm smb.tmp
rm smb1.tmp
cat "$caminho/smb.conf" > smb.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Smb.conf" --textbox "smb.tmp" 0 0
sed '/global/,/#######/d' /etc/samba/smb.conf > smb1.tmp

glob="[global]"
com="# Nome para uma rede NETBIOS dos computadores"
primeira="    netbios name = "
com1="# Define um grupo de trabalho para a rede"
segunda="    workgroup = "
com2="# Comentario sobre o servidor"
terceira="    server string = %h"
com3="# Define se este servidor sera um servidor PDC (Controlador de dominio primario)"
quarta="    domain master = "
com4="# Define se este servidor sera um servidor de logon"
quinta="    domain logons = "
com5="# Script utilizado pelo usuario para realizar login"
sexta="     logon script = "
com6="# Armazena todas as configuracoes dos usuarios"
setima="    logon home = "
com7="# Faz com que armazene apenas informações importantes dos usuarios"
oitava="    logon path = "
com8="# Nivel de autenticacao utilizado"
nona="      security = "
com9="# Define se as senhas serão criptografadas"
decima="    encrypt passwords = "
com10="# Define se membros do grupo Domain Admins do Windows poderão adicionar estacoes no samba"
onze="      enable privileges = "
com11="# Define o banco utilizado para obter as informacoes das contas dos usuarios"
doze="      passdb backend = "
com12="# Define se este sera o servidor prioritario de logon"
treze="     preferred master = "
com13="# Define se este servidor sera o servidor PDC principal"
quatorze="  local master = "
com14="# Define o nivel do servidor ou seja quanto maior este numero maior sera o nivel do servidor"
quinze="    os level = "
com15="# Define se este servidor sera um cliente Wins"
deze6="    wins support = "
com16="# Level dos LOGs"
deze7="    log level = "
com17="# Define para onde os erros devem ser enviados"
dez8="    syslog = "
com18="# Define a localização e o arquivo de log. Este sera composto por nome_maquina_cliente.nome_usuario.log"
deze9="	log file = /var/log/samba/%m.%u.log"
com19="# Tamanho maximo do arquivo de log em KB"
vinte="	max log size = "
aut=$(dialog --stdout --backtitle "Ex: samba-server" --inputbox "Informe o nome do servidor" 7 50)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $glob > smb.tmp
echo $com >> smb.tmp
echo $primeira $aut >> smb.tmp
echo $com1 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: Ifsul, Grupo, SME e etc" --inputbox "Informe o grupo de trabalho da rede" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $segunda $aut >> smb.tmp
echo $com2 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: Servidor de arquivos" --inputbox "Adicione um comentario sobre o servidor" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $terceira $aut >> smb.tmp
echo $com3 >> smb.tmp
aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Domain Master" --yesno "Este servidor sera um servidor PDC?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quarta $aut >> smb.tmp
echo $com4 >> smb.tmp
aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Domain Logons" --yesno "Este servidor sera um servidor de logon?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quinta $aut >> smb.tmp
echo $com5 >> smb.tmp

aut=" "
aut="%U.bat"
echo $sexta $aut >> smb.tmp
echo $com6 >> smb.tmp
aut=" "

aut="\\%L\%U\.profiles"
echo $setima $aut >> smb.tmp
echo $com7 >> smb.tmp
aut=" "

aut="\\%L\profiles\%U"
echo $oitava $aut >> smb.tmp
echo $com8 >> smb.tmp
aut=" "

aut=$(dialog --stdout --no-cancel --backtitle "Niveis de autenticacao" --menu "Escolha o nivel de autenticacao:" 11 35 35 \
        1 "Share" \
	2 "User" \
	3 "Domain" )

op=$?
if [ $op -eq 255 ]
then
return
fi
if [ $aut -eq 1 ]
then
aut="share"
fi
if [ $aut -eq 2 ]
then
aut="user"
fi
if [ $aut -eq 3 ]
then
aut="domain"
fi

echo $nona $aut >> smb.tmp
echo $com9 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Encrypt Passwords" --yesno "As senhas serao criptografadas?" 6 46
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi


echo $decima $aut >> smb.tmp
echo $com10 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Enable Privileges" --yesno "Membros Domain Admins poderao adicionar estacoes?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi


echo $onze $aut >> smb.tmp
echo $com11 >> smb.tmp

aut=" "

aut=$(dialog --stdout --no-cancel --backtitle "Banco utilizado para obter indormacoes dos usuarios" --menu "Escolha o banco utilizado:" 11 35 35 \
        1 "Smbpasswd" \
	2 "Tdbsam" )

op=$?
if [ $op -eq 255 ]
then
return
fi
#if [ $aut -eq 1 ]
#then
#aut="plaintext"
#fi
if [ $aut -eq 1 ]
then
aut="smbpasswd"
fi
if [ $aut -eq 2 ]
then
aut="tdbsam"
fi

echo $doze $aut >> smb.tmp
echo $com12 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Preferred Master" --yesno "Este sera o servidor padrao de logons?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $treze $aut >> smb.tmp
echo $com13 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Local Master" --yesno "Este sera o servidor de controle primario principal?" 6 65
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quatorze $aut >> smb.tmp
echo $com14 >> smb.tmp

aut=" "
aut=$(dialog --stdout --backtitle "Ex: O numero pode ser um valor entre 0 e 255" --inputbox "Informe o OS Level deste servidor:" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi

while [ $aut -lt 0 -o $aut -gt 255 ]
do 
aut=$(dialog --stdout --backtitle "Ex: O numero pode ser um valor entre 0 e 255" --inputbox "Tente novamente:" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
done

echo $quinze $aut >> smb.tmp
echo $com15 >> smb.tmp

aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Wins Support" --yesno "Defina se este servidor sera um cliente Wins?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $deze6 $aut >> smb.tmp
echo $com16 >> smb.tmp

aut=" "
aut=$(dialog --stdout --backtitle "Ex: O valor default é 0, mas pode-se colocar até o valor 3" --inputbox "Level dos LOGs" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi

while [ $aut -lt 0 -o $aut -gt 3 ]
do 
aut=$(dialog --stdout --backtitle "Ex: O valor default é 0, mas pode-se colocar até o valor 3" --inputbox "Valor errado! Tente novamente:" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
done

echo $deze7 $aut >> smb.tmp
echo $com17 >> smb.tmp

aut=" "

aut="0"
echo $dez8 $aut >> smb.tmp
echo $com18 >> smb.tmp

echo $deze9 >> smb.tmp
echo $com19 >> smb.tmp

aut=" "
aut=$(dialog --stdout --backtitle "Ex: 100000" --inputbox "Tamanho maximo do arquivo de log em KB" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi

echo $vinte $aut >> smb.tmp
aut=" "
echo " " >> smb.tmp
echo $as >> smb.tmp
cat smb1.tmp >> smb.tmp
cat smb.tmp > "$caminho/smb.conf"
dialog --title "Configuracao Atual" --backtitle "Configuração smb.conf" --textbox "$caminho/smb.conf" 0 0
}

profilesAvancado(){
as="#################################"
rm smb.tmp
rm smb1.tmp
cat "$caminho/smb.conf" > smb.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Smb.conf" --textbox "smb.tmp" 0 0
sed '/Profiles/,/########/d' /etc/samba/smb.conf > smb.tmp

prof="[Profiles]"
com1="# Diretorio onde ficam os profiles"
primeiro="	path = "
com2="# Permite ou nao a gravacao no compartilhamento"
segundo="	writable = "
com3="# Permite ou nao a visualizacao do compartilhamento"
terceiro="	browseable = "
com4="# Permissao dos arquivos criados"
quarto="	create mask = "
com5="# Permissao dos diretorios criados"
quinto="	directory mask = "

vazia=" "
echo $vazia >> smb.tmp
echo $prof >> smb.tmp
echo $com1 >> smb.tmp
aut=" "
aut="/var/samba/profiles"

if (cd $aut)
then
cd $HOME/tcc
else
mkdir -p $aut
chmod -R 1777 $aut
fi

if (cd /etc/skel/profile.pds)
then
cd $HOME/tcc
else
mkdir -p /etc/skel/profile.pds
chmod -R 664 /etc/skel/profile.pds
fi

echo $primeiro $aut >> smb.tmp
echo $com2 >> smb.tmp

aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Writable" --yesno "Permitir a gravacao no compartilhamento?" 6 46
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $segundo $aut >> smb.tmp
echo $com3 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Browseable" --yesno "Permitir a visualizacao do compartilhamento?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $terceiro $aut >> smb.tmp
echo $com4 >> smb.tmp

aut=" "
aut=$(dialog --stdout --backtitle "Ex: 0600" --inputbox "Informe as permissao dos arquivos criados" 7 60)
op=$?
if [ $op -eq 1 ]
then	
return
fi

#while [ $aut != "yes" -a $aut != "no" ]
#do
#aut=$(dialog --stdout --backtitle "Ex: yes ou no" --inputbox "Resposta errada, tente novamente:" 7 60)
#op=$?
#if [ $op -eq 1 ]
#then
#return
#fi
#done

echo $quarto $aut >> smb.tmp
echo $com5 >> smb.tmp

aut=" "
aut=$(dialog --stdout --backtitle "Ex: 0700" --inputbox "Informe as permissao dos diretorios criados" 7 60)
op=$?
if [ $op -eq 1 ]
then	
return
fi

echo $quinto $aut >> smb.tmp

aut=" "
echo " " >> smb.tmp
echo $as >> smb.tmp
cat smb.tmp > "$caminho/smb.conf"
dialog --title "Configuracao Atual" --backtitle "Configuração smb.conf" --textbox "$caminho/smb.conf" 0 0
}

netlogonAvancado(){
as="#################################"
rm smb.tmp
rm smb1.tmp
cat "$caminho/smb.conf" > smb.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Smb.conf" --textbox "smb.tmp" 0 0
sed '/netlogon/,/########/d' /etc/samba/smb.conf > smb.tmp

logon="[netlogon]"
com1="# Comentario sobre o compartilhamento de logon"
primeiro="	comment = "
com2="# Diretorio onde ficam os scripts de logon"
segundo="	path = "
com3="# Permite ou nao a visualizacao do compartilhamento"
terceiro="	browseable = "
com4="# Se definido com yes qualquer usuario tera acesso"
quarto="	guest ok = "
vazia=" "

echo $vazia >> smb.tmp
echo $logon >> smb.tmp
echo $com1 >> smb.tmp
aut=" "

aut=$(dialog --stdout --backtitle "Ex: Compartilhamento Logon" --inputbox "Digite um comentario sobre o compartilhamento" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi

echo $primeiro $aut >> smb.tmp
echo $com2 >> smb.tmp

aut=" "
aut="/var/samba/netlogon"

echo $segundo $aut >> smb.tmp
echo $com3 >> smb.tmp

if (cd $aut)
then
cd $HOME/tcc
else
mkdir -p $aut
chmod -R 775 $aut
fi

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Browseable" --yesno "Permitir a visualizacao do compartilhamento?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $terceiro $aut >> smb.tmp
echo $com4 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Guest OK" --yesno "Permitir que qualquer usuario tenha acesso?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quarto $aut >> smb.tmp

aut=" "
echo " " >> smb.tmp
echo $as >> smb.tmp
cat smb.tmp > "$caminho/smb.conf"
sleep 4
dialog --title "Configuracao Atual" --backtitle "Configuração smb.conf" --textbox "$caminho/smb.conf" 0 0
}


homeAvancado(){
as="#################################"
cat "$caminho/smb.conf" > smb.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Smb.conf" --textbox "smb.tmp" 0 0
sed '/Home/,/########/d' /etc/samba/smb.conf > smb.tmp

home="[Home]"
com1="# Define que apenas o usuario tera acesso a sua home"
primeiro="	valid users = %S"
com2="# Define a permissao dos arquivos criados"
segundo="	create mask = "
com3="# Define a permissao dos diretorios criados"
terceiro="	directory mask = "
com4="# Permite ou nao a visualizacao da home"
quarto="	browseable = "
com5="# Permite ou nao a gravacao no compartilhamento"
quinto="	writable = "
vazia=" "
echo $vazia >> smb.tmp
echo $home >> smb.tmp
echo $com1 >> smb.tmp
echo $primeiro >> smb.tmp
echo $com2 >> smb.tmp
aut=" "

aut=$(dialog --stdout --backtitle "Ex: 0700, esse é o padrão para que só o dono posso modificar " --inputbox "Informe as permissoes para os arquivos criados" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi

echo $segundo $aut >> smb.tmp
echo $com3 >> smb.tmp

aut=" "

aut=$(dialog --stdout --backtitle "Ex: 0700, esse é o padrão para que só o dono posso modificar " --inputbox "Informe as permissoes para os diretorios criados" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi

echo $terceiro $aut >> smb.tmp
echo $com4 >> smb.tmp


dialog --title "Pergunta:" --backtitle "Parametro Browseable" --yesno "Permitir a visualizacao da home do usuario?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quarto $aut >> smb.tmp
echo $com5 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Writable" --yesno "Permitir gravacao na home do usuario?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quinto $aut >> smb.tmp

aut=" "
echo " " >> smb.tmp
echo $as >> smb.tmp
cat smb.tmp > "$caminho/smb.conf"
dialog --title "Configuracao Atual" --backtitle "Configuração smb.conf" --textbox "$caminho/smb.conf" 0 0
}


compartilhamentoAvancado(){
as="#################################"
cat "$caminho/smb.conf" > smb.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Smb.conf" --textbox "smb.tmp" 0 0
sed '/dados/,/########/d' /etc/samba/smb.conf > smb.tmp


com10="# Comentario sobre o compartilhamento"
onze="	comment = "
com11="# Disponibiliza ou não o compartilhamento"
doze="	available = "
com12="# Permite ou nao a visualizacao do compartilhamento"
treze="	browseable = "
com13="# Diretorio compartilhado"
quatorze="	path = "
com14="# Exige ou nao a senha do usuario"
quinze="	public = "
com15="# Se definido com yes qualquer usuario tera acesso"
deze6="	guest ok = "
com16="# Define se e possivel gravar no compartilhamento"
deze7="	writable = "

dad="[dados]"
vazia=" "
echo $vazia >> smb.tmp
echo $dad >> smb.tmp
echo $com10 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: Diretorio compartilhado" --inputbox "Digite um comentario sobre o compartilhamento" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $onze $aut >> smb.tmp
echo $com11 >> smb.tmp
aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Available" --yesno "O compartilhamento deve ficar disponivel?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $doze $aut >> smb.tmp
echo $com12 >> smb.tmp
aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Browseable" --yesno "O compartilhamento deve ficar visivel?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $treze $aut >> smb.tmp
echo $com13 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: /mnt/publico" --inputbox "Informe o diretorio que será compartilhado" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
if (cd $aut)
then
cd $HOME/tcc
else
mkdir -p $aut
chmod -R 777 $aut
fi
echo $quatorze $aut >> smb.tmp
echo $com14 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Public" --yesno "Permitir o acesso ao servidor sem senha?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quinze $aut >> smb.tmp
echo $com15 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Guest OK" --yesno "Permitir que qualquer usuario tenha acesso?" 6 60
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $deze6 $aut >> smb.tmp
echo $com16 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Writable" --yesno "Permitir gravacoes no diretorio compartilhado?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $deze7 $aut >> smb.tmp

aut=" "
echo $as >> smb.tmp
cat smb.tmp > "$caminho/smb.conf"
dialog --title "Configuracao Atual" --backtitle "Configuração smb.conf" --textbox "$caminho/smb.conf" 0 0

}

global() {
as="#################################"
cat "$caminho/smb.conf" > smb.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Smb.conf" --textbox "smb.tmp" 0 0
sed '/global/,/########/d' /etc/samba/smb.conf > global.tmp

glob="[global]"
com="# Nome para uma rede NETBIOS dos computadores"
primeira="    netbios name = "
com1="# Define um grupo de trabalho para a rede"
segunda="    workgroup = "
com2="# Comentario sobre o servidor"
terceira="    server string = %h"
com3="# Define o nivel de autenticacao"
quarta="    security = "
com4="# Define se este servidor sera um servidor de logon"
quinta="    domain logons = "
com5="# Define se este servidor sera um cliente Wins"
sexta="    wins support = "
com6="# Level dos LOGs"
setima="    log level = "
com7="# Define para onde os erros devem ser enviados"
oitava="    syslog = "
com8="# Define a localização e o arquivo de log. Este sera composto por nome_maquina_cliente.nome_usuario.log"
nona="	log file = /var/log/samba/%m.%u.log"
com9="# Tamanho maximo do arquivo de log em KB"
decima="	max log size = "
com10="# Define o banco utilizado para obter as informacoes das contas dos usuarios"
onze="      passdb backend = "
aut=$(dialog --stdout --backtitle "Ex: samba-server" --inputbox "Informe o nome do servidor" 7 50)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $glob > smb.tmp
echo $com >> smb.tmp
echo $primeira $aut >> smb.tmp
echo $com1 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: Ifsul, Grupo, SME e etc" --inputbox "Informe o grupo de trabalho da rede" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $segunda $aut >> smb.tmp
echo $com2 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: Servidor de arquivos" --inputbox "Adicione um comentario sobre o servidor" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $terceira $aut >> smb.tmp
echo $com3 >> smb.tmp
aut=" "

aut=$(dialog --stdout --no-cancel --backtitle "Niveis de autenticacao" --menu "Escolha o nivel de autenticacao:" 11 35 35 \
        1 "Share" \
	2 "User" \
	3 "Domain" )

op=$?
if [ $op -eq 255 ]
then
return
fi
if [ $aut -eq 1 ]
then
aut="share"
fi
if [ $aut -eq 2 ]
then
aut="user"
fi
if [ $aut -eq 3 ]
then
aut="domain"
fi


echo $quarta $aut >> smb.tmp
echo $com4 >> smb.tmp
aut=" "
#aut=$(dialog --stdout --backtitle "Ex: yes ou no" --inputbox "Defina se este servidor sera um servidor de logon" 7 60)
#if [ $op -eq 1 ]
#then
#return
#fi
aut="no"
echo $quinta $aut >> smb.tmp
echo $com5 >> smb.tmp
aut=" "
#aut=$(dialog --stdout --backtitle "Ex: yes ou no" --inputbox "Defina se este servidor sera um cliente Wins" 7 60)
#if [ $op -eq 1 ]
#then
#return
#fi
aut="no"
echo $sexta $aut >> smb.tmp
echo $com6 >> smb.tmp
aut=" "
#aut=$(dialog --stdout --backtitle "Ex: O valor default é 0, mas pode-se colocar até o valor 3" --inputbox "Level dos LOGs" 7 60)
#op=$?
#if [ $op -eq 1 ]
#then
#return
#fi

#while [ $aut -lt 0 -o $aut -gt 3 ]
#do 
#aut=$(dialog --stdout --backtitle "Ex: O valor default é 0, mas pode-se colocar até o valor 3" --inputbox "Tente novamente:" 7 60)
#op=$?
#if [ $op -eq 1 ]
#then
#return
#fi
#done
aut="0"
echo $setima $aut >> smb.tmp
echo $com7 >> smb.tmp
aut=" "
#aut=$(dialog --stdout --backtitle "Ex: O valor default é 0" --inputbox "Informe para onde os erros devem ser enviados" 7 60)
#if [ $op -eq 1 ]
#then
#return
#fi
aut="0"
echo $oitava $aut >> smb.tmp
echo $com8 >> smb.tmp
aut=" "
echo $nona >> smb.tmp
echo $com9 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: 100000" --inputbox "Tamanho maximo do arquivo de log em KB" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $decima $aut >> smb.tmp

aut="smbpasswd"
echo $com10 >> smb.tmp
echo $onze $aut >> smb.tmp

aut=" "
echo " " >> smb.tmp
echo $as >> smb.tmp
cat global.tmp >> smb.tmp
cat smb.tmp > "$caminho/smb.conf"
dialog --title "Configuracao Atual" --backtitle "Configuração smb.conf" --textbox "$caminho/smb.conf" 0 0
}

compartilhamento(){
as="#################################"
cat "$caminho/smb.conf" > smb.tmp
dialog --title "Configuracao Atual" --backtitle "Configuração Smb.conf" --textbox "smb.tmp" 0 0
sed '/dados/,/########/d' /etc/samba/smb.conf > smb.tmp

com10="# Comentario sobre o compartilhamento"
onze="	comment = "
com11="# Disponibiliza ou não o compartilhamento"
doze="	available = "
com12="# Permite ou nao a visualizacao do compartilhamento"
treze="	browseable = "
com13="# Diretorio compartilhado"
quatorze="	path = "
com14="# Exige ou nao a senha do usuario"
quinze="	public = "
com15="# Se definido com yes qualquer usuario tera acesso"
deze6="	guest ok = "
com16="# Define se e possivel gravar no compartilhamento"
deze7="	writable = "

dad="[dados]"
#dad=$(dialog --stdout --backtitle "Ex: compartilhamento" --inputbox "Informe o nome da secao" 7 50)
#dad=[$dad]
#op=$?
#if [ $op -eq 1 ]
#then
#return
#fi
vazia=" "
echo $vazia >> smb.tmp
echo $dad >> smb.tmp
echo $com10 >> smb.tmp
aut=" "
aut=$(dialog --stdout --backtitle "Ex: Diretorio compartilhado" --inputbox "Digite um comentario sobre o compartilhamento" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
echo $onze $aut >> smb.tmp
echo $com11 >> smb.tmp
aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Available" --yesno "O compartilhamento deve ficar disponivel?" 6 46
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $doze $aut >> smb.tmp
echo $com12 >> smb.tmp
aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Browseable" --yesno "O compartilhamento deve ficar visivel?" 6 46
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $treze $aut >> smb.tmp
echo $com13 >> smb.tmp

aut=" "
aut=$(dialog --stdout --backtitle "Ex: /mnt/publico" --inputbox "Informe o diretorio que será compartilhado" 7 60)
op=$?
if [ $op -eq 1 ]
then
return
fi
if (cd $aut)
then
cd /home/felipe/tcc
else
mkdir -p $aut
chmod -R 777 $aut
fi
echo $quatorze $aut >> smb.tmp
echo $com14 >> smb.tmp
aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Public" --yesno "Permitir o acesso ao servidor sem senha?" 6 46
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $quinze $aut >> smb.tmp
echo $com15 >> smb.tmp
aut=" "

dialog --title "Pergunta:" --backtitle "Parametro Guest OK" --yesno "Permitir que qualquer usuario tenha acesso?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi

echo $deze6 $aut >> smb.tmp
echo $com16 >> smb.tmp

aut=" "
dialog --title "Pergunta:" --backtitle "Parametro Writable" --yesno "Permitir gravacoes no diretorio compartilhado?" 6 55
op=$?
if [ $op -eq 0 ]
then 
aut="yes"
else
aut="no"
fi

if [ $op -eq 255 ]
then
return
fi


echo $deze7 $aut >> smb.tmp

aut=" "
echo $as >> smb.tmp
cat smb.tmp > "$caminho/smb.conf"
dialog --title "Configuracao Atual" --backtitle "Configuração smb.conf" --textbox "$caminho/smb.conf" 0 0

}


iniciar(){
if (service smbd start &> /dev/null)
then
Mensagem "Servico iniciado com sucesso!"
else
Mensagem "Servico nao iniciado!"
fi
}

parar(){
if (service smbd stop &> /dev/null)
then
Mensagem "Servico parado com sucesso!"
else
Mensagem "Impossivel parar o servico!"
fi
}

restart(){
if (service smbd restart &> /dev/null)
then
Mensagem "Servico reiniciado com sucesso!"
else
Mensagem "Servico nao reiniciado!"
fi
}

Principal() {
opcao=1
clear
TesteSamba

while [ $opcao != 0 ]
do

Menu

case $opcao in
	
	1) clear 
	editar
	;;
	2) clear
	MenuConfiguracao
	;; 
	3) clear
	MenuUsuario
	;;	
	4) clear
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
rm -rf smb.tmp
rm -rf tmp.tmp
rm -rf smb1.tmp
clear

#!/bin/bash
#### Script creado por dobleM

# Variables
NOMBRE_SCRIPT="i_dobleM.sh"
INFO_SISTEMA="$(uname -a)"

clear
	
# Arranca script principal
	echo "\e[36m##############################################################\e[0m" 
	echo "\e[36m###                        \e[0;32mdobleM\e[0m                          \e[36m###\e[0m" 
	echo "\e[36m###               Telegram: \e[96mt.me/EPG_dobleM\e[0m                \e[36m###\e[0m" 
	echo "\e[36m##############################################################\e[0m" 
	echo
	echo "Se ha detectado el sistema operativo: \e[38;5;198m$INFO_SISTEMA\e[0m\n"
 
# Menu de sistemas
while :	
do
	echo "1) Ejecutar instalador para \e[0;36mLinux\e[0m"
	echo "2) Ejecutar instalador para \e[0;36mSynology en desarrollo\e[0m"
	echo "3) Ejecutar instalador para \e[0;36mPrueba1\e[0m"
    echo "4) Ejecutar instalador para \e[0;36mPrueba2\e[0m"
	echo 
    echo "5) \e[31mSalir del instalador\e[0m"
	echo
	echo -n "Indica una opción: "
	read opcion
	case $opcion in
		1) wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_linux.sh && sh i_linux.sh && rm -rf i_linux.sh; break;;
		2) echo "Esta función todavía no está, no seas impaciente"; break;;
		3) echo "Esta función todavía no está, no seas impaciente"; break;;
		4) echo "Esta función todavía no está, no seas impaciente"; break;;
		5) rm -rf $NOMBRE_SCRIPT; exit;;		
		*) echo "$opcion es una opción inválida\n";
	esac
done
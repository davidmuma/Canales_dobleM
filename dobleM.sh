#!/bin/bash
#### Script creado por dobleM

# Variables
INFO_SISTEMA="$(uname -a)"

clear

# Comprobamos si se está ejecutando como root
if [ $(id -u) -ne 0 ]; then
	printf "\e[31mERROR:\e[0m Por favor, ejecuta el script como root.
	
	Puedes hacerlo de diferentes formas:
	- Mediante el comando \"sudo sh $0\"
	- Entrando en la sesión del propio root con \"sudo -i\"
	  y después ejecutando el script con \"sh $0\"\n\n"
	exit 1
fi

# Borramos posibles residuos anteriores
#	rm -rf dobleM.sh
#	rm -rf i_linux.sh
	
# Arranca script principal
	echo "\e[36m##############################################################\e[0m" 
	echo "\e[36m###                      \e[0;32mdobleM\e[0m  v1.0                      \e[36m###\e[0m" 
	echo "\e[36m###               Telegram: \e[96mt.me/EPG_dobleM\e[0m                \e[36m###\e[0m" 
	echo "\e[36m##############################################################\e[0m" 
	echo
	echo "Se ha detectado el sistema operativo: \e[38;5;198m$INFO_SISTEMA\e[0m\n"
 
# Menu de instalación de dobleM por sistemas
while :	
do
	echo "1) Ejecutar instalador para \e[0;36mLinux\e[0m"
	echo "2) Ejecutar instalador para \e[0;36mSynology\e[0m"
	echo "3) Ejecutar instalador para \e[0;36mPrueba1\e[0m"
    echo "4) Ejecutar instalador para \e[0;36mPrueba2\e[0m"
	echo
    echo "5) \e[31mSalir del instalador\e[0m"
	echo
	echo -n "Indica una opción: "
	read opcion
	case $opcion in
		1) sh i_linux.sh; break;;
		#1) wget -c -q normandy.es//install/nepg43.sh && chmod +x ./nepg43.sh && ./nepg43.sh && rm ./nepg43.sh; break;;
		2) wget -c -q normandy.es//install/nepgae.sh && chmod +x ./nepgae.sh && ./nepgae.sh && rm ./nepgae.sh; break;;
		3) wget -c -q normandy.es//install/nepgdk.sh && chmod +x ./nepgdk.sh && ./nepgdk.sh && rm ./nepgdk.sh; break;;
		4) wget -c -q normandy.es//install/nepge2.sh && chmod +x ./nepge2.sh && ./nepge2.sh && rm ./nepge2.sh; break;;
		5) exit;;		
		*) echo "$opcion es una opción inválida";
	esac
done
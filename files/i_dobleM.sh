#!/bin/bash
# - Script creado por dobleM
#Formatear texto con colores: https://unix.stackexchange.com/a/92568
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
end='\e[0m'

# Detectamos sistema operativo
SYSTEM_INFO="$(uname -a)"
if [ "${SYSTEM_INFO#*"synology"}" != "$SYSTEM_INFO" ]; then
	INFO_SISTEMA="Synology/XPEnology"
else 
	INFO_SISTEMA="$(sed -e '/PRETTY_NAME=/!d' -e 's/PRETTY_NAME=//g' /etc/*-release)"
fi

# MENU ELECCION DE SISTEMAS
while :	
do
clear
	echo -e "$blue ############################################################################# $end" 
	echo -e "$blue ###                           $green -= dobleM =- $end                             $blue ### $end"
	echo -e "$blue ###                     Telegram: $cyan t.me/EPG_dobleM $end                      $blue ### $end"
	echo -e "$blue ### --------------------------------------------------------------------- ###$end" 
	echo -e "$blue ###       Por favor, comprueba tu sistema y tu versión de tvheadend       ### $end"
	echo -e "$blue ###       Para dudas o sugerencias pásate por el grupo de telegram.       ### $end" 
	echo -e "$blue ############################################################################# $end" 
	echo
	echo -e " Se ha detectado el sistema operativo:$yellow $INFO_SISTEMA $end"
	echo _________________________________________________________________________________
	echo
	echo -e " 1)$cyan Ejecutar instalador para$end$green Synology/XPEnology $end(solo para tvheadend 4.3)"
	echo
	echo -e " 2)$cyan Ejecutar instalador para$end$green LibreELEC/OpenELEC $end(solo para tvheadend 4.3)"
	echo
	echo -e " 3)$cyan Ejecutar instalador para$end$green Linux $end(solo para tvheadend 4.3)"
	echo
    echo -e " 4)$red Salir del instalador $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && sudo sh i_dobleMi.sh Synology; break;;
		2) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && sh i_dobleMi.sh Libreelec; break;;
		3) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && sudo sh i_dobleMi.sh Linux; break;;
		4) rm -rf i_dobleM*.sh; exit;;		
		*) echo "$opcion es una opción inválida\n";
	esac
done

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

# Variables
NOMBRE_SCRIPT="i_dobleM.sh"
INFO_SISTEMA="$(sed -e '/PRETTY_NAME=/!d' -e 's/PRETTY_NAME=//g' /etc/*-release)"

clear
	
# Arranca script principal
	echo
	echo -e "$blue ################################################################# $end" 
	echo -e "$blue #                       $green -= dobleM =- $end                         $blue # $end"
	echo -e "$blue #                 Telegram: $cyan t.me/EPG_dobleM $end                  $blue # $end"
	echo -e "$blue # ------------------------------------------------------------- #$end" 
	echo -e "$blue #   Por favor, comprueba tu sistema y tu versión de tvheadend   # $end"
	echo -e "$blue #   Para dudas o sugerencias pásate por el grupo de telegram.   # $end" 
	echo -e "$blue ################################################################# $end" 
	echo
	echo -e " Se ha detectado el sistema operativo:$yellow $INFO_SISTEMA $end"
	echo
	echo  -----------------------------------------------------------------
 
# Menu de sistemas
while :	
do
	echo
	echo -e " 1) Ejecutar instalador para$green Linux $end(solo para tvheadend 4.3)"
	echo
	echo -e " 2) Ejecutar instalador para$green Synology/XPEnology $end(en pruebas)"
	echo
	echo -e " 3) Ejecutar instalador para$green LibreELEC/OpenELEC $end(válido para tvheadend 4.2 y 4.3)"
	echo
	echo -e " 4) Ejecutar$green COPIA DE SEGURIDAD de tvheadend con script MANUELIN modificado $end"
	echo
	echo -e " 5) Ejecutar$green INSTALACION lista y grabber posters dobleM con script MANUELIN modificado $end"
	echo
    echo -e " 6) Ejecutar$green INSTALACION lista y grabber fantarts dobleM con script MANUELIN modificado $end"
	echo
    echo -e " 7) Ejecutar$green INSTALACION para COREELEC/LIBREELEC con script MANUELIN modificado $end"
	echo
    echo -e " 8)$red Salir del instalador $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_linux.sh && clear && sudo sh i_linux.sh; break;;
		2) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_synology.sh && clear && sudo sh i_synology.sh; break;;
		3) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_libreelec.sh && clear && sh i_libreelec.sh; break;;
		4) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_mposter.sh && clear && sudo sh i_mposter.sh -b; break;;
		5) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_mposter.sh && clear && sudo sh i_mposter.sh -g; break;;
		6) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_mfanart.sh && clear && sudo sh i_mfanart.sh -g; break;;
		7) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_mposter.sh && clear && sh i_mposter.sh -g; break;;
		8) rm -rf i_*.sh; exit;;		
		*) echo "$opcion es una opción inválida\n";
	esac
done

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
INFO_SISTEMA="$(lsb_release -d | cut -f 2-10 -d":")"

clear
	
# Arranca script principal
	echo "$blue ################################################################# $end" 
	echo "$blue #                       $green -= dobleM =- $end                         $blue # $end" 
	echo "$blue #                 Telegram: $cyan t.me/EPG_dobleM $end                  $blue # $end"
	echo "$blue # ------------------------------------------------------------- #$end"
	echo "$blue #  $red¡ PRECAUCION! $end  $blue Comprueba que el sistema y los directorios  # $end" 
	echo "$blue #  de instalación sean correctos, en caso de duda no continues  # $end" 
	echo "$blue ################################################################# $end" 
	echo
	echo " Se ha detectado el sistema operativo:$yellow $INFO_SISTEMA $end"
	echo
	echo " Instalación solo válida para la rama:$cyan  Tvheadend 4.3 $end"
 
# Menu de sistemas
while :	
do
	echo
	echo " 1) Ejecutar instalador para$green Linux $end"
	echo
	echo " 2) Ejecutar instalador para$green Synology (en pruebas) $end"
	echo
	echo " 3) Ejecutar instalador para$green LibreELEC (en pruebas) $end"
	echo
	echo " 4) Ejecutar$green COPIA DE SEGURIDAD de tvheadend con script MANUELIN modificado $end"
	echo
	echo " 5) Ejecutar$green INSTALACION lista y grabber posters dobleM con script MANUELIN modificado $end"
	echo
    echo " 6) Ejecutar$green INSTALACION lista y grabber fantarts dobleM con script MANUELIN modificado $end"
	echo 
    echo " 7)$red Salir del instalador $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_linux.sh && sudo sh i_linux.sh; break;;
		2) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_synology.sh && sudo sh i_synology.sh; break;;
		3) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_libreelec.sh && sudo sh i_libreelec.sh; break;;
		4) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_mposter.sh && sudo sh i_mposter.sh -b; break;;
		5) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_mposter.sh && sudo sh i_mposter.sh -g; break;;
		6) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_mfanart.sh && sudo sh i_mfanart.sh -g; break;;
		7) rm -rf i_*.sh; exit;;		
		*) echo "$opcion es una opción inválida\n";
	esac
done

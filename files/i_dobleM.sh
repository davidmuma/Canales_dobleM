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
	echo "$blue #  Si continuas se borrará cualquier lista de canales anterior  # $end"
	echo "$blue ################################################################# $end" 
	echo
	echo " Se ha detectado el sistema operativo: $yellow $INFO_SISTEMA $end"
 
# Menu de sistemas
while :	
do
	echo
	echo " 1) Ejecutar instalador para$green Linux $end"
	echo
	echo " 2) Ejecutar instalador para$green COPIA DE SEGURIDAD de tvheadend con script MANUELIN $end"
	echo
	echo " 3) Ejecutar instalador para$green INSTALAR lista y grabber dobleM con script MANUELIN $end"
	echo
    echo " 4) Ejecutar instalador para$green Prueba2 $end"
	echo 
    echo " 5)$red Salir del instalador $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_linux.sh && sudo sh i_linux.sh; break;;
		2) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_manuelin.sh && sudo sh i_manuelin.sh -b; break;;
		3) curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_manuelin.sh && sudo sh i_manuelin.sh -g; break;;
		4) echo "Esta función todavía no está, no seas impaciente"; break;;
		5) rm -rf i_*.sh; exit;;		
		*) echo "$opcion es una opción inválida\n";
	esac
done

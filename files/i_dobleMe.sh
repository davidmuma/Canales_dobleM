#!/bin/bash
# - script creado por dobleM
#Formatear texto con colores: https://unix.stackexchange.com/a/92568
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
end='\e[0m'

CARPETA_SCRIPT="$PWD"

#EPG
enigma2_EPG()
{
 cd $CARPETA_SCRIPT
 if [ ! -d /etc/epgimport/ ]; then
   echo "No tienes instalado EPG Import en su receptor, realiza la instalación y vuelve a intentarlo"
   sleep 5
 else
   curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_E2.sources.tar > /dev/null 2>&1
   wget -O dobleM_E2.sources.tar https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_E2.sources.tar > /dev/null 2>&1
   tar xf dobleM_E2.sources.tar -C /etc/epgimport/ 2>/dev/null
   rm -r dobleM_E2.sources.tar
   rm -rf i_dobleM*.sh
   echo
   echo "Ha finalizado la instalación, ves a EPG-Import y selecciona la fuente dobleM"
   echo
   sleep 5
   exit
 fi
}

# MENU INSTALACION
MENU()
{
while :
do
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                           $green -= dobleM =- $end                             $blue ### $end"
	echo -e "$blue ###                     Telegram: $cyan t.me/EPG_dobleM $end                      $blue ### $end"
	echo -e "$blue ### --------------------------------------------------------------------- ### $end"
	echo -e "$blue ###                 Instalador para EPG-Import en Enigma2                 ### $end"
	echo -e "$blue ############################################################################# $end"
	echo
	echo -e "$cyan Se procederá a instalar los recursos para la EPG $end"
	echo
	echo -n " ¿Estás seguro que deseas continuar? [s/n] "
	read opcionEPG
	case $opcionEPG in
			s) clear && enigma2_EPG;;
			n) clear && echo " Gracias por usar el script dobleM" && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit;;
			*) echo && echo " Por favor, elige Si o No" && echo;
	esac
done
}
MENU
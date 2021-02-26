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

	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                           $green -= dobleM =- $end                             $blue ### $end"
	echo -e "$blue ###                     Telegram: $cyan t.me/EPG_dobleM $end                      $blue ### $end"
	echo -e "$blue ### --------------------------------------------------------------------- ### $end"
	echo -e "$blue ###                 Instalador para EPG Import en Enigma2                 ### $end"
	echo -e "$blue ############################################################################# $end"
	echo
	while :
	do
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

#EPG
enigma2_EPG()
{
 if [ ! -d /etc/epgimport/ ]; then
   echo "No tienes instalado EPG Import en su receptor, realiza la instalación y vuelve a intentarlo"
   sleep 5
 else
   curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_E2.sources.tar
   tar xvf dobleM_E2.sources.tar -C /etc/epgimport/
   rm -r dobleM_E2.sources.tar
   echo "Ha finalizado la instalacion, ves a EPG Import y selecciona la fuente dobleM"
   sleep 5
 fi
}

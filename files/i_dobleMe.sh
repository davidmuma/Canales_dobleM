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
	echo -e "$blue ###                        Instalador para Enigma2                        ### $end"
	echo -e "$blue ############################################################################# $end"
	echo
	while :
	do
		echo -e "$cyan Se procederá a instalar la EPG $end"
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
   echo "No tiene instalado epg import en su receptor, realice la instalacion y vuelva a intentarlo"
   sleep 5
 else
   curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_e2EPG.sources.tar
   tar xvf dobleM_e2EPG.sources.tar -C /etc/epgimport/
   rm -r dobleM_e2EPG.sources.tar
   echo "Ha finalizado la instalacion de EPG dobleM, espere unos segundos y volverá al menu"
   sleep 5
 fi


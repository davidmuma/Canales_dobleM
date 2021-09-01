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
cd $CARPETA_SCRIPT

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
	echo -e "$blue ┌───────────────────────────────────────────────────────────────────────────┐ $end"
	echo -e "$blue │                             $green -= dobleM =- $end                             $blue   │ $end"
	echo -e "$blue │                       Telegram: $cyan t.me/EPG_dobleM $end                      $blue   │ $end"
	echo -e "$blue ├───────────────────────────────────────────────────────────────────────────┤ $end"
	echo -e "$blue │       Por favor, comprueba que tu versión de$yellow tvheadend$end$blue sea la$end$yellow 4.3$end      $blue   │ $end"
	echo -e "$blue │     En algunos sistemas es necesario tener instalado sudo y te pedirá     │ $end"
	echo -e "$blue │    tu contraseña para poder continuar con privilegios de administrador    │ $end"
	echo -e "$blue │         Para dudas o sugerencias pásate por el grupo de telegram          │ $end"
	echo -e "$blue └───────────────────────────────────────────────────────────────────────────┘ $end"
	echo -e " Se ha detectado el sistema operativo:$yellow $INFO_SISTEMA $end"
	echo -e " ───────────────────────────────────────────────────────────────────────────── "
	echo
	echo -e " 1)$cyan Ejecutar instalador para$end$green Synology/XPEnology $end(solo DSM 6 y tvheadend 4.3)"
	echo -e " 2)$cyan Ejecutar instalador para$end$green Qnap $end(solo para tvheadend 4.3)"
	echo -e " 3)$cyan Ejecutar instalador para$end$green LibreELEC/OpenELEC $end(solo para tvheadend 4.3)"
	echo -e " 4)$cyan Ejecutar instalador para$end$green CoreELEC $end(solo para tvheadend 4.3)"
	echo -e " 5)$cyan Ejecutar instalador para$end$green AlexELEC $end(solo para tvheadend 4.3)"
	echo -e " 6)$cyan Ejecutar instalador para$end$green Vitmod $end(EN PRUEBAS)"
	echo -e " 7)$cyan Ejecutar instalador para$end$green Linux $end(solo para tvheadend 4.3)"
	echo -e " 8)$cyan Ejecutar instalador para$end$green Docker $end(solo para tvheadend 4.3)"
	echo -e " 9)$cyan Ejecutar instalador para$end$green Docker (sudo) $end(solo para tvheadend 4.3)"
	echo -e " 0)$cyan Ejecutar instalador para$end$green Docker en Asustor $end(solo para tvheadend 4.3)"
	echo
    echo -e " s)$red Salir del instalador $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && sudo chmod +x i_dobleMi.sh && sudo ./i_dobleMi.sh Synology; break;;
		2) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && sudo chmod +x i_dobleMi.sh && sudo ./i_dobleMi.sh Qnap; break;;
		3) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && chmod +x i_dobleMi.sh && ./i_dobleMi.sh Libreelec; break;;
		4) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && chmod +x i_dobleMi.sh && ./i_dobleMi.sh Coreelec; break;;
		5) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && chmod +x i_dobleMi.sh && ./i_dobleMi.sh Alexelec; break;;
		6) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && chmod +x i_dobleMi.sh && ./i_dobleMi.sh Vitmod; break;;
		7) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh && clear && sudo chmod +x i_dobleMi.sh && sudo ./i_dobleMi.sh Linux; break;;
		8) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMd.sh && clear && chmod +x i_dobleMd.sh && ./i_dobleMd.sh; break;;
		9) curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMd.sh && clear && sudo chmod +x i_dobleMd.sh && sudo ./i_dobleMd.sh; break;;
		0) curl -sko $CARPETA_SCRIPT/i_dobleMd.sh https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMd.sh && clear && chmod +x i_dobleMd.sh && sudo -i sh $CARPETA_SCRIPT/i_dobleMd.sh; break;;
		s) clear && echo " Gracias por usar el script dobleM" && rm -rf i_dobleM*.sh; exit;;
		*) echo "$opcion es una opción inválida\n";
	esac
done

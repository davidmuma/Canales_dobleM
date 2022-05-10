#!/bin/bash
# - script creado por dobleM

CARPETA_SCRIPT="$PWD"
cd $CARPETA_SCRIPT

clear
echo
echo Descargando última versión del instalador...
sleep 1
echo
if [ -d /etc/enigma2 ]; then
	if [ -d /home/root/.hts/tvheadend ]; then
		curl -skO "https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh" && clear && chmod +x i_dobleMi.sh && ./i_dobleMi.sh e2
		wget -O i_dobleMi.sh --no-check-certificate "https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMi.sh" && clear && chmod +x i_dobleMi.sh && ./i_dobleMi.sh e2
		echo
		sleep 1
		echo Ejecutando instalador para tvheadend dentro de enigma2...
		sleep 1
		clear
		sh i_dobleM.sh			
	else
		curl -# -kO "https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMe.sh" > /dev/null 2>&1
		wget -O i_dobleMe.sh --no-check-certificate "https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMe.sh" > /dev/null 2>&1
		echo
		sleep 1
		echo Ejecutando instalador para enigma2...
		sleep 1
		clear
		sh i_dobleMe.sh
	fi
else
	curl -# -kO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleM.sh
	echo
	sleep 1
	echo Ejecutando instalador para tvheadend...
	sleep 1
	clear
	sh i_dobleM.sh
fi

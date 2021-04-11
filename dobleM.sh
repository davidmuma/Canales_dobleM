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
	curl -# -kO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMe.sh >/dev/null 2>&1
	wget -O i_dobleMe.sh https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMe.sh >/dev/null 2>&1
	echo
	sleep 1
	echo Ejecutando instalador para enigma2...
	sleep 1
	clear
	sh i_dobleMe.sh
else
	curl -# -kO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleM.sh
	echo
	sleep 1
	echo Ejecutando instalador para tvheadend...
	sleep 1
	clear
	sh i_dobleM.sh
fi

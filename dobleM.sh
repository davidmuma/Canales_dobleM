#!/bin/bash
#### Script creado por dobleM

echo
echo Descargando última versión del instalador...
sleep 1
echo
if [ -d /etc/enigma2 ]; then
	curl -# -O https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMe.sh
	echo
	sleep 1
	echo Ejecutando instalador para enigma2...
	sleep 1
	clear
	sh i_dobleMe.sh
else
	curl -# -O https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleM.sh
	echo
	sleep 1
	echo Ejecutando instalador para tvheadend...
	sleep 1
	clear
	sh i_dobleM.sh
fi

#!/bin/bash
#### script creado por dobleM

# Comprobamos que esté instalado curl
command -v curl >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'curl'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado."; exit 1; }

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

#!/bin/bash
#### Script creado por dobleM

# Comprobamos si se está ejecutando como root
if [ $(id -u) -ne 0 ]; then
	printf "\e[31mERROR:\e[0m Por favor, ejecuta el script como root.
	
	Puedes hacerlo de diferentes formas:
	- Mediante el comando \"sudo sh $0\"
	- Entrando en la sesión del propio root con \"sudo -i\"
	  y después ejecutando el script con \"sh $0\"\n\n"
	exit 1
fi

echo
echo Descargando última versión del instalador...
sleep 1
echo
curl -# -O https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleM.sh
echo
sleep 1
echo Ejecutando instalador...
sleep 1
sudo sh i_dobleM.sh

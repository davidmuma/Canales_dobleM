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

echo Descargando instalador...
sleep 2
wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleM.sh && sudo sh i_dobleM.sh && rm -rf i_dobleM.sh

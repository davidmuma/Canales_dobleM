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

clear
echo Cargando...

if [ -f "dobleM.log" ]; then
	mv "dobleM.log" "dobleM.old.log" 2>>$CARPETA_SCRIPT/dobleM.log
fi

if [ -z "$COLUMNS" ]; then
	COLUMNS=60
fi

instalarEPG()
{
	cd $CARPETA_SCRIPT
	if [ ! -d /etc/epgimport/ ]; then
		echo "$red No tienes instalado EPG-Import en tu receptor, $end"
		echo "$red realiza la instalación y vuelve a intentarlo $end"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
	else
		clear
		echo -e "$blue ############################################################ $end"
		echo -e "$blue ###       $green Comienza la instalación de los sources       $blue ### $end"
		echo -e "$blue ############################################################ $end"
		echo
		printf "%-$(($COLUMNS-10))s"  " 1. Probando descarga con curl"
			ERROR=false
			curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_E2.sources.tar 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s$green%s$end%s\n" "[" "  OK  " "]"
			else
				printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			fi
		printf "%-$(($COLUMNS-10))s"  " 2. Probando descarga con wget"
			wget -O dobleM_E2.sources.tar https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_E2.sources.tar 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s$green%s$end%s\n" "[" "  OK  " "]"
			else
				printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			fi
		printf "%-$(($COLUMNS-10))s"  " 3. Copiando sources"
			tar xf dobleM_E2.sources.tar -C /etc/epgimport/ 2>/dev/null 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s$green%s$end%s\n" "[" "  OK  " "]"
			else
				printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			fi
		printf "%-$(($COLUMNS-10))s"  " 4. Borrando temporales"
			rm -r dobleM_E2.sources.tar 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s$green%s$end%s\n" "[" "  OK  " "]"
			else
				printf "%s$red%s$end%s\n" "[" "FAILED" "]"
				echo -e "\n La descarga ha fallado.\n Por favor, inténtalo más tarde."
				echo
				echo " Pulsa intro para continuar..."
				read CAD
				MENU
			fi
		echo
		echo " Ha finalizado la instalación, ves a EPG-Import y pulsa el boton Azul (Fuentes)"
		echo " Elige la EPG dobleM que mas te guste y luego pulsa el boton Verde (Guardar)"
		echo " Volveremos a la pantalla principal de EPG-Import, si quieres forzar"
		echo " la primera decarga pulsa el boton Amarillo (Manual)"
		echo " Configura éstas opciones:"
		echo " Hora del inicio automático     8:05"
		echo " Eliminar EPG antes de importar     Habilitado"
		echo " luego pulsa el boton Verde (Guardar)"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
	fi
}

elegirSKIN()
{
	cd $CARPETA_SCRIPT
	clear
	echo -e "$blue ############################################################ $end"
	echo -e "$blue ###           $cyan Selecciona el skin a modificar           $blue ### $end"
	echo -e "$blue ############################################################ $end"
	echo
	while :
	do
		echo -e " a) PLi-HD"
		echo -e " b) OpenStarHD"
		echo -e " c) OctEtFHD"
		echo -e " d) DarknessFHD"
		echo -e " e) MetrixHD"
		echo -e " e) AtileHD"
		echo
		echo -e " 0)$magenta Volver al menú$end"
		echo
		echo -e " 1)$green Introducir ruta manualmente $end"
		echo
		echo -n " Indica una opción: "
		read opcionskin
		case $opcionskin in
				a) RUTASKIN=/usr/share/enigma2/PLi-HD; break;;
				b) RUTASKIN=/usr/share/enigma2/OpenStarHD; break;;
				c) RUTASKIN=/usr/share/enigma2/OctEtFHD; break;;
				d) RUTASKIN=/usr/share/enigma2/DarknessFHD; break;;
				e) RUTASKIN=/usr/share/enigma2/MetrixHD; break;;
				f) RUTASKIN=/usr/share/enigma2/AtileHD; break;;
				0) MENU;;
				1)  clear
					echo
					echo -e "Introduce la ruta de tu skin y pulsa INTRO "
					echo
					read RUTASKIN; break;;
				*) echo && echo " $opcionskin es una opción inválida" && echo;
		esac
	done
			if [ "$VAR" = "restaurar" ]; then
				echo -e " MOD"
				restaurarSKIN
			else
				echo -e " RES"
				modificarSKIN
			fi
}

modificarSKIN()
{
	cd $CARPETA_SCRIPT
	clear
	echo -e "$blue ############################################################ $end"
	echo -e "$blue ###         $cyan Selecciona el tipo de letra a usar         $blue ### $end"
	echo -e "$blue ############################################################ $end"
	echo
	while :
	do
		echo -e " 1) NanumGothic"
		echo -e " 2) RocknRollOne"
		echo -e " 3) Rounded"
		echo -e " 4) SawarabiGothic"
		echo -e " 5) Titre"
		echo -e " 6) setrixHD"
		echo
		echo -n " Indica una opción: "
		read opcionletra
		case $opcionletra in
				1) TIPOLETRA='NanumGothic.ttf'; break;;
				2) TIPOLETRA='RocknRollOne.ttf'; break;;
				3) TIPOLETRA='Rounded.ttf'; break;;
				4) TIPOLETRA='SawarabiGothic.ttf'; break;;
				5) TIPOLETRA='Titre.ttf'; break;;
				6) TIPOLETRA='setrixHD.ttf'; break;;
				*) echo && echo " $opcionletra es una opción inválida" && echo;
		esac
	done
	clear
	echo -e "$blue ############################################################ $end"
	echo -e "$blue ###          $green Comienza la modificación del skin         $blue ### $end"
	echo -e "$blue ############################################################ $end"
	echo
	echo -e " Ruta  skin :$yellow $RUTASKIN $end"
	echo -e " Tipo letra :$yellow $TIPOLETRA $end"
	echo ____________________________________________________________
	echo
	printf "%-$(($COLUMNS-10))s"  " 1. Comprobando que existe el skin"
		ERROR=false
		if [ ! -f $RUTASKIN/skin.xml ]; then
			echo "$red No existe el skin que has seleccionado, $end"
			echo "$red comprueba la ruta y vuelve a intentarlo $end"
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
			if [ $? -ne 0 ]; then
			ERROR=true
			fi
	printf "%-$(($COLUMNS-10))s"  " 2. Descargando tipo de letra elegido"
		if [ ! -d $RUTASKIN/fonts ]; then
			mkdir $RUTASKIN/fonts 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -ne 0 ]; then
			ERROR=true
			fi
		fi
		wget -O $RUTASKIN/fonts/$TIPOLETRA https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/$TIPOLETRA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\n La descarga ha fallado.\n Por favor, inténtalo más tarde."
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
	printf "%-$(($COLUMNS-10))s"  " 3. Creando copia de seguridad del skin"
		ERROR=false
		sed -i -e '/<!-- dobleM_nuevo.ttf -->/d' -e 's/<\!-- dobleM_backup //' -e 's/ dobleM_backup -->//' $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
		ERROR=true
		fi
		sed -i 's|<font.*name="Regular".*/>|<!-- dobleM_backup & dobleM_backup --> \n\t& <!-- dobleM_nuevo.ttf -->|' $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
	printf "%-$(($COLUMNS-10))s"  " 4. Modificando el skin"
		ERROR=false
		sed -i -e "/<!-- dobleM_nuevo.ttf -->/ s|<font.*scale|<font filename=\"$RUTASKIN/fonts/$TIPOLETRA\" name=\"Regular\" scale|" $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
	printf "\n$green%s$end\n" " ¡Proceso completado!"
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
}

restaurarSKIN()
{
	cd $CARPETA_SCRIPT
	clear
	echo -e "$blue ############################################################ $end"
	echo -e "$blue ###          $green Comienza la restauración del skin         $blue ### $end"
	echo -e "$blue ############################################################ $end"
	echo
	echo -e " Ruta  skin :$yellow $RUTASKIN $end"
	echo ____________________________________________________________
	echo
	printf "%-$(($COLUMNS-10))s"  " 1. Restaurando skin"
		ERROR=false
		sed -i -e '/<!-- dobleM_nuevo.ttf -->/d' -e 's/<\!-- dobleM_backup //' -e 's/ dobleM_backup -->//' $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
	printf "\n$green%s$end\n" " ¡Proceso completado!"
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
}

reiniciarGUI()
{
	cd $CARPETA_SCRIPT
	clear
	echo -e "$blue Reiniciando en ...$end"
	echo -e " 3"
	sleep 1
	echo -e " 2"
	sleep 1
	echo -e " 1"
	sleep 1
	echo
		init 4 @@ init 3
	MENU
}

# MENU INSTALACION
MENU()
{
while :
do
	clear
	echo -e "$blue ############################################################ $end"
	echo -e "$blue ###                    $green -= dobleM =- $end                   $blue ### $end"
	echo -e "$blue ###             Telegram: $cyan t.me/EPG_dobleM $end             $blue ### $end"
	echo -e "$blue ### ---------------------------------------------------- ### $end"
	echo -e "$blue ###          $blue Instalador para sistema$yellow enigma2 $end          $blue ### $end"
	echo -e "$blue ############################################################ $end"
	echo
	echo -e " 1)$cyan Instalar$green SOURCES$end$cyan para EPG-Import$end"
	echo -e " 2)$cyan Modificar$green SKIN$end$cyan para caracteres especiales$end"
	echo -e " 3)$cyan Restaurar$green SKIN$end$cyan a su estado original$end"
	echo -e " 4)$cyan Reiniciar receptor para aplicar los cambios$end"
	echo
    echo -e " s)$red Salir $end"
	echo
	echo -n " Indica una opción: "
	read opcionmenu
	case $opcionmenu in
		1) clear && instalarEPG;;
		2) clear && VAR="modificar" && elegirSKIN;;
		3) clear && VAR="restaurar" && elegirSKIN;;
		4) clear && reiniciarGUI;;
		s) clear && echo " Gracias por usar el script dobleM" && echo && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit;;
		*) echo && echo " $opcionmenu es una opción inválida" && echo;
	esac
done
}
MENU


#!/bin/bash
# - script creado por dobleM

CARPETA_SCRIPT="$PWD"
CARPETA_SKIN="/usr/share/enigma2"
#CARPETA_SKIN="/mnt/c/pru/skin"

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
		echo " No tienes instalado EPG-Import en tu receptor,"
		echo " realiza la instalación y vuelve a intentarlo"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
	else
		clear
		echo " ############################################################"
		echo " ###        Comienza la instalación de los sources        ###"
		echo " ############################################################"
		echo
			ERROR=false
		printf "%-$(($COLUMNS-10))s"  " 1. Descargando sources"
			wget -O dobleM_E2.sources.tar https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_E2.sources.tar 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
				echo
				echo " La descarga ha fallado"
				echo " Por favor, inténtalo más tarde"
				echo
				echo " Pulsa intro para continuar..."
				read CAD
				MENU
			fi
		printf "%-$(($COLUMNS-10))s"  " 2. Copiando sources"
			tar xf dobleM_E2.sources.tar -C /etc/epgimport/ 2>/dev/null 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
		printf "%-$(($COLUMNS-10))s"  " 3. Borrando temporales"
			rm -r dobleM_E2.sources.tar 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
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
	find $CARPETA_SKIN -name skin.xml | sed -e 's#/skin.xml##' > i_dobleMskin.sh
	LISTADO_SKINS="$(find $CARPETA_SKIN -name skin.xml | nl -s ") " | sed -e 's#/skin.xml##' -e "s#$CARPETA_SKIN/##" -e 's#    ##')"
	clear
	echo " ############################################################"
	echo " ###            Selecciona el skin a modificar            ###"
	echo " ############################################################"
	echo
	while :
	do
		echo "$LISTADO_SKINS"
		echo
		echo " v) Volver al menú"
		echo
		echo " m) Introducir ruta manualmente"
		echo
		echo -n " Indica una opción: "
		read opcionskin
		case $opcionskin in
				1) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				2) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				3) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				4) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				5) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				6) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				7) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				8) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				9) RUTASKIN="$(sed -n "$opcionskin p" i_dobleMskin.sh)"; break;;
				v) MENU;;
				m)  clear
					echo
					echo "Introduce la ruta de tu skin y pulsa INTRO "
					echo
					read RUTASKIN; break;;
				*) echo && echo " $opcionskin es una opción inválida" && echo;
		esac
	done
		if [ ! -f $RUTASKIN/skin.xml ]; then
			echo " No existe el skin que has seleccionado,"
			echo " comprueba la ruta y vuelve a intentarlo"
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
		if [ "$VAR" = "restaurar" ]; then
			echo " MOD"
			restaurarSKIN
		else
			echo " RES"
			modificarSKIN
		fi
}

modificarSKIN()
{
	cd $CARPETA_SCRIPT
	clear
	echo " ############################################################"
	echo " ###          Selecciona el tipo de letra a usar          ###"
	echo " ############################################################"
	echo
	while :
	do
		echo " 1) NanumGothic"
		echo " 2) RocknRollOne"
		echo " 3) Rounded"
		echo " 4) SawarabiGothic"
		echo " 5) Titre"
		echo
		echo -n " Indica una opción: "
		read opcionletra
		case $opcionletra in
				1) TIPOLETRA='NanumGothic.ttf'; break;;
				2) TIPOLETRA='RocknRollOne.ttf'; break;;
				3) TIPOLETRA='Rounded.ttf'; break;;
				4) TIPOLETRA='SawarabiGothic.ttf'; break;;
				5) TIPOLETRA='Titre.ttf'; break;;
				*) echo && echo " $opcionletra es una opción inválida" && echo;
		esac
	done
	clear
	echo " ############################################################"
	echo " ###           Comienza la modificación del skin          ###"
	echo " ############################################################"
	echo
	echo " Ruta  skin : $RUTASKIN"
	echo " Tipo letra : $TIPOLETRA"
	echo ____________________________________________________________
	echo
		ERROR=false
	printf "%-$(($COLUMNS-10))s"  " 1. Descargando tipo de letra elegido"
		if [ ! -d $RUTASKIN/fonts ]; then
			mkdir $RUTASKIN/fonts 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -ne 0 ]; then
			ERROR=true
			fi
		fi
		wget -O $RUTASKIN/fonts/$TIPOLETRA https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/$TIPOLETRA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
		else
			printf "%s%s%s\n" "[" "FAILED" "]"
			echo
			echo " La descarga ha fallado"
			echo " Por favor, inténtalo más tarde"
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
	printf "%-$(($COLUMNS-10))s"  " 2. Creando copia de seguridad del skin"
		sed -i -e '/<!-- dobleM_nuevo.ttf -->/d' -e 's/<\!-- dobleM_backup //' -e 's/ dobleM_backup -->//' $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
		ERROR=true
		fi
		sed -i 's|<font name=.*Regular.*filename=.*scale=.*100.*/>|<!-- dobleM_backup & dobleM_backup --> \n\t& <!-- dobleM_nuevo.ttf -->|' $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log		
		if [ $? -ne 0 ]; then
		ERROR=true
		fi
		sed -i 's|<font filename=.*name=.*Regular.*scale=.*100.*/>|<!-- dobleM_backup & dobleM_backup --> \n\t& <!-- dobleM_nuevo.ttf -->|' $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log		
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
		else
			printf "%s%s%s\n" "[" "FAILED" "]"
		fi
	printf "%-$(($COLUMNS-10))s"  " 3. Modificando el skin"
		sed -i -e "/<!-- dobleM_nuevo.ttf -->/ s|filename=\".*tf\"|filename=\"$RUTASKIN/fonts/$TIPOLETRA\"|" $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
		else
			printf "%s%s%s\n" "[" "FAILED" "]"
		fi	
		printf "\n%s\n" " ¡Proceso completado!"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
}

restaurarSKIN()
{
	cd $CARPETA_SCRIPT
	clear
	echo " ############################################################"
	echo " ###           Comienza la restauración del skin          ###"
	echo " ############################################################"
	echo
	echo " Ruta  skin : $RUTASKIN"
	echo ____________________________________________________________
	echo
		ERROR=false
	printf "%-$(($COLUMNS-10))s"  " 1. Restaurando skin"
		sed -i -e '/<!-- dobleM_nuevo.ttf -->/d' -e 's/<\!-- dobleM_backup //' -e 's/ dobleM_backup -->//' $RUTASKIN/skin.xml 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
		else
			printf "%s%s%s\n" "[" "FAILED" "]"
		fi
	printf "\n%s\n" " ¡Proceso completado!"
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
}

reiniciar()
{
	rm -rf $CARPETA_SCRIPT/i_dobleM*.sh
	clear
	echo " Reiniciando en ..."
	echo " 3"
	sleep 1
	echo " 2"
	sleep 1
	echo " 1"
	sleep 1
	echo
	reboot
}

# MENU INSTALACION
MENU()
{
while :
do
	clear
	echo " ############################################################"
	echo " ###                     -= dobleM =-                     ###"
	echo " ###             Telegram:  t.me/EPG_dobleM               ###"
	echo " ### ---------------------------------------------------- ###"
	echo " ###           Instalador para sistema enigma2            ###"
	echo " ############################################################"
	echo
	echo " 1) Instalar SOURCES para EPG-Import"
	echo " 2) Modificar SKIN para caracteres especiales"
	echo " 3) Restaurar SKIN a su estado original"
	echo " 4) Reiniciar receptor para aplicar los cambios"
	echo
    echo " s) Salir"
	echo
	echo -n " Indica una opción: "
	read opcionmenu
	case $opcionmenu in
		1) clear && instalarEPG;;
		2) clear && VAR="modificar" && elegirSKIN;;
		3) clear && VAR="restaurar" && elegirSKIN;;
		4) clear && reiniciar;;
		s) clear && echo " Gracias por usar el script dobleM" && echo && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit;;
		*) echo && echo " $opcionmenu es una opción inválida" && echo;
	esac
done
}
MENU


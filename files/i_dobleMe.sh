#!/bin/bash
# - script creado por dobleM

CARPETA_SCRIPT="$PWD"
CARPETA_DOBLEM="$CARPETA_SCRIPT/dobleM"
CARPETA_lamedb="/etc/enigma2"
CARPETA_satellites="/etc/tuxbox"
CARPETA_skin="/usr/share/enigma2"

#CARPETA_lamedb="/mnt/c/canales/e2/CAN"
#CARPETA_satellites="/mnt/c/canales/e2/CAN"


receptor="$(cat /etc/hostname)"
arquitectura="$(uname -m)"
imagen_version="$(cat /etc/image-version | grep imageversion | sed -e 's/imageversion=//')"
compilacion="$(cat /etc/image-version | grep imagebuild= | sed -e 's/imagebuild=//')"
ram=$(free | grep Mem  | awk '{ print $4 }')
flash=$(df -h | awk 'NR == 2 {print $4}')

clear
echo Cargando...

if [ -f "dobleM.log" ]; then
	mv "dobleM.log" "dobleM.old.log" 2>>$CARPETA_SCRIPT/dobleM.log
fi

if [ -z "$COLUMNS" ]; then
	COLUMNS=60
fi


instalarCANALES()
{
	cd $CARPETA_SCRIPT
		clear
		while :
		do
			echo " ┌─────────────────────────────────────────────────────────┐"
			echo " │               Seleccione lista a instalar               │"
			echo " └─────────────────────────────────────────────────────────┘"
			echo " 1) Antena individual"
			echo " 2) Antena comunitaría"
			echo
			echo " v) Volver al menú"
			echo
			echo -n " Indica una opción: "
			read opcionsat
			case $opcionsat in
					1) LISTASAT='sed -i -e 's/dobleM_INDIVIDUAL//''; break;;
					2) LISTASAT='sed -i -e 's/^.*dobleM_INDIVIDUAL/\#SERVICE 1:832:d:0:0:0:0:0:0:0:/''; break;;
					v) MENU;;
					*) echo && echo " $opcionsat es una opción inválida" && echo;
			esac
		done		
						# 1		2		3		4		5				6		7	8	9	10	11 12	13	  14   15	   16
						#001,LA 1 HD,La 1 HD,19.2 E,10729V 22000 2/3,Movistar+,7863,0,TV HD,1 : 0: 25: 7863 :41A : 1 : C00000:0:0:0
		NUMCANAL='$1'
		NOMCORTO='$2'
		NOMLARGO='$3'
		PROVIDER='$6'
		REFERENCE='$13":""00"$16":"$14":""000"$15":"$12":0"'
		clear
		while :
		do
			echo " ┌─────────────────────────────────────────────────────────┐"
			echo " │              Formato de la lista a instalar             │"
			echo " └─────────────────────────────────────────────────────────┘"
			echo " 1) Nombre corto"
			echo " 2) Nombre largo"
			echo " 3) Número canal + Nombre corto"
			echo " 4) Número canal + Nombre largo"
			echo
			echo " v) Volver al menú"
			echo
			echo -n " Indica una opción: "
			read opcionlista
			case $opcionlista in
					1) FORMATOLISTA=''"$REFERENCE"' "\n" '"$NOMCORTO"' "\n" "p:"'"$PROVIDER"''; break;;
					2) FORMATOLISTA=''"$REFERENCE"' "\n" '"$NOMLARGO"' "\n" "p:"'"$PROVIDER"''; break;;
					3) FORMATOLISTA=''"$REFERENCE"' "\n" '"$NUMCANAL"' " " '"$NOMCORTO"' "\n" "p:"'"$PROVIDER"''; break;;
					4) FORMATOLISTA=''"$REFERENCE"' "\n" '"$NUMCANAL"' " " '"$NOMLARGO"' "\n" "p:"'"$PROVIDER"''; break;;
					v) MENU;;
					*) echo && echo " $opcionlista es una opción inválida" && echo;
			esac
		done
		clear
		while :
		do
			echo " ┌─────────────────────────────────────────────────────────┐"
			echo " │                  Bouquets con categorías                │"
			echo " └─────────────────────────────────────────────────────────┘"
			echo " 1) Si"
			echo " 2) No"
			echo
			echo " v) Volver al menú"
			echo
			echo -n " Indica una opción: "
			read opcioncatbouquet
			case $opcioncatbouquet in
					1) ELIMCATBOU=; break;;
					2) ELIMCATBOU='sed -i -e '/----/d' -e '/1:64:/d''; break;;
					v) MENU;;
					*) echo && echo " $opcioncatbouquet es una opción inválida" && echo;
			esac
		done
		echo		
		clear
		echo " ┌─────────────────────────────────────────────────────────┐"
		echo " │      Comienza la instalación de la lista de canales     │"
		echo " └─────────────────────────────────────────────────────────┘"
		echo
			ERROR=false
		printf "%-$(($COLUMNS-10))s"  " 1. Descargando lista de canales"
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -ne 0 ]; then
				ERROR=true
			fi			
			wget -qO dobleM_E2.canales.tar https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_E2.canales.tar 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s$green%s$end%s\n" "[" "  OK  " "]"
			else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
				echo
				echo " La descarga ha fallado"
				echo " Por favor, inténtalo más tarde"
				echo
				echo " Pulsa intro para continuar..."
				read CAD
				MENU
			fi
		printf "%-$(($COLUMNS-10))s"  " 2. Preparando lista de canales"
			tar xf dobleM_E2.canales.tar -C $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
			
			
			#iconv -f windows-1252 -t utf-8 dobleM_export.txt > dobleM_export
			sed -i '/,,,/d' $CARPETA_DOBLEM/dobleM_export
			sed -i -e "s/_/,/g" -e "s/,19,/,25,/" $CARPETA_DOBLEM/dobleM_export
			awk -F, '{print '"$FORMATOLISTA"'}' $CARPETA_DOBLEM/dobleM_export > $CARPETA_DOBLEM/dobleM_lamedb
			cat $CARPETA_DOBLEM/dobleM_transponders > $CARPETA_DOBLEM/lamedb
			echo "services" >> $CARPETA_DOBLEM/lamedb
			cat $CARPETA_DOBLEM/dobleM_lamedb >> $CARPETA_DOBLEM/lamedb
			echo "end" >> $CARPETA_DOBLEM/lamedb
			$ELIMCATBOU $CARPETA_DOBLEM/*.tv
			$LISTASAT $CARPETA_DOBLEM/*.tv
			
			
			
		printf "%-$(($COLUMNS-10))s"  " 3. Haciendo copia de seguridad"
			if [ -f "$CARPETA_SCRIPT/Backup_canales_$(date +"%Y-%m-%d").tar.xz" ]; then
				FILE="Backup_canales_$(date +"%Y-%m-%d_%H.%M.%S").tar.xz"
				tar -cjf $CARPETA_SCRIPT/$FILE $CARPETA_lamedb/*.tv $CARPETA_lamedb/*.radio $CARPETA_lamedb/lamedb $CARPETA_lamedb/blacklist $CARPETA_lamedb/whitelist $CARPETA_satellites/satellites.xml 2>>$CARPETA_SCRIPT/dobleM.log
			else
				FILE="Backup_canales_$(date +"%Y-%m-%d").tar.xz"
				tar -cjf $CARPETA_SCRIPT/$FILE $CARPETA_lamedb/*.tv $CARPETA_lamedb/*.radio $CARPETA_lamedb/lamedb $CARPETA_lamedb/blacklist $CARPETA_lamedb/whitelist $CARPETA_satellites/satellites.xml 2>>$CARPETA_SCRIPT/dobleM.log
			fi
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi		

			
			
			
			
			
			
		printf "%-$(($COLUMNS-10))s"  " 4. Borrando lista de canales vieja"
			rm $CARPETA_lamedb/*.tv 2>>$CARPETA_SCRIPT/dobleM.log
			rm $CARPETA_lamedb/*.radio 2>>$CARPETA_SCRIPT/dobleM.log
			rm $CARPETA_lamedb/lamedb 2>>$CARPETA_SCRIPT/dobleM.log
			rm $CARPETA_lamedb/blacklist 2>>$CARPETA_SCRIPT/dobleM.log
			rm $CARPETA_lamedb/whitelist 2>>$CARPETA_SCRIPT/dobleM.log
			rm $CARPETA_satellites/satellites.xml 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
		printf "%-$(($COLUMNS-10))s"  " 5. Copiando lista de canales nueva"
			cp $CARPETA_DOBLEM/*.tv $CARPETA_lamedb 2>>$CARPETA_SCRIPT/dobleM.log
			cp $CARPETA_DOBLEM/*.radio $CARPETA_lamedb 2>>$CARPETA_SCRIPT/dobleM.log
			cp $CARPETA_DOBLEM/lamedb $CARPETA_lamedb 2>>$CARPETA_SCRIPT/dobleM.log
			cp $CARPETA_DOBLEM/blacklist $CARPETA_lamedb 2>>$CARPETA_SCRIPT/dobleM.log
			cp $CARPETA_DOBLEM/whitelist $CARPETA_lamedb 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
		printf "%-$(($COLUMNS-10))s"  " 6. Copiando satellites.xml"
			cp $CARPETA_DOBLEM/satellites.xml $CARPETA_satellites 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
		printf "%-$(($COLUMNS-10))s"  " 7. Recargando lista de canales"
			wget -qO - http://127.0.0.1/web/servicelistreload?mode=0 >/dev/null 2>&1
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi			
		printf "%-$(($COLUMNS-10))s"  " 8. Eliminando archivos temporales"
			rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
			if [ $? -eq 0 ]; then
				printf "%s$green%s$end%s\n" "[" "  OK  " "]"
			else
				printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			fi
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
}

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
		echo " ┌─────────────────────────────────────────────────────────┐"
		echo " │          Comienza la instalación de los sources         │"
		echo " └─────────────────────────────────────────────────────────┘"
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
			tar xf dobleM_E2.sources.tar -C /etc/epgimport/ 2>>$CARPETA_SCRIPT/dobleM.log
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
	find $CARPETA_skin -name skin.xml | sed -e 's#/skin.xml##' > i_dobleMskin.sh
	LISTADO_SKINS="$(find $CARPETA_skin -name skin.xml | nl -s ") " | sed -e 's#/skin.xml##' -e "s#$CARPETA_skin/##" -e 's#    ##')"
	clear
	echo " ┌─────────────────────────────────────────────────────────┐"
	echo " │              Selecciona el skin a modificar             │"
	echo " └─────────────────────────────────────────────────────────┘"
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
	while :
	do
		echo " ┌─────────────────────────────────────────────────────────┐"
		echo " │            Selecciona el tipo de letra a usar           │"
		echo " └─────────────────────────────────────────────────────────┘"
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
	echo " ┌─────────────────────────────────────────────────────────┐"
	echo " │             Comienza la modificación del skin           │"
	echo " └─────────────────────────────────────────────────────────┘"
	echo " Ruta  skin : $RUTASKIN"
	echo " Tipo letra : $TIPOLETRA"
	echo " ───────────────────────────────────────────────────────────"
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
	echo " ┌─────────────────────────────────────────────────────────┐"
	echo " │             Comienza la restauración del skin           │"
	echo " └─────────────────────────────────────────────────────────┘"
	echo " Ruta  skin : $RUTASKIN"
	echo " ───────────────────────────────────────────────────────────"
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
	echo " ┌─────────────────────────────────────────────────────────┐"
	echo " │                       -= dobleM =-                      │"
	echo " │               Telegram:  t.me/EPG_dobleM                │"
	echo " ├─────────────────────────────────────────────────────────┘"
	echo " ├── Receptor: $receptor"
	echo " ├── Imagen Version: OpenATV $imagen_version"
    echo " ├── Fecha Compilacion:$compilacion"
	echo " ├── Arquitectura: $arquitectura"
	echo " ├── Ram Libre: $ram kb"
	echo " └── Flash Libre: $flash gb"	
	echo
	echo " 1) Instalar lista de CANALES (en PRUEBAS, no usar)"
	echo " 2) Instalar SOURCES para EPG-Import"
	echo " 3) Modificar SKIN para caracteres especiales"
	echo " 4) Restaurar SKIN a su estado original"
	echo " 5) Reiniciar receptor para aplicar los cambios"
	echo
    echo " s) Salir"
	echo
	echo -n " Indica una opción: "
	read opcionmenu
	case $opcionmenu in
		1) clear && instalarCANALES;;
		2) clear && instalarEPG;;
		3) clear && VAR="modificar" && elegirSKIN;;
		4) clear && VAR="restaurar" && elegirSKIN;;
		5) clear && reiniciar;;
		s) clear && echo " Gracias por usar el script dobleM" && echo && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit;;
		*) echo && echo " $opcionmenu es una opción inválida" && echo;
	esac
done
}
MENU


#!/bin/bash
# - Script creado por dobleM
#Formatear texto con colores: https://unix.stackexchange.com/a/92568
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
end='\e[0m'

NOMBRE_APP="dobleM"
NOMBRE_APP_IPTV="dobleM-IPTV"
CARPETA_SCRIPT="$PWD"

clear
echo Cargando...

if [ -f "dobleM.log" ]; then
	mv "dobleM.log" "dobleM.old.log" 2>>$CARPETA_SCRIPT/dobleM.log
fi

if [ -z "$COLUMNS" ]; then
	COLUMNS=80
fi

# Comprobamos que estén instalados curl y wget
command -v sudo >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'sudo'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado." && rm -rf $CARPETA_SCRIPT/i_*.sh; exit 1; }
command -v stat >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'stat'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado." && rm -rf $CARPETA_SCRIPT/i_*.sh; exit 1; }
command -v curl >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'curl'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado." && rm -rf $CARPETA_SCRIPT/i_*.sh; exit 1; }
command -v wget >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'wget'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado." && rm -rf $CARPETA_SCRIPT/i_*.sh; exit 1; }

# Detectando sistema operativo
	SYSTEM_DETECTOR="$(uname -a)"
	if [ "${SYSTEM_DETECTOR#*"synology"}" != "$SYSTEM_DETECTOR" ]; then
		SYSTEM_INFO="Synology/XPEnology"
	else
		SYSTEM_INFO="$(sed -e '/PRETTY_NAME=/!d' -e 's/PRETTY_NAME=//g' /etc/*-release)" 2>>$CARPETA_SCRIPT/dobleM.log
	fi

# Sistema elegido:	 1-Docker
	if [ "$1" = "Docker" ]; then
		SISTEMA_ELEGIDO="Docker"
		SYSTEM=1
	fi
	case $SYSTEM in
	1) #Docker
		CONTAINER_NAME="tvheadend"
		TVHEADEND_CONFIG="/config"
		TVHEADEND_GRABBER="/usr/bin"
		TVHEADEND_CONFIG_DIR="$CONTAINER_NAME:/config"
		TVHEADEND_GRABBER_DIR="$CONTAINER_NAME:/usr/bin"
		DOBLEM_DIR="$CARPETA_SCRIPT/dobleM"
		FFMPEG_COMMAND="/usr/bin/ffmpeg -i \$1 -c copy -f mpegts pipe:1"
		;;
	esac

# Parar/Iniciar tvheadend
PARAR_TVHEADEND()
{
SERVICE_ERROR=false
	case $SYSTEM in
	1) #Docker
		docker stop tvheadend 1>$CARPETA_SCRIPT/dobleM.log 2>&1
	esac
	if [ $? -eq 0 ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
	else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		SERVICE_ERROR=true
	fi
}
INICIAR_TVHEADEND()
{
SERVICE_ERROR=false
	case $SYSTEM in
	1) #Docker
		docker restart tvheadend 1>$CARPETA_SCRIPT/dobleM.log 2>&1
	esac
	if [ $? -eq 0 ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
	else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		SERVICE_ERROR=true
	fi
}

# INSTALADOR SATELITE
install()
{
	clear
	LIST_ERROR=false
	GRABBER_ERROR=false

# Pedimos el formato de la guía de programación
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###            Elección del formato de la guía de programación            ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$yellow Elige el formato de la guía de programación: $end"
		echo -e " 1) Guía con etiquetas de colores"
		echo -e " 2) Guía sin etiquetas de colores"
		echo -e " 3) Guía con etiquetas de colores y título en una sola linea"
		echo -e " 4) Guía sin etiquetas de colores, título en una sola linea y sin caracteres especiales"
		echo
		echo -n " Indica una opción: "
		read opcion1
		case $opcion1 in
				1) FORMATO_IDIOMA_EPG='\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
				2) FORMATO_IDIOMA_EPG='\n\t\t"eng",\n\t\t"spa",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
				3) FORMATO_IDIOMA_EPG='\n\t\t"ger",\n\t\t"eng",\n\t\t"spa",\n\t\t"fre"\n\t'; break;;
				4) FORMATO_IDIOMA_EPG='\n\t\t"fre",\n\t\t"eng",\n\t\t"ger",\n\t\t"spa"\n\t'; break;;
				*) echo "$opcion1 es una opción inválida";
		esac
	done
		echo
	while :
	do
		echo -e "$yellow Elige que tipo de imágenes quieres que aparezcan en la guía: $end"
		echo -e " 1) Imágenes tipo poster"
		echo -e " 2) Imágenes tipo fanart"
		echo
		echo -n " Indica una opción: "
		read opcion2
		case $opcion2 in
				1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g''; break;;
				2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g''; break;;
				*) echo "$opcion2 es una opción inválida";
		esac
	done
	
# Iniciamos instalación satélite
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###        Iniciando instalación de canales satélite y EPG dobleM         ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
	echo
	
# Preparamos DOBLEM_DIR y descargamos el fichero dobleM.tar.xz
	printf "%-$(($COLUMNS-10+1))s"  " 1. Descargando lista de canales satélite"
		ERROR=false
		rm -rf $DOBLEM_DIR && mkdir $DOBLEM_DIR && cd $DOBLEM_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.tar.xz 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\nLa lista de canales satélite no se ha podido descargar.\nPor favor, inténtalo más tarde."
			MENU
		fi
	# Descomprimimos el tar y marcamos con dobleM al final todos los archivos de la carpeta /channel/config/ y /channel/tag/
	tar -xf "dobleM.tar.xz"
		sed -i '/^\}$/,$d' $DOBLEM_DIR/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i '/^\}$/,$d' $DOBLEM_DIR/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i "\$a}\n$NOMBRE_APP" $DOBLEM_DIR/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i "\$a}\n$NOMBRE_APP" $DOBLEM_DIR/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log

# Configuramos ficheros para tvheadend y grabber para satelite
	printf "%-$(($COLUMNS-10))s"  " 2. Configurando ficheros para tvheadend"
		ERROR=false
		sed -i -- "s,dobleMgrab,$TVHEADEND_GRABBER,g" $DOBLEM_DIR/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		$FORMATO_IMAGEN_GRABBER $DOBLEM_DIR/grabber/tv_grab_EPG_dobleM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi	
		docker cp $TVHEADEND_CONFIG_DIR/config $DOBLEM_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi		
		docker cp $TVHEADEND_CONFIG_DIR/epggrab/config $DOBLEM_DIR/epggrab/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi		
		#Idiomas EPG config tvheadend		
		sed -i 's/"language": \[/"language": \[\ndobleM/g' $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/dobleM/,/],/d' $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s/\"language\": \[/\"language\": \[$FORMATO_IDIOMA_EPG\],/g" $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		#picons config tvheadend
		sed -i '/"chiconscheme": .*,/d' $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/"piconpath": .*,/d' $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/"piconscheme": .*,/d' $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"prefer_picon": .*,/"prefer_picon": false,\n\t"chiconscheme": 2,\n\t"piconpath": "file:\/\/TVHEADEND_CONFIG\/picons",\n\t"piconscheme": 0,/g' $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s,TVHEADEND_CONFIG,$TVHEADEND_CONFIG,g" $DOBLEM_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		#cron y grabber config epggrab
		sed -i -e '/channel_rename/d' -e '/channel_renumber/d' -e '/channel_reicon/d' -e '/epgdb_periodicsave/d' -e '/epgdb_saveafterimport/d' -e '/cron/d' -e '/int_initial/d' -e '/ota_initial/d' -e '/ota_cron/d' -e '/ota_timeout/d' $DOBLEM_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '2i\\t"channel_rename": false,\n\t"channel_renumber": false,\n\t"channel_reicon": false,\n\t"epgdb_periodicsave": 0,\n\t"epgdb_saveafterimport": true,\n\t"cron": "# Se ejecuta todos los días a las 8:10\\n10 8 * * *",\n\t"int_initial": true,\n\t"ota_initial": false,\n\t"ota_cron": "# Configuración modificada por dobleM\\n# Desactivados todos los OTA grabber",\n\t"ota_timeout": 600,' $DOBLEM_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"enabled": .*,/"enabled": false,/g' $DOBLEM_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/tv_grab_EPG_dobleM/,/},/d' $DOBLEM_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/tv_grab_EPG_dobleM-IPTV/,/},/d' $DOBLEM_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"modules": {/"modules": {\n\t\t"TVHEADEND_GRABBER\/tv_grab_EPG_dobleM": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - Movistar+",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 5\n\t\t},\n\t\t"TVHEADEND_GRABBER\/tv_grab_EPG_dobleM-IPTV": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - IPTV",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 4\n\t\t},/g' $DOBLEM_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s,TVHEADEND_GRABBER,$TVHEADEND_GRABBER,g" $DOBLEM_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		GRABBER_ERROR=true
		fi				
# Borramos configuración actual menos "channel" y "epggrab" de tvheadend
	printf "%-$(($COLUMNS-10+1))s"  " 3. Eliminando instalación anterior"
		ERROR=false
		docker exec tvheadend sh -c "rm -rf /config/bouquet/" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker exec tvheadend sh -c "rm -rf /config/channel/" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker exec tvheadend sh -c "rm -rf /config/input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker exec tvheadend sh -c "rm -rf /config/picons/" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker exec tvheadend sh -c "rm -rf /config/epggrab/" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker exec tvheadend sh -c "rm -f /config/config" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker exec tvheadend sh -c "rm -f /usr/bin/tv_grab_EPG_dobleM" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
			
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 4. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
		
# Empezamos a copiar los archivos necesarios
	printf "%-$(($COLUMNS-10+1))s"  " 5. Instalando lista de canales satélite"
		ERROR=false		
		docker cp $DOBLEM_DIR/dobleM.ver $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker cp $DOBLEM_DIR/bouquet/. $TVHEADEND_CONFIG_DIR/bouquet/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker cp $DOBLEM_DIR/channel/. $TVHEADEND_CONFIG_DIR/channel/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker cp $DOBLEM_DIR/input/. $TVHEADEND_CONFIG_DIR/input/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker cp $DOBLEM_DIR/picons/. $TVHEADEND_CONFIG_DIR/picons/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker cp $DOBLEM_DIR/config $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi

# Instalación de grabber. Copiamos carpeta epggrab y grabber nuevo.
	printf "%-$(($COLUMNS-10+1))s"  " 6. Instalando grabber para satélite"
		ERROR=false	
		docker cp $DOBLEM_DIR/epggrab/. $TVHEADEND_CONFIG_DIR/epggrab/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 -a $SYSTEM -ne 2 ]; then
			ERROR=true
		fi	
		chmod +x $DOBLEM_DIR/grabber/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		docker cp $DOBLEM_DIR/grabber/tv_grab_EPG_dobleM $TVHEADEND_GRABBER_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi

# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 7. Eliminando archivos temporales"
		rm -rf $DOBLEM_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
		
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 8. Iniciando tvheadend"
		cd $CARPETA_SCRIPT
		INICIAR_TVHEADEND	
		
# Fin instalación
if [ "$LIST_ERROR" = true -o "$GRABBER_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: El proceso no se ha completado correctamente."
	printf "$red%s$end\n" " Revisa los errores anteriores para intentar solucionarlo."
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
elif [ "$SERVICE_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: tvheadend no se ha podido reiniciar de forma automática."
	printf "$red%s$end\n" " Es necesario reiniciar tvheadend manualmente para aplicar los cambios."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
	echo
	echo " Acuerdate de activar el sintonizador y asignar \"Red DVB-S\" en la pestaña:"
	echo "   Configuración >> Entradas DVB >> Adaptadores de TV"
	echo
	echo " La primera captura de EPG tardará unos minutos hasta que todos"
	echo " los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
else
	printf "\n$green%s$end\n" " ¡Proceso completado!"
	echo
	echo " Acuerdate de activar el sintonizador y asignar \"Red DVB-S\" en la pestaña:"
	echo "   Configuración >> Entradas DVB >> Adaptadores de TV"
	echo
	echo " La primera captura de EPG tardará unos minutos hasta que todos"
	echo " los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
fi
}

# MENU INSTALACION
MENU()
{
while :
do
ver_local=`docker exec tvheadend sh -c "cat /config/dobleM.ver" 2>/dev/null`
ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.ver 2>/dev/null`
ver_local_IPTV=`docker exec tvheadend sh -c "cat /config/dobleM-IPTV.ver" 2>/dev/null`
ver_web_IPTV=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-IPTV.ver 2>/dev/null`
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                           $green -= dobleM =- $end                             $blue ### $end"
	echo -e "$blue ###                     Telegram: $cyan t.me/EPG_dobleM $end                      $blue ### $end"
	echo -e "$blue ### --------------------------------------------------------------------- ###$end"
	echo -e "$blue ###      $red¡ PRECAUCION! $end  $blue Comprueba que el sistema y los directorios      ### $end"
	echo -e "$blue ###      de instalación sean correctos, en caso de duda no continues      ### $end"
	echo -e "$blue ############################################################################# $end"
	echo
	echo -e " Sistema seleccionado:$magenta $SISTEMA_ELEGIDO $end"
	echo
	echo -e " Sistema    detectado:$yellow $SYSTEM_INFO $end"
	echo -e " Nombre de contenedor:$yellow $CONTAINER_NAME $end"
	echo -e " Directorio tvheadend:$yellow $TVHEADEND_CONFIG $end"
	echo -e " Directorio   grabber:$yellow $TVHEADEND_GRABBER $end"
	echo
	echo -e " Versión SATELITE instalada:$red $ver_local $end --->  Nueva versión:$green $ver_web $end"
	echo -e " Versión   IPTV   instalada:$red $ver_local_IPTV $end --->  Nueva versión:$green $ver_web_IPTV $end"
	echo _______________________________________________________________________________
	echo
#	echo -e " 1)$green Hacer copia de seguridad de tvheadend $end"
	echo -e " 2)$cyan Instalar lista de canales$yellow SATELITE $end+ picons, grabber y configurar tvheadend $end"
#	echo -e " 3)$cyan Instalar lista de canales$yellow IPTV $end+ picons, grabber y configurar tvheadend $end"
#	echo -e " 4)$cyan Cambiar el formato de la guía de programación $end"
#	echo -e " 5)$cyan Hacer una limpieza$red TOTAL$end$cyan de tvheadend $end"
#	echo -e " 6)$green Restaurar copia de seguridad $end(Usa el fichero mas reciente que encuentre) $end"
    echo -e " 7)$magenta Volver $end"
    echo -e " 8)$red Salir $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) clear && backup;;
		2) clear && install;;
		3) clear && installIPTV;;
		4) clear && cambioformatoEPG;;
		5) clear && limpiezatotal;;
		6) clear && resbackup;;
		7) rm -rf $CARPETA_SCRIPT/i_dobleMd.sh && clear && sh $CARPETA_SCRIPT/i_dobleM.sh; break;;
		8) rm -rf $CARPETA_SCRIPT/i_*.sh; exit;;
		*) echo "$opcion es una opción inválida\n";
	esac
done
}
MENU

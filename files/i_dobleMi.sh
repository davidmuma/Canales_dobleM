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
CARPETA_DOBLEM="$CARPETA_SCRIPT/dobleM"

clear
echo Cargando...

if [ -f "dobleM.log" ]; then
	mv "dobleM.log" "dobleM.old.log" 2>>$CARPETA_SCRIPT/dobleM.log
fi

if [ -z "$COLUMNS" ]; then
	COLUMNS=80
fi

# Comprobamos que estén instalados stat y curl
command -v stat >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'stat'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado." && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit 1; }
command -v curl >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'curl'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado." && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit 1; }
# Detectando sistema operativo
	SYSTEM_DETECTOR="$(uname -a)"
	if [ "${SYSTEM_DETECTOR#*"synology"}" != "$SYSTEM_DETECTOR" ]; then
		SYSTEM_INFO="Synology/XPEnology"
	else
		SYSTEM_INFO="$(sed -e '/PRETTY_NAME=/!d' -e 's/PRETTY_NAME=//g' /etc/*-release)" 2>>$CARPETA_SCRIPT/dobleM.log
	fi

# Sistema elegido:	 1-Synology/XPEnology   2-LibreELEC/OpenELEC  3-AlexELEC  4-Linux	 5-Qnap
	if [ "$1" = "Synology" ]; then
		SISTEMA_ELEGIDO="Synology/XPEnology"
		SYSTEM=1
	elif [ "$1" = "Libreelec" ]; then
		SISTEMA_ELEGIDO="LibreELEC/OpenELEC"
		SYSTEM=2
	elif [ "$1" = "Coreelec" ]; then
		SISTEMA_ELEGIDO="CoreELEC"
		SYSTEM=3
	elif [ "$1" = "Alexelec" ]; then
		SISTEMA_ELEGIDO="AlexELEC"
		SYSTEM=4
	elif [ "$1" = "Linux" ]; then
		SISTEMA_ELEGIDO="Linux"
		SYSTEM=5
	elif [ "$1" = "Qnap" ]; then
		SISTEMA_ELEGIDO="Qnap"
		SYSTEM=6
	fi
	case $SYSTEM in
	1) #Synology/XPEnology
		TVHEADEND_SERVICE="$(synoservicecfg --list | grep tvheadend)" 2>>$CARPETA_SCRIPT/dobleM.log #"pkgctl-tvheadend-testing"
		if [ $? -ne 0 ]; then
			SERVICES_MANAGEMENT="OLD"
		else
			SERVICES_MANAGEMENT="NEW"
		fi
#		TVHEADEND_USER="$(cut -d: -f1 /etc/passwd | grep tvheadend)" 2>>$CARPETA_SCRIPT/dobleM.log #"sc-tvheadend-testing"
#		TVHEADEND_GROUP="$(id -gn $TVHEADEND_USER)" 2>>$CARPETA_SCRIPT/dobleM.log #"users"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
		TVHEADEND_CONFIG_DIR="/var/packages/$(ls /var/packages/ | grep tvheadend)/target/var" 2>>$CARPETA_SCRIPT/dobleM.log #"/var/packages/tvheadend-testing/target/var"
		TVHEADEND_GRABBER_DIR="/usr/local/bin"
		TVHEADEND_USER=$(stat -c %U $TVHEADEND_CONFIG_DIR/config) 2>>$CARPETA_SCRIPT/dobleM.log
		TVHEADEND_GROUP=$(stat -c %G $TVHEADEND_CONFIG_DIR/config) 2>>$CARPETA_SCRIPT/dobleM.log
		FFMPEG_DIR="/usr/local/ffmpeg/bin/ffmpeg"
		FFMPEG_COMMAND='-loglevel fatal -i "$1" -vcodec copy -acodec copy -f mpegts pipe:1'
		;;
	2) #LibreELEC/OpenELEC
		TVHEADEND_SERVICE="$(systemctl list-unit-files --type=service | grep tvheadend | tr -s ' ' | cut -d' ' -f1)" 2>>$CARPETA_SCRIPT/dobleM.log #"service.tvheadend42.service"
		TVHEADEND_USER="root"
		TVHEADEND_GROUP="video"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
		TVHEADEND_CONFIG_DIR="/storage/.kodi/userdata/addon_data/$(ls /storage/.kodi/userdata/addon_data/ | grep tvheadend)" 2>>$CARPETA_SCRIPT/dobleM.log #"/storage/.kodi/userdata/addon_data/service.tvheadend42"
		TVHEADEND_GRABBER_DIR="/storage/.kodi/addons/$(ls /storage/.kodi/addons/ | grep tvheadend)/bin" 2>>$CARPETA_SCRIPT/dobleM.log #"/storage/.kodi/addons/service.tvheadend42/bin"
		FFMPEG_DIR="/storage/.kodi/addons/tools.ffmpeg-tools/bin/ffmpeg"
		FFMPEG_COMMAND='-loglevel fatal -i "$1" -vcodec copy -acodec copy -f mpegts pipe:1'
		;;
	3) #CoreELEC
		TVHEADEND_SERVICE="service.tvheadend43.service" 2>>$CARPETA_SCRIPT/dobleM.log #"$(systemctl list-unit-files --type=service | grep tvheadend | tr -s ' ' | cut -d' ' -f1)"
		TVHEADEND_USER="root"
		TVHEADEND_GROUP="video"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
		TVHEADEND_CONFIG_DIR="/storage/.kodi/userdata/addon_data/service.tvheadend43" 2>>$CARPETA_SCRIPT/dobleM.log #"/storage/.kodi/userdata/addon_data/$(ls /storage/.kodi/userdata/addon_data/ | grep tvheadend)"
		TVHEADEND_GRABBER_DIR="/storage/.kodi/addons/service.tvheadend43/bin" 2>>$CARPETA_SCRIPT/dobleM.log #"/storage/.kodi/addons/$(ls /storage/.kodi/addons/ | grep tvheadend)/bin"
		FFMPEG_DIR="/storage/.kodi/addons/tools.ffmpeg-tools/bin/ffmpeg"
		FFMPEG_COMMAND='-loglevel fatal -i "$1" -vcodec copy -acodec copy -f mpegts pipe:1'
		;;
	4) #AlexElec
		TVHEADEND_SERVICE="$(systemctl list-unit-files --type=service | grep tvheadend | tr -s ' ' | cut -d' ' -f1)" 2>>$CARPETA_SCRIPT/dobleM.log #"service.tvheadend42.service"
		TVHEADEND_USER="root"
		TVHEADEND_GROUP="video"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
		TVHEADEND_CONFIG_DIR="/storage/.config/tvheadend" 2>>$CARPETA_SCRIPT/dobleM.log
		TVHEADEND_GRABBER_DIR="/storage/.config/tvheadend/bin" 2>>$CARPETA_SCRIPT/dobleM.log
		FFMPEG_DIR="/usr/bin/ffmpeg"
		FFMPEG_COMMAND='-loglevel fatal -i "$1" -vcodec copy -acodec copy -f mpegts pipe:1'
		;;
	5) #Linux
		TVHEADEND_SERVICE="$(systemctl list-unit-files --type=service | grep tvheadend | tr -s ' ' | cut -d' ' -f1)" 2>>$CARPETA_SCRIPT/dobleM.log #"tvheadend.service"
		TVHEADEND_USER="$(cut -d: -f1 /etc/passwd | grep -E 'tvheadend|hts')" 2>>$CARPETA_SCRIPT/dobleM.log #"hts"
		TVHEADEND_GROUP="video" #"$(id -gn $TVHEADEND_USER)"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
		TVHEADEND_CONFIG_DIR="/home/hts/.hts/tvheadend"
		TVHEADEND_GRABBER_DIR="/usr/bin"
		FFMPEG_DIR="/usr/bin/ffmpeg"
		FFMPEG_COMMAND='-loglevel fatal -i "$1" -vcodec copy -acodec copy -f mpegts pipe:1'
		;;
	6) #Qnap
		TVHEADEND_SERVICE="tvheadend"
		TVHEADEND_USER="admin"
        TVHEADEND_GROUP="administrators"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
        TVHEADEND_CONFIG_DIR="/share/CACHEDEV1_DATA/.qpkg/TVHeadend/config"
        TVHEADEND_GRABBER_DIR="/usr/bin"
		FFMPEG_DIR="/share/CACHEDEV1_DATA/.qpkg/ffmpeg/ffmpeg"
		FFMPEG_COMMAND='-loglevel fatal -i "$1" -vcodec copy -acodec copy -f mpegts pipe:1'
		;;
	esac

# Parar/Iniciar tvheadend
PARAR_TVHEADEND()
{
SERVICE_ERROR=false
	case $SYSTEM in
		1) #Synology/XPEnology
			if [ "$SERVICES_MANAGEMENT" = "OLD" ]; then
				"/var/packages/$(ls /var/packages/ | grep tvheadend)/scripts/start-stop-status" stop 1>>$CARPETA_SCRIPT/dobleM.log 2>&1
			else
				stop -q $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log
			fi;;
		2) #LibreELEC/OpenELEC
			systemctl stop $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		3) #CoreELEC
			systemctl stop $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		4) #AlexElec
			systemctl stop $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		5) #Linux
			service tvheadend stop 1>>$CARPETA_SCRIPT/dobleM.log 2>&1;; #service tvheadend stop
		6) #Qnap
			/etc/init.d/TVHeadend.sh stop 2>>$CARPETA_SCRIPT/dobleM.log;;
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
		1) #Synology/XPEnology
			if [ "$SERVICES_MANAGEMENT" = "OLD" ]; then
				"/var/packages/$(ls /var/packages/ | grep tvheadend)/scripts/start-stop-status" start 1>>$CARPETA_SCRIPT/dobleM.log 2>&1
			else
				start -q $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log
			fi;;
		2) #LibreELEC/OpenELEC
			systemctl start $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		3) #CoreELEC
			systemctl start $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		4) #AlexElec
			systemctl start $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		5) #Linux
			service tvheadend start 1>>$CARPETA_SCRIPT/dobleM.log 2>&1;; #service tvheadend start
		6) #Qnap
			/etc/init.d/TVHeadend.sh start 2>>$CARPETA_SCRIPT/dobleM.log;;
	esac
	if [ $? -eq 0 ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
	else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		SERVICE_ERROR=true
	fi
}

# Variables config tvheadend
if [ -d $TVHEADEND_CONFIG_DIR/bouquet ]; then
	TVHEADEND_BOUQUET_USER=$(stat -c %U $TVHEADEND_CONFIG_DIR/bouquet) 2>/dev/null
	TVHEADEND_BOUQUET_GROUP=$(stat -c %G $TVHEADEND_CONFIG_DIR/bouquet) 2>/dev/null
	TVHEADEND_BOUQUET_PERMISSIONS=$(stat -c %a $TVHEADEND_CONFIG_DIR/bouquet) 2>/dev/null
	if [ $? -ne 0 ]; then
		TVHEADEND_BOUQUET_USER=$TVHEADEND_USER
		TVHEADEND_BOUQUET_GROUP=$TVHEADEND_GROUP
		TVHEADEND_BOUQUET_PERMISSIONS=$TVHEADEND_PERMISSIONS
	fi
else
	TVHEADEND_BOUQUET_USER=$TVHEADEND_USER
	TVHEADEND_BOUQUET_GROUP=$TVHEADEND_GROUP
	TVHEADEND_BOUQUET_PERMISSIONS=$TVHEADEND_PERMISSIONS
fi

if [ -d $TVHEADEND_CONFIG_DIR/channel ]; then
	TVHEADEND_CHANNEL_USER=$(stat -c %U $TVHEADEND_CONFIG_DIR/channel) 2>/dev/null
	TVHEADEND_CHANNEL_GROUP=$(stat -c %G $TVHEADEND_CONFIG_DIR/channel) 2>/dev/null
	TVHEADEND_CHANNEL_PERMISSIONS=$(stat -c %a $TVHEADEND_CONFIG_DIR/channel) 2>/dev/null
	if [ $? -ne 0 ]; then
		TVHEADEND_CHANNEL_USER=$TVHEADEND_USER
		TVHEADEND_CHANNEL_GROUP=$TVHEADEND_GROUP
		TVHEADEND_CHANNEL_PERMISSIONS=$TVHEADEND_PERMISSIONS
	fi
else
	TVHEADEND_CHANNEL_USER=$TVHEADEND_USER
	TVHEADEND_CHANNEL_GROUP=$TVHEADEND_GROUP
	TVHEADEND_CHANNEL_PERMISSIONS=$TVHEADEND_PERMISSIONS
fi

if [ -d $TVHEADEND_CONFIG_DIR/epggrab ]; then
	TVHEADEND_EPGGRAB_USER=$(stat -c %U $TVHEADEND_CONFIG_DIR/epggrab) 2>/dev/null
	TVHEADEND_EPGGRAB_GROUP=$(stat -c %G $TVHEADEND_CONFIG_DIR/epggrab) 2>/dev/null
	TVHEADEND_EPGGRAB_PERMISSIONS=$(stat -c %a $TVHEADEND_CONFIG_DIR/epggrab) 2>/dev/null
	if [ $? -ne 0 ]; then
		TVHEADEND_EPGGRAB_USER=$TVHEADEND_USER
		TVHEADEND_EPGGRAB_GROUP=$TVHEADEND_GROUP
		TVHEADEND_EPGGRAB_PERMISSIONS=$TVHEADEND_PERMISSIONS
	fi
else
	TVHEADEND_EPGGRAB_USER=$TVHEADEND_USER
	TVHEADEND_EPGGRAB_GROUP=$TVHEADEND_GROUP
	TVHEADEND_EPGGRAB_PERMISSIONS=$TVHEADEND_PERMISSIONS
fi

if [ -d $TVHEADEND_CONFIG_DIR/input ]; then
	TVHEADEND_INPUT_USER=$(stat -c %U $TVHEADEND_CONFIG_DIR/input) 2>/dev/null
	TVHEADEND_INPUT_GROUP=$(stat -c %G $TVHEADEND_CONFIG_DIR/input) 2>/dev/null
	TVHEADEND_INPUT_PERMISSIONS=$(stat -c %a $TVHEADEND_CONFIG_DIR/input) 2>/dev/null
	if [ $? -ne 0 ]; then
		TVHEADEND_INPUT_USER=$TVHEADEND_USER
		TVHEADEND_INPUT_GROUP=$TVHEADEND_GROUP
		TVHEADEND_INPUT_PERMISSIONS=$TVHEADEND_PERMISSIONS
	fi
else
	TVHEADEND_INPUT_USER=$TVHEADEND_USER
	TVHEADEND_INPUT_GROUP=$TVHEADEND_GROUP
	TVHEADEND_INPUT_PERMISSIONS=$TVHEADEND_PERMISSIONS
fi

if [ -d $TVHEADEND_CONFIG_DIR/picons ]; then
	TVHEADEND_PICONS_USER=$(stat -c %U $TVHEADEND_CONFIG_DIR/picons) 2>/dev/null
	TVHEADEND_PICONS_GROUP=$(stat -c %G $TVHEADEND_CONFIG_DIR/picons) 2>/dev/null
	TVHEADEND_PICONS_PERMISSIONS=$(stat -c %a $TVHEADEND_CONFIG_DIR/picons) 2>/dev/null
	if [ $? -ne 0 ]; then
		TVHEADEND_PICONS_USER=$TVHEADEND_USER
		TVHEADEND_PICONS_GROUP=$TVHEADEND_GROUP
		TVHEADEND_PICONS_PERMISSIONS=$TVHEADEND_PERMISSIONS
	fi
else
	TVHEADEND_PICONS_USER=$TVHEADEND_USER
	TVHEADEND_PICONS_GROUP=$TVHEADEND_GROUP
	TVHEADEND_PICONS_PERMISSIONS=$TVHEADEND_PERMISSIONS
fi

# COMPROBAR QUE EXISTE CONFIG EN EPGGRAB
comprobarconfigepggrab()
{
	clear
	if [ ! -f $TVHEADEND_CONFIG_DIR/epggrab/config ]; then
		printf "$red%s$end\n\n" "¡No continúes hasta hacer lo siguiente!:"
		printf "%s\n\t%s$blue%s$end%s$blue%s$end%s$blue%s$end$blue%s$end$blue%s$end\n\t%s\n\n" "Es necesario que la interfaz web de tvheadend esté en modo Experto:" "- " "Configuración"  " >> " "General" " >> " "Base" " -> " "Default view level: Experto" "  (en inglés: Configuration >> General >> Base -> Default view level: Expert)"
		printf "%s\n\t%s$blue%s$end%s$blue%s$end%s$blue%s$end\n\t%s\n" "Luego dirígete al apartado:" "- " "Configuración"  " >> " "Canal / EPG" " >> " "Módulos para Obtención de Guía" "  (en inglés: Configuration >> Channel / EPG >> EPG Grabber Modules)"
		printf "\n%s\n" "Una vez estés situado aquí, haz lo siguiente:"
		printf "\t%s$green%s$end\n" "1- Selecciona el grabber que esté en " "\"Verde\""""
		printf "\t%s$blue%s$end\n\t%s\n" "2- En el menú lateral desmarca la casilla " "\"Habilitado\"" "  (en inglés \"Enabled\")"
		printf "\t%s$blue%s$end\n\t%s\n" "3- Finalmente, pulsa sobre el botón superior " "\"Guardar\"" "  (en inglés \"Save\")"
		printf "\n%s\n\n" "Repite esta operación con todos los grabber que estén habilitados"
		CONTINUAR="n"
		while [ "$CONTINUAR" != "s" ] && [ "$CONTINUAR" != "S" ] && [ "$CONTINUAR" != "" ]; do
			read -p "Una vez haya realizado este proceso ya puedes continuar. ¿Deseas continuar? [S/n]" CONTINUAR
		done
	fi
}

# COPIA DE SEGURIDAD
backup()
{
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                     Iniciando copia de seguridad                      ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Hacemos la copia de seguridad
	printf "%-$(($COLUMNS-10))s"  " 2. Realizando copia de seguridad"
		cd $TVHEADEND_CONFIG_DIR
		mkdir -p accesscontrol bouquet caclient channel codec epggrab input passwd picons profile service_mapper 2>>$CARPETA_SCRIPT/dobleM.log
		ls -l > dobleM-DIR.ver 2>>$CARPETA_SCRIPT/dobleM.log
		if [ -f "$CARPETA_SCRIPT/Backup_tvheadend_$(date +"%Y-%m-%d").tar.xz" ]; then
			FILE="Backup_tvheadend_$(date +"%Y-%m-%d_%H.%M.%S").tar.xz"
			tar -cjf $CARPETA_SCRIPT/$FILE accesscontrol bouquet caclient channel codec config epggrab input passwd picons profile service_mapper dobleM*.ver 2>>$CARPETA_SCRIPT/dobleM.log
		else
			FILE="Backup_tvheadend_$(date +"%Y-%m-%d").tar.xz"
			tar -cjf $CARPETA_SCRIPT/$FILE accesscontrol bouquet caclient channel codec config epggrab input passwd picons profile service_mapper dobleM*.ver 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
			printf "%s$blue%s$end\n" "   Backup creado: " "$FILE"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 3. Iniciando tvheadend"
		cd $CARPETA_SCRIPT
		INICIAR_TVHEADEND
# Fin copia de seguridad
	printf "\n$green%s$end\n" " ¡Proceso completado!"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
}

# INSTALADOR SATELITE
install()
{
# Comprobamos que exista el fichero config en la carpeta epggrab
	comprobarconfigepggrab
# Reiniciamos variables ERROR
	LIST_ERROR=false
	GRABBER_ERROR=false
	CONFIG_ERROR=false
	SERVICE_ERROR=false
# Pedimos lista a instalar
	NOMBRE_LISTA=dobleM-SAT
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                 Elección de lista satélite a instalar                 ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Elige la lista satélite que quieres instalar: $end"
		echo -e " 1) TODO (Astra individual + comunitaria + Lista de canales SD)"
		echo -e " 2) Astra individual + Lista de canales SD"
		echo -e " 3) Astra comunitaria + Lista de canales SD"
		echo -e " 4) Astra individual"
		echo -e " 5) Astra comunitaria"
		echo
		echo -e " v)$magenta Volver al menú$end"
		echo
		echo -n " Indica una opción: "
		read opcionsat
		case $opcionsat in
				1) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #No borramos nada
				2) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra individual y Astra SD
				3) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra comunitaria y Astra SD
				4) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c'; break;; #borramos todo menos Astra individual
				5) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2'; break;; #borramos todo menos Astra comunitaria
				v) MENU;;
				*) echo && echo " $opcionsat es una opción inválida" && echo;
		esac
	done
# Pedimos el formato de la guía de programación
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###            Elección del formato de la guía de programación            ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Elige el formato de la guía de programación: $end"
		echo -e " 1) Guía con etiquetas de colores"
		echo -e " 2) Guía sin etiquetas de colores"
		echo -e " 3) Guía con etiquetas de colores y título en una sola linea"
		echo -e " 4) Guía sin etiquetas de colores, título en una sola linea y sin caracteres especiales"
		echo
		echo -n " Indica una opción: "
		read opcion1
		case $opcion1 in
				1) FORMATO_IDIOMA_EPG='\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
				2) FORMATO_IDIOMA_EPG='\n\t\t"fre",\n\t\t"eng",\n\t\t"ger",\n\t\t"spa"\n\t'; break;;
				3) FORMATO_IDIOMA_EPG='\n\t\t"ger",\n\t\t"eng",\n\t\t"spa",\n\t\t"fre"\n\t'; break;;
				4) FORMATO_IDIOMA_EPG='\n\t\t"eng",\n\t\t"spa",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
				*) echo && echo " $opcion1 es una opción inválida" && echo;
		esac
	done
		echo
	while :
	do
		echo -e "$cyan Elige que tipo de imágenes aparecerán en la guía: $end"
		echo -e " 1) Imágenes tipo poster"
		echo -e " 2) Imágenes tipo fanart"
		echo
		echo -n " Indica una opción: "
		read opcion2
		case $opcion2 in
				1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g''; break;;
				2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g''; break;;
				*) echo && echo " $opcion2 es una opción inválida" && echo;
		esac
	done
		echo
	while :
	do
		echo -e "$cyan Elige el tipo de picon (los de GitHub aparecen bien al exportar el m3u): $end"
		echo -e " 1) dobleM (local)"
		echo -e " 2) dobleM (GitHub)"
		echo -e " 3) reflejo (GitHub)"
		echo -e " 4) transparent (GitHub)"
		echo -e " 5) color (GitHub)"
		echo
		echo -n " Indica una opción: "
		read opcion3
		case $opcion3 in
				1) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons"; break;;
				2) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/dobleM"; break;;
				3) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/reflejo"; break;;
				4) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/transparent"; break;;
				5) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/color"; break;;
				*) echo && echo " $opcion3 es una opción inválida" && echo;
		esac
	done
# Iniciamos instalación satélite
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###        Iniciando instalación de canales satélite y EPG dobleM         ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end con lista$green $NOMBRE_LISTA$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
	printf "%-$(($COLUMNS-10+1))s"  " 2. Descargando lista y grabber para canales satélite"
		ERROR=false
		rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.tar.xz 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\nLa lista de canales satélite no se ha podido descargar.\nPor favor, inténtalo más tarde."
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
# Descomprimimos el tar, borramos canales no elegidos y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
	printf "%-$(($COLUMNS-10+1))s"  " 3. Preparando lista de canales satélite"
		ERROR=false
		tar -xf "$NOMBRE_LISTA.tar.xz"
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		grep -L $LIMPIAR_CANALES_SAT $CARPETA_DOBLEM/channel/config/* | xargs -I{} rm {} 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Marcamos con dobleM????? al final todos los archivos de la carpeta /epggrab/xmltv/channels/
	printf "%-$(($COLUMNS-10+1))s"  " 4. Preparando grabber para satélite"
		ERROR=false
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Configuramos tvheadend y grabber para satelite
	printf "%-$(($COLUMNS-10))s"  " 5. Configurando tvheadend"
		ERROR=false
		#Idiomas EPG config tvheadend
		sed -i 's#"language":.*#"language": [\n\t idiomas_inicio#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's#"epg_compress":.*#idiomas_final \n\t"epg_compress": true,#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/idiomas_inicio/,/idiomas_final/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"language\":.*#\"language\": \[$FORMATO_IDIOMA_EPG\],#g" $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		#picons config tvheadend
		sed -i 's#"prefer_picon":.*#"prefer_picon": true,\n\t picons_inicio#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's#"http_server_name":.*#picons_final \n\t&#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/picons_inicio/,/picons_final/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"prefer_picon\".*#\"prefer_picon\": true,\n\t\"chiconscheme\": 0,\n\t\"piconpath\": \"$RUTA_PICON\",\n\t\"piconscheme\": 0,#" $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		#cron y grabber config epggrab
		sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			CONFIG_ERROR=true
		fi
# Borramos configuración actual
	printf "%-$(($COLUMNS-10+1))s"  " 6. Eliminando instalación anterior si la hubiera"
		# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos resto de la instalación anterior
		ERROR=false
		rm -rf $TVHEADEND_CONFIG_DIR/input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi

		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-IPTV
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-Pluto


# Copiamos archivos para canales
	printf "%-$(($COLUMNS-10+1))s"  " 7. Instalando lista de canales satélite"
		ERROR=false
		cp -r $CARPETA_DOBLEM/bouquet/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/picons/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/$NOMBRE_LISTA.ver $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Damos permisos a directorios y ficheros para canales
	printf "%-$(($COLUMNS-10+1))s" " 8. Aplicando permisos a la lista de canales satélite"
		ERROR=false
		chown -R $TVHEADEND_BOUQUET_USER:$TVHEADEND_BOUQUET_GROUP $TVHEADEND_CONFIG_DIR/bouquet 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/bouquet -type d -exec chmod $TVHEADEND_BOUQUET_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/bouquet -type f -exec chmod $(($TVHEADEND_BOUQUET_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_CHANNEL_USER:$TVHEADEND_CHANNEL_GROUP $TVHEADEND_CONFIG_DIR/channel 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type d -exec chmod $TVHEADEND_CHANNEL_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type f -exec chmod $(($TVHEADEND_CHANNEL_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_INPUT_USER:$TVHEADEND_INPUT_GROUP $TVHEADEND_CONFIG_DIR/input 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type d -exec chmod $TVHEADEND_INPUT_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type f -exec chmod $(($TVHEADEND_INPUT_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_PICONS_USER:$TVHEADEND_PICONS_GROUP $TVHEADEND_CONFIG_DIR/picons 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/picons -type d -exec chmod $TVHEADEND_PICONS_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/picons -type f -exec chmod $(($TVHEADEND_PICONS_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Copiamos archivos para grabber
	printf "%-$(($COLUMNS-10+1))s"  " 9. Instalando grabber para satélite"
		if [ -f /usr/bin/tv_grab_EPG_$NOMBRE_LISTA -a $SYSTEM -eq 1 ]; then
			 rm /usr/bin/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		ERROR=false
		cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		if [ ! -d $TVHEADEND_GRABBER_DIR ]; then
			mkdir -p $TVHEADEND_GRABBER_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Damos permisos a directorios y ficheros para canales
	printf "%-$(($COLUMNS-10+1))s" " 10. Aplicando permisos al grabber para satélite"
		ERROR=false
		chown -R $TVHEADEND_EPGGRAB_USER:$TVHEADEND_EPGGRAB_GROUP $TVHEADEND_CONFIG_DIR/epggrab 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type d -exec chmod $TVHEADEND_EPGGRAB_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type f -exec chmod $(($TVHEADEND_EPGGRAB_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown $TVHEADEND_USER:$TVHEADEND_GROUP $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod $(($TVHEADEND_PERMISSIONS-100)) $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 11. Eliminando archivos temporales"
		rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 12. Iniciando tvheadend"
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
elif [ "$CONFIG_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: La configuración de tvheadend no se ha realizado de forma automática."
	printf "$red%s$end\n" " Será necesario revisar y corregir la configuración manualmente."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
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

# ACTUALIZAR SATELITE
update()
{
# Reiniciamos variables ERROR
	LIST_ERROR=false
	GRABBER_ERROR=false
	CONFIG_ERROR=false
	SERVICE_ERROR=false
# Pedimos lista a actualizar
	NOMBRE_LISTA=dobleM-SAT
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                Elección de lista satélite a actualizar                ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Elige la lista satélite que quieres actualizar: $end"
		echo -e " 1) TODO (Astra individual + comunitaria + Lista de canales SD)"
		echo -e " 2) Astra individual + Lista de canales SD"
		echo -e " 3) Astra comunitaria + Lista de canales SD"
		echo -e " 4) Astra individual"
		echo -e " 5) Astra comunitaria"
		echo
		echo -e " v)$magenta Volver al menú$end"
		echo
		echo -n " Indica una opción: "
		read opcionsat
		case $opcionsat in
				1) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #No borramos nada
				2) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra individual y Astra SD
				3) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra comunitaria y Astra SD
				4) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c'; break;; #borramos todo menos Astra individual
				5) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2'; break;; #borramos todo menos Astra comunitaria
				v) MENU;;
				*) echo && echo " $opcionsat es una opción inválida" && echo;
		esac
	done
# Iniciamos actualización satélite
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###              Iniciando actualización de canales satélite              ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end con lista$green $NOMBRE_LISTA$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
	printf "%-$(($COLUMNS-10+1))s"  " 2. Descargando lista para canales satélite"
		ERROR=false
		rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.tar.xz 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\nLa lista de canales satélite no se ha podido descargar.\nPor favor, inténtalo más tarde."
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
# Descomprimimos el tar, borramos canales no elegidos y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
	printf "%-$(($COLUMNS-10+1))s"  " 3. Preparando lista de canales satélite"
		ERROR=false
		tar -xf "$NOMBRE_LISTA.tar.xz"
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		grep -L $LIMPIAR_CANALES_SAT $CARPETA_DOBLEM/channel/config/* | xargs -I{} rm {} 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi		
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log		
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Borramos configuración actual
	printf "%-$(($COLUMNS-10+1))s"  " 4. Eliminando instalación anterior"
		# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos resto de la instalación anterior
		ERROR=false
		rm -rf $TVHEADEND_CONFIG_DIR/input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi

		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-IPTV
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-Pluto


# Copiamos archivos para canales
	printf "%-$(($COLUMNS-10+1))s"  " 5. Instalando lista de canales satélite"
		ERROR=false
		cp -r $CARPETA_DOBLEM/bouquet/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/picons/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/$NOMBRE_LISTA.ver $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Damos permisos a directorios y ficheros para canales
	printf "%-$(($COLUMNS-10+1))s" " 6. Aplicando permisos a la lista de canales satélite"
		ERROR=false
		chown -R $TVHEADEND_BOUQUET_USER:$TVHEADEND_BOUQUET_GROUP $TVHEADEND_CONFIG_DIR/bouquet 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/bouquet -type d -exec chmod $TVHEADEND_BOUQUET_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/bouquet -type f -exec chmod $(($TVHEADEND_BOUQUET_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_CHANNEL_USER:$TVHEADEND_CHANNEL_GROUP $TVHEADEND_CONFIG_DIR/channel 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type d -exec chmod $TVHEADEND_CHANNEL_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type f -exec chmod $(($TVHEADEND_CHANNEL_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_INPUT_USER:$TVHEADEND_INPUT_GROUP $TVHEADEND_CONFIG_DIR/input 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type d -exec chmod $TVHEADEND_INPUT_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type f -exec chmod $(($TVHEADEND_INPUT_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_PICONS_USER:$TVHEADEND_PICONS_GROUP $TVHEADEND_CONFIG_DIR/picons 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/picons -type d -exec chmod $TVHEADEND_PICONS_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/picons -type f -exec chmod $(($TVHEADEND_PICONS_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi		
		chown -R $TVHEADEND_EPGGRAB_USER:$TVHEADEND_EPGGRAB_GROUP $TVHEADEND_CONFIG_DIR/epggrab 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type d -exec chmod $TVHEADEND_EPGGRAB_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type f -exec chmod $(($TVHEADEND_EPGGRAB_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;	
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 7. Eliminando archivos temporales"
		rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
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
elif [ "$CONFIG_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: La configuración de tvheadend no se ha realizado de forma automática."
	printf "$red%s$end\n" " Será necesario revisar y corregir la configuración manualmente."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
elif [ "$SERVICE_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: tvheadend no se ha podido reiniciar de forma automática."
	printf "$red%s$end\n" " Es necesario reiniciar tvheadend manualmente para aplicar los cambios."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
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
	echo " La primera captura de EPG tardará unos minutos hasta que todos"
	echo " los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
fi
}

# INSTALADOR IPTV sin ffmpeg
installIPTV()
{
# Comprobamos que exista el fichero config en la carpeta epggrab
	comprobarconfigepggrab
# Reiniciamos variables ERROR
	LIST_ERROR=false
	GRABBER_ERROR=false
	CONFIG_ERROR=false
	SERVICE_ERROR=false
# Pedimos lista a instalar
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###             Elección de lista IPTV a instalar/actualizar              ### $end"
	echo -e "$blue ### --------------------------------------------------------------------- ### $end"
	echo -e "$blue ###     $green¡ IMPORTANTE! $end $blue Estas listas y sus correspondientes EPG son       ### $end"
	echo -e "$blue ###     de terceros y pueden dejar de funcionar en cualquier momento      ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Elige la lista IPTV que quieres instalar/actualizar: $end"
		echo -e " 1) TDTChannels"
		echo -e " 2) Pluto.TV todos los países"
		echo -e " 3) Pluto.TV VOD español"
		echo
		echo -e " v)$magenta Volver al menú$end"
		echo
		echo -n " Indica una opción: "
		read opcioniptv
		case $opcioniptv in
				1) NOMBRE_LISTA=dobleM-TDT; break;;
				2) NOMBRE_LISTA=dobleM-PlutoTV_ALL; break;;
				3) NOMBRE_LISTA=dobleM-PlutoVOD_ES; break;;
				v) MENU;;
				*) echo && echo " $opcioniptv es una opción inválida" && echo;
		esac
	done
# Iniciamos instalación IPTV
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###             Iniciando instalación de canales IPTV y EPG               ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end con lista$green $NOMBRE_LISTA$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
	printf "%-$(($COLUMNS-10))s"  " 2. Descargando lista y grabber parar canales IPTV"
		ERROR=false
		rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.tar.xz 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\nLa lista de canales IPTV no se ha podido descargar.\nPor favor, inténtalo más tarde."
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
# Descomprimimos el tar y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
	printf "%-$(($COLUMNS-10))s"  " 3. Preparando lista de canales IPTV"
		ERROR=false
		tar -xf "$NOMBRE_LISTA.tar.xz"
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		grep -L '"epglimit": 7' $CARPETA_DOBLEM/channel/config/* | xargs -I{} rm {} 2>>$CARPETA_SCRIPT/dobleM.log #borramos todo menos los canales sin ffmpeg
		if [ $? -ne 0 ]; then
			ERROR=true
		fi			
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Marcamos con dobleM????? al final todos los archivos de la carpeta /epggrab/xmltv/channels/
	printf "%-$(($COLUMNS-10))s"  " 4. Preparando grabber para IPTV"
		ERROR=false
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Configuramos grabber para IPTV
	printf "%-$(($COLUMNS-10))s"  " 5. Configurando grabber en tvheadend"
		ERROR=false
		#cron y grabber config epggrab
		sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 4\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			CONFIG_ERROR=true
		fi
# Borramos configuración actual
	printf "%-$(($COLUMNS-10+1))s"  " 6. Eliminando instalación anterior si la hubiera"
		# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos resto de la instalación anterior
		ERROR=false
		case $opcioniptv in
				1) rm -rf $TVHEADEND_CONFIG_DIR/input/iptv/networks/c80013f7cb7dc75ed04b0312fa362ae1/ 2>>$CARPETA_SCRIPT/dobleM.log;;
				2) rm -rf $TVHEADEND_CONFIG_DIR/input/iptv/networks/d80013f7cb7dc75ed04b0312fa362ae1/ 2>>$CARPETA_SCRIPT/dobleM.log;;
				3) rm -rf $TVHEADEND_CONFIG_DIR/input/iptv/networks/f801b3c9e6be4260665d32be03908e00/ 2>>$CARPETA_SCRIPT/dobleM.log;;
		esac
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi


		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-IPTV
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-Pluto



# Copiamos archivos para canales
	printf "%-$(($COLUMNS-10))s"  " 7. Instalando lista de canales IPTV"
		ERROR=false
		cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/$NOMBRE_LISTA.ver $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Damos permisos a directorios y ficheros para canales
	printf "%-$(($COLUMNS-10))s" " 8. Aplicando permisos a la lista de canales IPTV"
		ERROR=false
		chown -R $TVHEADEND_CHANNEL_USER:$TVHEADEND_CHANNEL_GROUP $TVHEADEND_CONFIG_DIR/channel 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type d -exec chmod $TVHEADEND_CHANNEL_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type f -exec chmod $(($TVHEADEND_CHANNEL_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_INPUT_USER:$TVHEADEND_INPUT_GROUP $TVHEADEND_CONFIG_DIR/input 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type d -exec chmod $TVHEADEND_INPUT_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type f -exec chmod $(($TVHEADEND_INPUT_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Copiamos archivos para grabber
	printf "%-$(($COLUMNS-10))s"  " 9. Instalando grabber para para IPTV"
		if [ -f /usr/bin/tv_grab_EPG_$NOMBRE_LISTA -a $SYSTEM -eq 1 ]; then
			 rm /usr/bin/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		ERROR=false
		cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		if [ ! -d $TVHEADEND_GRABBER_DIR ]; then
			mkdir -p $TVHEADEND_GRABBER_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Damos permisos a los directorios
	printf "%-$(($COLUMNS-10))s" " 10. Aplicando permisos al grabber IPTV"
		ERROR=false
		chown -R $TVHEADEND_EPGGRAB_USER:$TVHEADEND_EPGGRAB_GROUP $TVHEADEND_CONFIG_DIR/epggrab 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type d -exec chmod $TVHEADEND_EPGGRAB_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type f -exec chmod $(($TVHEADEND_EPGGRAB_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown $TVHEADEND_USER:$TVHEADEND_GROUP $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod $(($TVHEADEND_PERMISSIONS-100)) $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 11. Eliminando archivos temporales"
		rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 12. Iniciando tvheadend"
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
elif [ "$CONFIG_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: La configuración de tvheadend no se ha realizado de forma automática."
	printf "$red%s$end\n" " Será necesario revisar y corregir la configuración manualmente."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
elif [ "$SERVICE_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: tvheadend no se ha podido reiniciar de forma automática."
	printf "$red%s$end\n" " Es necesario reiniciar tvheadend manualmente para aplicar los cambios."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
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
	echo " La primera captura de EPG tardará unos minutos hasta que todos"
	echo " los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
fi
}

# INSTALADOR IPTV con ffmpeg
installIPTVffmpeg()
{
# Comprobamos que exista el fichero config en la carpeta epggrab
	comprobarconfigepggrab
# Reiniciamos variables ERROR
	LIST_ERROR=false
	GRABBER_ERROR=false
	CONFIG_ERROR=false
	SERVICE_ERROR=false
# Pedimos lista a instalar
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###             Elección de lista IPTV a instalar/actualizar              ### $end"
	echo -e "$blue ### --------------------------------------------------------------------- ### $end"
	echo -e "$blue ###     $green¡ IMPORTANTE! $end $blue Estas listas y sus correspondientes EPG son       ### $end"
	echo -e "$blue ###     de terceros y pueden dejar de funcionar en cualquier momento      ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	echo -e " Ruta binario ffmpeg:$yellow $FFMPEG_DIR $end"
	echo -e " Comandos     ffmpeg:$yellow $FFMPEG_COMMAND $end"
	echo _______________________________________________________________________________
	echo
	while :
	do
		echo -e "$cyan Elige la lista IPTV que quieres instalar/actualizar: $end"
		echo -e " 1) TDTChannels"
		echo -e " 2) Pluto.TV todos los países"
		echo -e " 3) Pluto.TV VOD español"
		echo
		echo -e " v)$magenta Volver al menú$end"
		echo
		echo -e " a)$green Cambiar ruta binario$end$yellow $FFMPEG_DIR $end"
		echo -e " b)$green Cambiar los comandos$end$yellow $FFMPEG_COMMAND $end"
		echo
		echo -n " Indica una opción: "
		read opcioniptv
		case $opcioniptv in
				1) NOMBRE_LISTA=dobleM-TDT; break;;
				2) NOMBRE_LISTA=dobleM-PlutoTV_ALL; break;;
				3) NOMBRE_LISTA=dobleM-PlutoVOD_ES; break;;
				v) MENU;;
				a)  clear
					echo -e "Introduzca su ruta para el binario ffmpeg: "
					echo -e "$yellow$FFMPEG_DIR$end y pulse INTRO"
					echo
					read FFMPEG_DIR
					installIPTV;;
				b)	clear
					echo -e "Introduzca sus comandos para ffmpeg: "
					echo -e "$yellow$FFMPEG_COMMAND$end y pulse INTRO"
					echo
					read FFMPEG_COMMAND
					installIPTV;;
				*) echo && echo " $opcioniptv es una opción inválida" && echo;
		esac
	done
# Iniciamos instalación IPTV
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###             Iniciando instalación de canales IPTV y EPG               ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end con lista$green $NOMBRE_LISTA$end"
	echo
# Comprobamos que esté instalado ffmpeg
command -v ffmpeg >/dev/null 2>&1 || { printf "$red%s\n%s$end\n\n" "ERROR: Es necesario tener instalado 'ffmpeg'." "Por favor, ejecuta el script de nuevo cuando lo hayas instalado." && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit 1; }
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
	printf "%-$(($COLUMNS-10))s"  " 2. Descargando lista y grabber parar canales IPTV"
		ERROR=false
		rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.tar.xz 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\nLa lista de canales IPTV no se ha podido descargar.\nPor favor, inténtalo más tarde."
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
# Descomprimimos el tar y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
	printf "%-$(($COLUMNS-10))s"  " 3. Preparando lista de canales IPTV"
		ERROR=false
		tar -xf "$NOMBRE_LISTA.tar.xz"
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		grep -L '"epglimit": 0' $CARPETA_DOBLEM/channel/config/* | xargs -I{} rm {} 2>>$CARPETA_SCRIPT/dobleM.log #borramos todo menos los canales con ffmpeg
		if [ $? -ne 0 ]; then
			ERROR=true
		fi			
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Marcamos con dobleM????? al final todos los archivos de la carpeta /epggrab/xmltv/channels/
	printf "%-$(($COLUMNS-10))s"  " 4. Preparando grabber para IPTV"
		ERROR=false
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Configuramos grabber para IPTV
	printf "%-$(($COLUMNS-10))s"  " 5. Configurando grabber en tvheadend"
		ERROR=false
		#cron y grabber config epggrab
		sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 4\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			CONFIG_ERROR=true
		fi
# Borramos configuración actual
	printf "%-$(($COLUMNS-10+1))s"  " 6. Eliminando instalación anterior si la hubiera"
		# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos resto de la instalación anterior
		ERROR=false
		case $opcioniptv in
				1) rm -rf $TVHEADEND_CONFIG_DIR/input/iptv/networks/c80013f7cb7dc75ed04b0312fa362ae1/ 2>>$CARPETA_SCRIPT/dobleM.log;;
				2) rm -rf $TVHEADEND_CONFIG_DIR/input/iptv/networks/d80013f7cb7dc75ed04b0312fa362ae1/ 2>>$CARPETA_SCRIPT/dobleM.log;;
				3) rm -rf $TVHEADEND_CONFIG_DIR/input/iptv/networks/f801b3c9e6be4260665d32be03908e00/ 2>>$CARPETA_SCRIPT/dobleM.log;;
		esac
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi


		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-IPTV
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-Pluto



# Copiamos archivos para canales
	printf "%-$(($COLUMNS-10))s"  " 7. Instalando lista de canales IPTV"
		ERROR=false
		cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#FFMPEG_TEMP#$FFMPEG_DIR $FFMPEG_COMMAND#g" $CARPETA_DOBLEM/dobleM-FFMPEG.sh && chmod +rx $CARPETA_DOBLEM/dobleM-FFMPEG.sh && cp -r $CARPETA_DOBLEM/dobleM-FFMPEG.sh /var 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/$NOMBRE_LISTA.ver $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Damos permisos a directorios y ficheros para canales
	printf "%-$(($COLUMNS-10))s" " 8. Aplicando permisos a la lista de canales IPTV"
		ERROR=false
		chown -R $TVHEADEND_CHANNEL_USER:$TVHEADEND_CHANNEL_GROUP $TVHEADEND_CONFIG_DIR/channel 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type d -exec chmod $TVHEADEND_CHANNEL_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/channel -type f -exec chmod $(($TVHEADEND_CHANNEL_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown -R $TVHEADEND_INPUT_USER:$TVHEADEND_INPUT_GROUP $TVHEADEND_CONFIG_DIR/input 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type d -exec chmod $TVHEADEND_INPUT_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/input -type f -exec chmod $(($TVHEADEND_INPUT_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Copiamos archivos para grabber
	printf "%-$(($COLUMNS-10))s"  " 9. Instalando grabber para para IPTV"
		if [ -f /usr/bin/tv_grab_EPG_$NOMBRE_LISTA -a $SYSTEM -eq 1 ]; then
			 rm /usr/bin/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		ERROR=false
		cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		if [ ! -d $TVHEADEND_GRABBER_DIR ]; then
			mkdir -p $TVHEADEND_GRABBER_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Damos permisos a los directorios
	printf "%-$(($COLUMNS-10))s" " 10. Aplicando permisos al grabber IPTV"
		ERROR=false
		chown -R $TVHEADEND_EPGGRAB_USER:$TVHEADEND_EPGGRAB_GROUP $TVHEADEND_CONFIG_DIR/epggrab 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type d -exec chmod $TVHEADEND_EPGGRAB_PERMISSIONS 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		find $TVHEADEND_CONFIG_DIR/epggrab -type f -exec chmod $(($TVHEADEND_EPGGRAB_PERMISSIONS-100)) 2>>$CARPETA_SCRIPT/dobleM.log {} \;
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown $TVHEADEND_USER:$TVHEADEND_GROUP $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod $(($TVHEADEND_PERMISSIONS-100)) $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 11. Eliminando archivos temporales"
		rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 12. Iniciando tvheadend"
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
elif [ "$CONFIG_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: La configuración de tvheadend no se ha realizado de forma automática."
	printf "$red%s$end\n" " Será necesario revisar y corregir la configuración manualmente."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
elif [ "$SERVICE_ERROR" = true ]; then
	printf "\n$red%s$end\n" " ERROR: tvheadend no se ha podido reiniciar de forma automática."
	printf "$red%s$end\n" " Es necesario reiniciar tvheadend manualmente para aplicar los cambios."
	printf "\n$green%s$end\n" " ¡Proceso completado!"
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
	echo " La primera captura de EPG tardará unos minutos hasta que todos"
	echo " los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo " Pulsa intro para continuar..."
	read CAD
	MENU
fi
}

# INSTALAR GRABBER
installGRABBER()
{
# Comprobamos que exista el fichero config en la carpeta epggrab
	comprobarconfigepggrab
# Pedimos grabber a instalar
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                    Elección de grabber a instalar                     ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Elige el grabber que quieres instalar: $end"
		echo -e " 1) Satélite"
		echo -e " 2) TDTChannels"
		echo -e " 3) Pluto.TV"
		echo -e " 4) Pluto.TV VOD"
		echo
		echo -e " v)$magenta Volver al menú$end"
		echo
		echo -n " Indica una opción: "
		read opciongrabber
		case $opciongrabber in
				1) NOMBRE_LISTA=dobleM-SAT; break;;
				2) NOMBRE_LISTA=dobleM-TDT; break;;
				3) NOMBRE_LISTA=dobleM-PlutoTV_ALL; break;;
				4) NOMBRE_LISTA=dobleM-PlutoVOD_ES; break;;
				v) MENU;;
				*) echo && echo " $opciongrabber es una opción inválida" && echo;
		esac
	done
# Iniciamos instalación grabber
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                   Iniciando instalación de grabber                    ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end con grabber$green tv_grab_EPG_$NOMBRE_LISTA$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Preparamos CARPETA_DOBLEM y descargamos el grabber
	printf "%-$(($COLUMNS-10))s"  " 2. Descargando grabber"
		ERROR=false
		rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM/epggrab && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\nEl grabber no se ha podido descargar.\nPor favor, inténtalo más tarde."
			echo
			echo " Pulsa intro para continuar..."
			read CAD
			MENU
		fi
# Configuramos grabber
	printf "%-$(($COLUMNS-10))s"  " 3. Configurando grabber en tvheadend"
		ERROR=false
		#cron y grabber config epggrab
		sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Borramos grabber anterior, copiamos el nuevo grabber y el fichero epggrab/config
	printf "%-$(($COLUMNS-10))s"  " 4. Instalando grabber"
		ERROR=false
		if [ ! -d $TVHEADEND_GRABBER_DIR ]; then
			mkdir -p $TVHEADEND_GRABBER_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Damos permisos a los directorios
	printf "%-$(($COLUMNS-10))s" " 5. Aplicando permisos al grabber"
		ERROR=false
		chown $TVHEADEND_USER:$TVHEADEND_GROUP $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod $(($TVHEADEND_PERMISSIONS-100)) $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 6. Eliminando archivos temporales"
		rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 7. Iniciando tvheadend"
		cd $CARPETA_SCRIPT
		INICIAR_TVHEADEND
# Fin limpieza
	printf "\n$green%s$end\n" " ¡Proceso completado!"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		installGRABBER
}

# CAMBIAR FORMATO EPG
cambioformatoEPG()
{
	NOMBRE_LISTA=dobleM-SAT
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###            Elección del formato de la guía de programación            ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Elige el formato de la guía de programación: $end"
		echo -e " 1) Guía con etiquetas de colores"
		echo -e " 2) Guía sin etiquetas de colores"
		echo -e " 3) Guía con etiquetas de colores y título en una sola linea"
		echo -e " 4) Guía sin etiquetas de colores, título en una sola linea y sin caracteres especiales"
		echo
		echo -n " Indica una opción: "
		read opcion1
		case $opcion1 in
				1) FORMATO_IDIOMA_EPG='\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
				2) FORMATO_IDIOMA_EPG='\n\t\t"fre",\n\t\t"eng",\n\t\t"ger",\n\t\t"spa"\n\t'; break;;
				3) FORMATO_IDIOMA_EPG='\n\t\t"ger",\n\t\t"eng",\n\t\t"spa",\n\t\t"fre"\n\t'; break;;
				4) FORMATO_IDIOMA_EPG='\n\t\t"eng",\n\t\t"spa",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
				*) echo && echo " $opcion1 es una opción inválida" && echo;
		esac
	done
		echo
	while :
	do
		echo -e "$cyan Elige que tipo de imágenes aparecerán en la guía: $end"
		echo -e " 1) Imágenes tipo poster"
		echo -e " 2) Imágenes tipo fanart"
		echo
		echo -n " Indica una opción: "
		read opcion2
		case $opcion2 in
				1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g''; break;;
				2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g''; break;;
				*) echo && echo " $opcion2 es una opción inválida" && echo;
		esac
	done
		echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Aplicamos cambio formato de EPG
	printf "%-$(($COLUMNS-10+2))s"  " 2. Cambiando formato de la guía de programación"
		ERROR=false
		sed -i 's#"language":.*#"language": [\n\t idiomas_inicio#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's#"epg_compress":.*#idiomas_final \n\t"epg_compress": true,#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/idiomas_inicio/,/idiomas_final/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"language\":.*#\"language\": \[$FORMATO_IDIOMA_EPG\],#g" $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Aplicamos cambio tipo de imagen de EPG
	printf "%-$(($COLUMNS-10+3))s"  " 3. Cambiando tipo de imágenes de la guía de programación"
		$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 4. Iniciando tvheadend"
		cd $CARPETA_SCRIPT
		INICIAR_TVHEADEND
	printf "\n$green%s$end\n" " ¡Proceso completado!"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
}

# CAMBIAR RUTA Y TIPO_PICON
cambioformatoPICONS()
{
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###           Iniciando cambio del formato/ruta de los picons             ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Elige el tipo de picon (los de GitHub aparecen bien al exportar el m3u): $end"
		echo -e " 1) dobleM (local)"
		echo -e " 2) dobleM (GitHub)"
		echo -e " 3) reflejo (GitHub)"
		echo -e " 4) transparent (GitHub)"
		echo -e " 5) color (GitHub)"
		echo
		echo -e " a)$yellow Introducir la ruta de los picons manualmente $end"
		echo -e "    (el nombre del picon tiene que ser: 1_0_19_18EF .... .png)"
		echo
		echo -n " Indica una opción: "
		read opcion3
		case $opcion3 in
				1) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons"; break;;
				2) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/dobleM"; break;;
				3) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/reflejo"; break;;
				4) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/transparent"; break;;
				5) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/color"; break;;
				a)
					echo -e "$yellow Escribe la ruta de los picons (si es local no te olvides de file:///)$end"
					read RUTA_PICON
					break;;
				*) echo && echo " $opcion3 es una opción inválida" && echo;
		esac
	done
		echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Aplicamos cambio formato picons
	printf "%-$(($COLUMNS-10))s"  " 2. Cambiando formato/ruta picons"
		ERROR=false
		sed -i 's#"prefer_picon":.*#"prefer_picon": true,\n\t picons_inicio#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's#"http_server_name":.*#picons_final \n\t&#' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/picons_inicio/,/picons_final/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s#\"prefer_picon\".*#\"prefer_picon\": true,\n\t\"chiconscheme\": 0,\n\t\"piconpath\": \"$RUTA_PICON\",\n\t\"piconscheme\": 0,#" $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 3. Iniciando tvheadend"
		cd $CARPETA_SCRIPT
		INICIAR_TVHEADEND
	printf "\n$green%s$end\n" " ¡Proceso completado!"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
}

# LIMPIEZA TOTAL DE CANALES
limpiezatotal()
{
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                 Iniciando limpieza total de tvheadend                 ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	while :
	do
		echo -e "$cyan Se borrarán los siguientes directorios: $end"
		echo -e "$cyan channel, epggrab, input, bouquet y picons $end"
		echo
		echo -n " ¿Estás seguro que deseas continuar? [s/n] "
		read opcionlimpieza
		case $opcionlimpieza in
				s) echo && echo " Procediendo a limpiar tvheadend" && echo; break;;
				n) MENU;;
				*) echo && echo " Por favor, elige Si o No" && echo;
		esac
	done
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Borramos carpeta "channel" de tvheadend
	printf "%-$(($COLUMNS-10+1))s"  " 2. Borrando toda la configuración de tvheadend"
		cd $TVHEADEND_CONFIG_DIR
		rm -rf $TVHEADEND_CONFIG_DIR/bouquet/ $TVHEADEND_CONFIG_DIR/channel/ $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/ $TVHEADEND_CONFIG_DIR/input/ $TVHEADEND_CONFIG_DIR/picons/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
		rm -rf $TVHEADEND_CONFIG_DIR/dobleM*.ver >/dev/null 2>&1
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 3. Iniciando tvheadend"
		cd $CARPETA_SCRIPT
		INICIAR_TVHEADEND
# Fin limpieza
	printf "\n$green%s$end\n" " ¡Proceso completado!"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
}

# RESTAURAR COPIA DE SEGURIDAD
resbackup()
{
	clear
# Comprobamos que exista un fichero de copia de seguridad
	if [ ! -f $CARPETA_SCRIPT/Backup_tvheadend_* ]; then
		printf "$red%s$end\n\n" "No se ha encontrado ningún fichero de copia de seguridad."
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
	fi
# Iniciamos restauración de la copia de seguridad
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###           Iniciando restauración de la copia de seguridad             ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Elegimos fichero de backup mas reciente
	printf "%-$(($COLUMNS-10+1))s"  " 2. Comprobando copia de seguridad más reciente"
		FILE_BACKUP="$(ls -t Backup_tvheadend_* | head -1)" 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Borramos carpetas/ficheros
	printf "%-$(($COLUMNS-10))s"  " 2. Preparando copia de seguridad"
		rm -rf $TVHEADEND_CONFIG_DIR/accesscontrol/ $TVHEADEND_CONFIG_DIR/bouquet/ $TVHEADEND_CONFIG_DIR/caclient/ $TVHEADEND_CONFIG_DIR/channel/ $TVHEADEND_CONFIG_DIR/codec/ $TVHEADEND_CONFIG_DIR/config $TVHEADEND_CONFIG_DIR/epggrab/ $TVHEADEND_CONFIG_DIR/input/ $TVHEADEND_CONFIG_DIR/passwd/ $TVHEADEND_CONFIG_DIR/picons/ $TVHEADEND_CONFIG_DIR/profile/ $TVHEADEND_CONFIG_DIR/service_mapper/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
		rm -rf $TVHEADEND_CONFIG_DIR/dobleM*.ver 2>/dev/null
# Descomprimimos el fichero de backup
	printf "%-$(($COLUMNS-10))s"  " 3. Restaurando copia de seguridad"
		tar -xf "$CARPETA_SCRIPT/$FILE_BACKUP" -C $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 4. Iniciando tvheadend"
		cd $CARPETA_SCRIPT
		INICIAR_TVHEADEND
# Fin restauracion copia de seguridad
	printf "\n$green%s$end\n" " ¡Proceso completado!"
		echo
		echo " Pulsa intro para continuar..."
		read CAD
		MENU
}

# MENU INSTALACION
MENU()
{
while :
do
ver_menu_SAT=""
ver_menu_TDT=""
ver_menu_PlutoTV_ALL=""
ver_menu_PlutoVOD_ES=""
ver_local_SAT=`cat $TVHEADEND_CONFIG_DIR/dobleM-SAT.ver 2>/dev/null`
	if [ $? -ne 0 ]; then
	ver_local_SAT=···
	fi
ver_web_SAT=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-SAT.ver 2>/dev/null`
	if [ $ver_local_SAT != $ver_web_SAT ]; then
	ver_menu_SAT="--->  Nueva versión:$green $ver_web_SAT $end"
	fi
ver_local_TDT=`cat $TVHEADEND_CONFIG_DIR/dobleM-TDT.ver 2>/dev/null`
	if [ $? -ne 0 ]; then
	ver_local_TDT=···
	fi
ver_web_TDT=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-TDT.ver 2>/dev/null`
	if [ $ver_local_TDT != $ver_web_TDT ]; then
	ver_menu_TDT="--->  Nueva versión:$green $ver_web_TDT $end"
	fi
ver_local_PlutoTV_ALL=`cat $TVHEADEND_CONFIG_DIR/dobleM-PlutoTV_ALL.ver 2>/dev/null`
	if [ $? -ne 0 ]; then
	ver_local_PlutoTV_ALL=···
	fi
ver_web_PlutoTV_ALL=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-PlutoTV_ALL.ver 2>/dev/null`
	if [ $ver_local_PlutoTV_ALL != $ver_web_PlutoTV_ALL ]; then
	ver_menu_PlutoTV_ALL="--->  Nueva versión:$green $ver_web_PlutoTV_ALL $end"
	fi
ver_local_PlutoVOD_ES=`cat $TVHEADEND_CONFIG_DIR/dobleM-PlutoVOD_ES.ver 2>/dev/null`
	if [ $? -ne 0 ]; then
	ver_local_PlutoVOD_ES=···
	fi
ver_web_PlutoVOD_ES=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-PlutoVOD_ES.ver 2>/dev/null`
	if [ $ver_local_PlutoVOD_ES != $ver_web_PlutoVOD_ES ]; then
	ver_menu_PlutoVOD_ES="--->  Nueva versión:$green $ver_web_PlutoVOD_ES $end"
	fi
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                           $green -= dobleM =- $end                             $blue ### $end"
	echo -e "$blue ###                     Telegram: $cyan t.me/EPG_dobleM $end                      $blue ### $end"
	echo -e "$blue ### --------------------------------------------------------------------- ### $end"
	echo -e "$blue ###      $red¡ PRECAUCION! $end  $blue Comprueba que el sistema y los directorios      ### $end"
	echo -e "$blue ###      de instalación sean correctos, en caso de duda no continues      ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Usando script$green $SISTEMA_ELEGIDO$end en$green $SYSTEM_INFO$end"
	echo
	echo -e " Directorio tvheadend:$yellow $TVHEADEND_CONFIG_DIR $end"
	echo -e " Directorio   grabber:$yellow $TVHEADEND_GRABBER_DIR $end"
	echo
	echo -e " SATELITE      --->  Versión instalada:$red $ver_local_SAT $end $ver_menu_SAT"
	echo -e " TDTChannels   --->  Versión instalada:$red $ver_local_TDT $end $ver_menu_TDT"
	echo -e " Pluto.TV      --->  Versión instalada:$red $ver_local_PlutoTV_ALL $end $ver_menu_PlutoTV_ALL"
	echo -e " Pluto.TV VOD  --->  Versión instalada:$red $ver_local_PlutoVOD_ES $end $ver_menu_PlutoVOD_ES"
	echo _______________________________________________________________________________
	echo
	echo -e " 0)$green Hacer copia de seguridad de tvheadend $end"
	echo -e " 1)$cyan Instalar   canales$yellow SATELITE $end+ picons, grabber y configurar tvheadend $end"
	echo -e " 2)$cyan Actualizar canales$yellow SATELITE $end(Solo actualiza canales y picons) $end"
	echo -e " 3)$cyan Instalar/Actualizar canales$yellow IPTV $end(TDTChannels - Pluto.TV - Pluto.TV VOD) $end"
	echo -e " 4)$cyan Instalar/Actualizar canales$yellow IPTV-ffmpeg $end(Pasando la URL por ffmpeg) $end"
	echo -e " 5)$cyan Instalar grabber y configurar tvheadend $end"
	echo -e " 6)$cyan Cambiar el formato de la guía de programación $end"
	echo -e " 7)$cyan Cambiar el formato/ruta de los picons $end"
	echo -e " 8)$cyan Hacer una$red limpieza$end$cyan de tvheadend $end(channel, epggrab, input, bouquet, picons)"
	echo -e " 9)$green Restaurar copia de seguridad $end(Usa el fichero mas reciente que encuentre) $end"
	echo
    echo -e " v)$magenta Volver $end"
    echo -e " s)$red Salir $end"
	echo
	echo -e " a)$green Cambiar la ruta$end$yellow $TVHEADEND_CONFIG_DIR $end"
	echo -e " b)$green Cambiar la ruta$end$yellow $TVHEADEND_GRABBER_DIR $end"
	echo
	echo -n " Indica una opción: "
	read opcionmenu
	case $opcionmenu in
		0) clear && backup;;
		1) clear && install;;
		2) clear && update;;
		3) clear && installIPTV;;
		4) clear && installIPTVffmpeg;;
		5) clear && installGRABBER;;
		6) clear && cambioformatoEPG;;
		7) clear && cambioformatoPICONS;;
		8) clear && limpiezatotal;;
		9) clear && resbackup;;
		v) rm -rf $CARPETA_SCRIPT/i_dobleMi.sh && clear && cd $CARPETA_SCRIPT && ./i_dobleM.sh; break;;
		s) clear && echo " Gracias por usar el script dobleM" && rm -rf $CARPETA_SCRIPT/i_dobleM*.sh; exit;;
		a)  clear
			echo -e "Introduzca su ruta para el directorio: "
			echo -e "$yellow$TVHEADEND_CONFIG_DIR$end y pulse INTRO"
			echo
			read TVHEADEND_CONFIG_DIR
			MENU;;
		b)	clear
			echo -e "Introduzca su ruta para el directorio: "
			echo -e "$yellow$TVHEADEND_GRABBER_DIR$end y pulse INTRO"
			echo
			read TVHEADEND_GRABBER_DIR
			MENU;;
		*) echo && echo " $opcionmenu es una opción inválida" && echo;
	esac
done
}
MENU

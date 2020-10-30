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
CARPETA_DOBLEM="$TVHEADEND_CONFIG_DIR/dobleM"
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
command -v curl >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'curl'." "Por favor, ejecute el script de nuevo una vez haya sido instalado." && rm -rf $CARPETA_SCRIPT/i_*.sh; exit 1; }
command -v wget >/dev/null 2>&1 || { printf "$red%s\n%s$end\n" "ERROR: Es necesario tener instalado 'wget'." "Por favor, ejecute el script de nuevo una vez haya sido instalado." && rm -rf $CARPETA_SCRIPT/i_*.sh; exit 1; }

# Detectando sistema operativo
	SYSTEM_DETECTOR="$(uname -a)"
	if [ "${SYSTEM_DETECTOR#*"synology"}" != "$SYSTEM_DETECTOR" ]; then
		SYSTEM_INFO="Synology/XPEnology"
	else
		SYSTEM_INFO="$(sed -e '/PRETTY_NAME=/!d' -e 's/PRETTY_NAME=//g' /etc/*-release)" 2>>$CARPETA_SCRIPT/dobleM.log
	fi

# Sistema elegido:	 1-Synology/XPEnology   2-LibreELEC/OpenELEC   3-Linux
	if [ "$1" = "Synology" ]; then
		SISTEMA_ELEGIDO="Synology/XPEnology"
		SYSTEM=1
	elif [ "$1" = "Libreelec" ]; then
		SISTEMA_ELEGIDO="LibreELEC/OpenELEC/CoreELEC"
		SYSTEM=2
	elif [ "$1" = "Linux" ]; then
		SISTEMA_ELEGIDO="Linux"
		SYSTEM=3
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
		
		FFMPEG_COMMAND="/usr/local/ffmpeg/bin/ffmpeg -loglevel fatal -re -i \$1 -c copy -f mpegts -tune zerolatency pipe:1";;
	2) #LibreELEC/OpenELEC
		TVHEADEND_SERVICE="$(systemctl list-unit-files --type=service | grep tvheadend | tr -s ' ' | cut -d' ' -f1)" 2>>$CARPETA_SCRIPT/dobleM.log #"service.tvheadend42.service"
		TVHEADEND_USER="root"
		TVHEADEND_GROUP="video"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
		TVHEADEND_CONFIG_DIR="/storage/.kodi/userdata/addon_data/$(ls /storage/.kodi/userdata/addon_data/ | grep tvheadend)" 2>>$CARPETA_SCRIPT/dobleM.log #"/storage/.kodi/userdata/addon_data/service.tvheadend42"
		TVHEADEND_GRABBER_DIR="/storage/.kodi/addons/$(ls /storage/.kodi/addons/ | grep tvheadend)/bin" 2>>$CARPETA_SCRIPT/dobleM.log #"/storage/.kodi/addons/service.tvheadend42/bin"
		FFMPEG_COMMAND="/usr/bin/ffmpeg -i \$1 -c copy -f mpegts pipe:1";;
	3) #Linux
		TVHEADEND_SERVICE="$(systemctl list-unit-files --type=service | grep tvheadend | tr -s ' ' | cut -d' ' -f1)" 2>>$CARPETA_SCRIPT/dobleM.log #"tvheadend.service"
		TVHEADEND_USER="$(cut -d: -f1 /etc/passwd | grep -E 'tvheadend|hts')" 2>>$CARPETA_SCRIPT/dobleM.log #"hts"
		TVHEADEND_GROUP="video" #"$(id -gn $TVHEADEND_USER)"
		TVHEADEND_PERMISSIONS="700" #"u=rwX,g=,o="
		TVHEADEND_CONFIG_DIR="/home/hts/.hts/tvheadend"
		TVHEADEND_GRABBER_DIR="/usr/bin"
		FFMPEG_COMMAND="/usr/bin/ffmpeg -i \$1 -c copy -f mpegts pipe:1";;
	esac

# Parar/Iniciar tvheadend
PARAR_TVHEADEND()
{
SERVICE_ERROR=false
	case $SYSTEM in
		1)
			if [ "$SERVICES_MANAGEMENT" = "OLD" ]; then
				"/var/packages/$(ls /var/packages/ | grep tvheadend)/scripts/start-stop-status" stop 1>$CARPETA_SCRIPT/dobleM.log 2>&1
			else
				stop -q $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log
			fi;;
		2)
			systemctl stop $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		3)
			service tvheadend stop 1>>$CARPETA_SCRIPT/dobleM.log 2>&1;; #service tvheadend stop
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
		1)
			if [ "$SERVICES_MANAGEMENT" = "OLD" ]; then
				"/var/packages/$(ls /var/packages/ | grep tvheadend)/scripts/start-stop-status" start 1>$CARPETA_SCRIPT/dobleM.log 2>&1
			else
				start -q $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log
			fi;;
		2)
			systemctl start $TVHEADEND_SERVICE 2>>$CARPETA_SCRIPT/dobleM.log;;
		3)
			service tvheadend start 1>>$CARPETA_SCRIPT/dobleM.log 2>&1;; #service tvheadend start
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

# COPIA DE SEGURIDAD
backup()
{
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                     Iniciando copia de seguridad                      ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Ejecutando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Hacemos la copia de seguridad
	printf "%-$(($COLUMNS-10))s"  " 2. Realizando copia de seguridad"
		cd $TVHEADEND_CONFIG_DIR
		mkdir -p accesscontrol bouquet caclient channel codec epggrab input passwd picons profile service_mapper 2>>$CARPETA_SCRIPT/dobleM.log
		if [ -f "$CARPETA_SCRIPT/Backup_tvheadend_$(date +"%Y-%m-%d").tar.xz" ]; then
			FILE="Backup_tvheadend_$(date +"%Y-%m-%d_%H.%M.%S").tar.xz"
			tar -cjf $CARPETA_SCRIPT/$FILE accesscontrol bouquet caclient channel codec config epggrab input passwd picons profile service_mapper 2>>$CARPETA_SCRIPT/dobleM.log
		else
			FILE="Backup_tvheadend_$(date +"%Y-%m-%d").tar.xz"
			tar -cjf $CARPETA_SCRIPT/$FILE accesscontrol bouquet caclient channel codec config epggrab input passwd picons profile service_mapper 2>>$CARPETA_SCRIPT/dobleM.log
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
	clear
	LIST_ERROR=false
	GRABBER_ERROR=false
# Comprobamos que exista el fichero config en la carpeta epggrab
	if [ ! -f $TVHEADEND_CONFIG_DIR/epggrab/config ]; then
		printf "$red%s$end\n\n" "¡No continúes hasta hacer lo siguiente!:"
		printf "%s\n\t%s$blue%s$end%s$blue%s$end%s$blue%s$end\n\t%s\n" "Es necesario que entres en la interfaz web del tvheadend y te dirijas al apartado:" "- " "Configuración"  " >> " "Canal / EPG" " >> " "Módulos para Obtención de Guía" "  (en inglés: Configuration >> Channel / EPG >> EPG Grabber Modules)"
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
# Pedimos el formato de la guía de programación
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###            Elección del formato de la guía de programación            ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Ejecutando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
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
	echo -e " Ejecutando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM.tar.xz
	printf "%-$(($COLUMNS-10+1))s"  " 2. Descargando lista de canales satélite"
		ERROR=false
		rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
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
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i "\$a}\n$NOMBRE_APP" $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i "\$a}\n$NOMBRE_APP" $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
# Borramos configuración actual menos "channel" y "epggrab" de tvheadend
	printf "%-$(($COLUMNS-10+1))s"  " 3. Eliminando instalación anterior"
		rm -rf $TVHEADEND_CONFIG_DIR/bouquet/ $TVHEADEND_CONFIG_DIR/input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/ $TVHEADEND_CONFIG_DIR/picons/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
		# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
		rm -f
			if [ "$1" != "ALL" ];then
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM
				for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
				do
					if [ -f "$fichero" ]; then
						ultima=$(tail -n 1 $fichero)
						if [ "$ultima" = $NOMBRE_APP ]; then
						rm -f $fichero
						fi
					fi
				done
			else
				# Borramos todos los canales y tags
				rm -rf $TVHEADEND_CONFIG_DIR/channel/ 2>>$CARPETA_SCRIPT/dobleM.log
			fi
# Empezamos a copiar los archivos necesarios
	printf "%-$(($COLUMNS-10+1))s"  " 4. Instalando lista de canales satélite"
		ERROR=false
		cp -r $CARPETA_DOBLEM/dobleM.ver $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
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
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Damos permisos a los directorios
	printf "%-$(($COLUMNS-10+1))s" " 5. Aplicando permisos a los ficheros de configuración"
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
# Instalación de grabber. Borramos carpeta epggrab y grabber viejo. Copiamos carpeta epggrab y grabber nuevo. Damos permisos.
	printf "%-$(($COLUMNS-10+1))s"  " 6. Instalando grabber para satélite"
		if [ -f /usr/bin/tv_grab_EPG_dobleM -a $SYSTEM -eq 1 ]; then
			 rm /usr/bin/tv_grab_EPG_dobleM 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		ERROR=false
		rm -rf $TVHEADEND_CONFIG_DIR/epggrab/xmltv 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 -a $SYSTEM -ne 2 ]; then
			ERROR=true
		fi
		sed -i -- "s,dobleMgrab,$TVHEADEND_GRABBER_DIR,g" $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
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
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		if [ ! -d $TVHEADEND_GRABBER_DIR ]; then
			mkdir -p $TVHEADEND_GRABBER_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/grabber/tv_grab_EPG_dobleM $TVHEADEND_GRABBER_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown $TVHEADEND_USER:$TVHEADEND_GROUP $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod $(($TVHEADEND_PERMISSIONS-100)) $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Configuramos tvheadend y grabber para satelite
	printf "%-$(($COLUMNS-10))s"  " 7. Configurando tvheadend"
		ERROR=false
		#Idiomas EPG config tvheadend
		sed -i 's/"language": \[/"language": \[\ndobleM/g' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/dobleM/,/],/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s/\"language\": \[/\"language\": \[$FORMATO_IDIOMA_EPG\],/g" $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		#picons config tvheadend
		sed -i '/"chiconscheme": .*,/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/"piconpath": .*,/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/"piconscheme": .*,/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"prefer_picon": .*,/"prefer_picon": false,\n\t"chiconscheme": 2,\n\t"piconpath": "file:\/\/TVHEADEND_CONFIG_DIR\/picons",\n\t"piconscheme": 0,/g' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s,TVHEADEND_CONFIG_DIR,$TVHEADEND_CONFIG_DIR,g" $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		#cron y grabber config epggrab
		sed -i -e '/channel_rename/d' -e '/channel_renumber/d' -e '/channel_reicon/d' -e '/epgdb_periodicsave/d' -e '/epgdb_saveafterimport/d' -e '/cron/d' -e '/int_initial/d' -e '/ota_initial/d' -e '/ota_cron/d' -e '/ota_timeout/d' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '2i\\t"channel_rename": false,\n\t"channel_renumber": false,\n\t"channel_reicon": false,\n\t"epgdb_periodicsave": 0,\n\t"epgdb_saveafterimport": true,\n\t"cron": "# Se ejecuta todos los días a las 8:10\\n10 8 * * *",\n\t"int_initial": true,\n\t"ota_initial": false,\n\t"ota_cron": "# Configuración modificada por dobleM\\n# Desactivados todos los OTA grabber",\n\t"ota_timeout": 600,' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"enabled": .*,/"enabled": false,/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/tv_grab_EPG_dobleM/,/},/d' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/tv_grab_EPG_dobleM-IPTV/,/},/d' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"modules": {/"modules": {\n\t\t"TVHEADEND_GRABBER_DIR\/tv_grab_EPG_dobleM": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - Movistar+",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 5\n\t\t},\n\t\t"TVHEADEND_GRABBER_DIR\/tv_grab_EPG_dobleM-IPTV": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - IPTV",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 4\n\t\t},/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s,TVHEADEND_GRABBER_DIR,$TVHEADEND_GRABBER_DIR,g" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		GRABBER_ERROR=true
		fi
# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 8. Eliminando archivos temporales"
		rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 9. Iniciando tvheadend"
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

# INSTALADOR IPTV
installIPTV()
{
	clear
	LIST_ERROR=false
	GRABBER_ERROR=false
# Comprobamos que exista el fichero config en la carpeta epggrab
	if [ ! -f $TVHEADEND_CONFIG_DIR/epggrab/config ]; then
		printf "$red%s$end\n\n" "¡No continúes hasta hacer lo siguiente!:"
		printf "%s\n\t%s$blue%s$end%s$blue%s$end%s$blue%s$end\n\t%s\n" "Es necesario que entres en la interfaz web del tvheadend y te dirijas al apartado:" "- " "Configuración"  " >> " "Canal / EPG" " >> " "Módulos para Obtención de Guía" "  (en inglés: Configuration >> Channel / EPG >> EPG Grabber Modules)"
		printf "\n%s\n" "Una vez estés situado aquí, haz lo siguiente:"
		printf "\t%s$green%s$end\n" "1- Selecciona el grabber que esté en " "\"Verde\""""
		printf "\t%s$blue%s$end\n\t%s\n" "2- En el menú lateral desmarca la casilla " "\"Habilitado\"" "  (en inglés \"Enabled\")"
		printf "\t%s$blue%s$end\n\t%s\n" "3- Finalmente, pulsa sobre el botón superior " "\"Guardar\"" "  (en inglés \"Save\")"
		printf "\n%s\n\n" "Repite esta operación con todos los grabber que estén habilitados"
		CONTINUAR="n"
		while [ "$CONTINUAR" != "s" ] && [ "$CONTINUAR" != "S" ] && [ "$CONTINUAR" != "" ]; do
			read -p "Una vez haya realizado este proceso ya puedes continuar. ¿Desea continuar? [S/n]" CONTINUAR
		done
	fi
# Iniciamos instalación IPTV
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###          Iniciando instalación de canales IPTV y EPG dobleM           ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Ejecutando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
	echo
# Comprobamos que esté instalado ffmpeg
command -v ffmpeg >/dev/null 2>&1 || { printf "$red%s\n%s$end\n\n" "ERROR: Es necesario tener instalado 'ffmpeg'." "Por favor, ejecute el script de nuevo una vez haya sido instalado." && rm -rf $CARPETA_SCRIPT/i_*.sh; exit 1; }
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM.tar.xz
	printf "%-$(($COLUMNS-10))s"  " 2. Descargando lista de canales IPTV"
		ERROR=false
		rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-IPTV.tar.xz 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			echo -e "\nLa lista de canales IPTV no se ha podido descargar.\nPor favor, inténtalo más tarde."
			MENU
		fi
	# Descomprimimos el tar y marcamos con dobleM al final todos los archivos de la carpeta /channel/config/ y /channel/tag/
	tar -xf "dobleM-IPTV.tar.xz"
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i "\$a}\n$NOMBRE_APP_IPTV" $CARPETA_DOBLEM/channel/config/* 2>>$CARPETA_SCRIPT/dobleM.log
		sed -i "\$a}\n$NOMBRE_APP_IPTV" $CARPETA_DOBLEM/channel/tag/* 2>>$CARPETA_SCRIPT/dobleM.log
# Borramos configuración actual menos "channel" y "epggrab" de tvheadend
	printf "%-$(($COLUMNS-10+1))s"  " 3. Eliminando instalación anterior"
		rm -rf $TVHEADEND_CONFIG_DIR/input/iptv/networks/f80013f7cb7dc75ed04b0312fa362ae1/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
			# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
			rm -f
				if [ "$1" != "ALL" ];then
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM
					for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_APP_IPTV ]; then
							rm -f $fichero
							fi
						fi
					done
				else
					# Borramos todos los canales y tags
					rm -rf $TVHEADEND_CONFIG_DIR/channel/
				fi
# Empezamos a copiar los archivos necesarios
	printf "%-$(($COLUMNS-10))s"  " 4. Instalando lista de canales IPTV"
		ERROR=false
		sed -i "s#FFMPEG_TEMP#$FFMPEG_COMMAND#g" $CARPETA_DOBLEM/dobleM-IPTV.sh && chmod +rx $CARPETA_DOBLEM/dobleM-IPTV.sh && cp -r $CARPETA_DOBLEM/dobleM-IPTV.sh /var 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/dobleM-IPTV.ver $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			LIST_ERROR=true
		fi
# Damos permisos a los directorios
	printf "%-$(($COLUMNS-10+1))s" " 5. Aplicando permisos a los ficheros de configuración"
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
# Instalación de grabber. Borramos grabber viejo. Copiamos grabber nuevo. Damos permisos.
	printf "%-$(($COLUMNS-10))s"  " 6. Instalando grabber para IPTV"
		if [ -f /usr/bin/tv_grab_EPG_dobleM-IPTV -a $SYSTEM -eq 1 ]; then
			 rm /usr/bin/tv_grab_EPG_dobleM-IPTV 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		ERROR=false
		rm -rf $TVHEADEND_CONFIG_DIR/epggrab/xmltv 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 -a $SYSTEM -ne 2 ]; then
			ERROR=true
		fi
		sed -i -- "s,dobleMgrab,$TVHEADEND_GRABBER_DIR,g" $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/* 2>>$CARPETA_SCRIPT/dobleM.log
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
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		if [ ! -d $TVHEADEND_GRABBER_DIR ]; then
			mkdir -p $TVHEADEND_GRABBER_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		fi
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		cp -r $CARPETA_DOBLEM/grabber/tv_grab_EPG_dobleM-IPTV $TVHEADEND_GRABBER_DIR/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chown $TVHEADEND_USER:$TVHEADEND_GROUP $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-IPTV 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod $(($TVHEADEND_PERMISSIONS-100)) $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-IPTV 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM-IPTV 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
			GRABBER_ERROR=true
		fi
# Configuramos tvheadend y grabber para IPTV
	printf "%-$(($COLUMNS-10))s"  " 7. Configurando tvheadend"
		ERROR=false
		#cron y grabber config epggrab
		sed -i -e '/channel_rename/d' -e '/channel_renumber/d' -e '/channel_reicon/d' -e '/epgdb_periodicsave/d' -e '/epgdb_saveafterimport/d' -e '/cron/d' -e '/int_initial/d' -e '/ota_initial/d' -e '/ota_cron/d' -e '/ota_timeout/d' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '2i\\t"channel_rename": false,\n\t"channel_renumber": false,\n\t"channel_reicon": false,\n\t"epgdb_periodicsave": 0,\n\t"epgdb_saveafterimport": true,\n\t"cron": "# Se ejecuta todos los días a las 8:10\\n10 8 * * *",\n\t"int_initial": true,\n\t"ota_initial": false,\n\t"ota_cron": "# Configuración modificada por dobleM\\n# Desactivados todos los OTA grabber",\n\t"ota_timeout": 600,' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"enabled": .*,/"enabled": false,/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/tv_grab_EPG_dobleM/,/},/d' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/tv_grab_EPG_dobleM-IPTV/,/},/d' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i 's/"modules": {/"modules": {\n\t\t"TVHEADEND_GRABBER_DIR\/tv_grab_EPG_dobleM": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - Movistar+",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 5\n\t\t},\n\t\t"TVHEADEND_GRABBER_DIR\/tv_grab_EPG_dobleM-IPTV": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - IPTV",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 4\n\t\t},/g' $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s,TVHEADEND_GRABBER_DIR,$TVHEADEND_GRABBER_DIR,g" $TVHEADEND_CONFIG_DIR/epggrab/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		GRABBER_ERROR=true
		fi
# Borramos carpeta termporal dobleM
	printf "%-$(($COLUMNS-10))s"  " 8. Eliminando archivos temporales"
		rm -rf $CARPETA_DOBLEM 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Reiniciamos tvheadend
	printf "%-$(($COLUMNS-10))s"  " 9. Iniciando tvheadend"
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

# CAMBIAR FORMATO EPG
cambioformatoEPG()
{
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###        Iniciando cambio de formato de la guía de programación         ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Ejecutando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
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
		echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Aplicamos cambio formato de EPG
	printf "%-$(($COLUMNS-10+2))s"  " 2. Cambiando formato de la guía de programación"
		ERROR=false
		sed -i 's/"language": \[/"language": \[\ndobleM/g' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i '/dobleM/,/],/d' $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		sed -i "s/\"language\": \[/\"language\": \[$FORMATO_IDIOMA_EPG\],/g" $TVHEADEND_CONFIG_DIR/config 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
		printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
		printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
# Aplicamos cambio tipo de imagen de EPG
	printf "%-$(($COLUMNS-10+3))s"  " 3. Cambiando tipo de imágenes de la guía de programación"
		$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_dobleM 2>>$CARPETA_SCRIPT/dobleM.log
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

# LIMPIEZA TOTAL DE CANALES
limpiezatotal()
{
	clear
	echo -e "$blue ############################################################################# $end"
	echo -e "$blue ###                 Iniciando limpieza total de tvheadend                 ### $end"
	echo -e "$blue ############################################################################# $end"
	echo -e " Ejecutando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
	echo
# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos
	printf "%-$(($COLUMNS-10))s"  " 1. Deteniendo tvheadend"
		cd $CARPETA_SCRIPT
		PARAR_TVHEADEND
# Borramos carpeta "channel" de tvheadend
	printf "%-$(($COLUMNS-10+1))s"  " 2. Borrando toda la configuración de tvheadend"
		cd $TVHEADEND_CONFIG_DIR
		rm -rf $TVHEADEND_CONFIG_DIR/dobleM*.ver $TVHEADEND_CONFIG_DIR/bouquet/ $TVHEADEND_CONFIG_DIR/channel/ $TVHEADEND_CONFIG_DIR/epggrab/xmltv $TVHEADEND_CONFIG_DIR/input/ $TVHEADEND_CONFIG_DIR/picons/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 ]; then
			printf "%s$green%s$end%s\n" "[" "  OK  " "]"
		else
			printf "%s$red%s$end%s\n" "[" "FAILED" "]"
		fi
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
	echo -e " Ejecutando script$green $SISTEMA_ELEGIDO$end en$yellow $SYSTEM_INFO$end"
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
# Borramos carpetas/ficheros y descomprimimos el fichero de backup
	printf "%-$(($COLUMNS-10))s"  " 3. Restaurando copia de seguridad"
		ERROR=false
		rm -rf $TVHEADEND_CONFIG_DIR/accesscontrol/ $TVHEADEND_CONFIG_DIR/bouquet/ $TVHEADEND_CONFIG_DIR/caclient/ $TVHEADEND_CONFIG_DIR/channel/ $TVHEADEND_CONFIG_DIR/codec/ $TVHEADEND_CONFIG_DIR/config $TVHEADEND_CONFIG_DIR/epggrab/ $TVHEADEND_CONFIG_DIR/input/ $TVHEADEND_CONFIG_DIR/passwd/ $TVHEADEND_CONFIG_DIR/picons/ $TVHEADEND_CONFIG_DIR/profile/ $TVHEADEND_CONFIG_DIR/service_mapper/ 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -ne 0 ]; then
			ERROR=true
		fi
		tar -xf "$CARPETA_SCRIPT/$FILE_BACKUP" -C $TVHEADEND_CONFIG_DIR 2>>$CARPETA_SCRIPT/dobleM.log
		if [ $? -eq 0 -a $ERROR = "false" ]; then
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
ver_local=`cat $TVHEADEND_CONFIG_DIR/dobleM.ver 2>/dev/null`
ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.ver 2>/dev/null`
ver_local_IPTV=`cat $TVHEADEND_CONFIG_DIR/dobleM-IPTV.ver 2>/dev/null`
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
	echo -e " Directorio tvheadend:$yellow $TVHEADEND_CONFIG_DIR $end"
	echo -e " Directorio   grabber:$yellow $TVHEADEND_GRABBER_DIR $end"
	echo
	echo -e " Versión SATELITE instalada:$red $ver_local $end --->  Nueva versión:$green $ver_web $end"
	echo -e " Versión   IPTV   instalada:$red $ver_local_IPTV $end --->  Nueva versión:$green $ver_web_IPTV $end"
	echo _______________________________________________________________________________
	echo
	echo -e " 1)$green Hacer copia de seguridad de tvheadend $end"
	echo -e " 2)$cyan Instalar lista de canales$yellow SATELITE $end+ picons, grabber y configurar tvheadend $end"
	echo -e " 3)$cyan Instalar lista de canales$yellow IPTV $end+ picons, grabber y configurar tvheadend $end"
	echo -e " 4)$cyan Cambiar el formato de la guía de programación $end"
	echo -e " 5)$cyan Hacer una limpieza$red TOTAL$end$cyan de tvheadend $end"
	echo -e " 6)$green Restaurar copia de seguridad $end(Usa el fichero mas reciente que encuentre) $end"
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
		7) rm -rf $CARPETA_SCRIPT/i_dobleMi.sh && clear && sh $CARPETA_SCRIPT/i_dobleM.sh; break;;
		8) rm -rf $CARPETA_SCRIPT/i_*.sh; exit;;
		*) echo "$opcion es una opción inválida\n";
	esac
done
}
MENU

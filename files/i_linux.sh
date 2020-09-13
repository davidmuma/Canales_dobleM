#!/bin/bash
#### Script creado por dobleM

# Variables
NOMBRE_SCRIPT="i_linux.sh"
CARPETA_SCRIPT="$PWD"
CARPETA_TVH="/home/david/.hts/tvheadend"
CARPETA_GRABBER="/usr/local/bin"

CARPETA_DOBLEM="$CARPETA_TVH/dobleM"
carpeta_channel="$CARPETA_TVH/channel/config/*"
carpeta_tag="$CARPETA_TVH/channel/tag/*"

ver_local=`cat $CARPETA_TVH/dobleM.ver 2>/dev/null`
ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.ver 2>/dev/null`

INFO_SISTEMA="$(uname -a)"

clear

# Copia de seguridad
backup()
{
	echo "Realizando copia de seguridad"
	cd $CARPETA_TVH
	if [ -f "$CARPETA_SCRIPT/Backup_Tvheadend_$(date +"%Y-%m-%d").tar.xz" ]; then
		FILE="Backup_Tvheadend_$(date +"%Y-%m-%d__%H-%M-%S").tar.xz"
		tar -cJf $CARPETA_SCRIPT/$FILE bouquet channel epggrab input/dvb picons 
		echo "Copia de seguridad completada. Pulsa intro para continuar..."
		read CAD
	else
		FILE="Backup_Tvheadend_$(date +"%Y-%m-%d").tar.xz"
		tar -cJf $CARPETA_SCRIPT/$FILE bouquet channel epggrab input/dvb picons 
		echo "Copia de seguridad completada. Pulsa intro para continuar..."
		read CAD
	fi
}

install()
{
	echo
	echo "\e[36m##############################################################\e[0m" 
	echo "\e[36m#   Iniciando instalación de lista de canales y EPG dobleM   #\e[0m" 
	echo "\e[36m##############################################################\e[0m" 	

#Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos	
	echo
	echo "\e[38;5;198m1. Parando servicio tvheadend\e[0m"
#		/etc/init.d/tvheadend stop
				
# Borramos grabber anterior y carpeta dobleM. Vamos al directorio principal de tvheadend y borramos configuración actual	
	echo
	echo "\e[38;5;198m2. Borrando instalación anterior\e[0m"
	rm -f $CARPETA_GRABBER/tv_grab_EPG_dobleM
	rm -rf $CARPETA_DOBLEM
	cd $CARPETA_TVH
	rm -rf picons/
	rm -rf bouquet/
	rm -rf channel/
	rm -rf epggrab/
	rm -rf input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/

# Descargamos el tar de dobleM y lo descomprimimos en CARPETA_DOBLEM		
	echo
	echo "\e[38;5;198m3. Descargando nueva lista de canales dobleM\e[0m" 		
		mkdir $CARPETA_DOBLEM
		cd $CARPETA_DOBLEM
		wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.tar.xz
		tar -xf "dobleM.tar.xz"

# Empezamos a copiar los archivos necesarios
	echo	
	echo "\e[38;5;198m4. Instalando lista de canales dobleM\e[0m"
		cp -r $CARPETA_DOBLEM/dobleM.ver $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/picons/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/data/* $CARPETA_TVH

# Copiamos el grabber
	echo			
	echo "\e[38;5;198m5. Instalando grabber dobleM\e[0m"		
		cp -r $CARPETA_DOBLEM/grabber/* $CARPETA_GRABBER
		
while :	
do
	echo "   5a. Eligue si quieres la guía con imágenes tipo posters o fanarts"
	echo "	1. Posters"
	echo "	2. Fanarts"
	echo -n "	Indica una opción: "
	read opcion
	case $opcion in
			1) sed -i 's/enable_fanart=.*/enable_fanart=false/g' $CARPETA_GRABBER/tv_grab_EPG_dobleM; break;;
			2) sed -i 's/enable_fanart=.*/enable_fanart=true/g' $CARPETA_GRABBER/tv_grab_EPG_dobleM; break;;	
			*) echo "$opcion es una opción inválida";
	esac
done

# Damos permisos a los directorios y al grabber
	echo
	echo "\e[38;5;198m6. Estableciendo permisos\e[0m"									
		chmod +x $CARPETA_TVH/picons/
		chmod +x $CARPETA_TVH/bouquet/
		chmod +x $CARPETA_TVH/channel/
		chmod +x $CARPETA_TVH/epggrab/
		chmod +x $CARPETA_TVH/input/
		chmod +x $CARPETA_GRABBER/tv_grab_EPG_dobleM
	
# Configuramos tvheadend
	echo
	echo "\e[38;5;198m7. Configurando tvheadend\e[0m"
		#Idiomas EPG config tvheadend
		sed -i 's/"language": \[/"language": \[\ndobleM/g' $CARPETA_TVH/config
		sed -i '/dobleM/,/],/d' $CARPETA_TVH/config
		sed -i 's/"language": \[/"language": \[\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t\],/g' $CARPETA_TVH/config
		#picons config tvheadend
		sed -i 's/"prefer_picon": .*,/"prefer_picon": false,/g' $CARPETA_TVH/config
		sed -i 's/"chiconscheme": .*,/"chiconscheme": 2,/g' $CARPETA_TVH/config
		sed -i 's/"piconpath": .*,/"piconpath": "file:\/\/CARPETA_TVH\/picons",/g' $CARPETA_TVH/config
		sed -i 's/"piconscheme": .*,/"piconscheme": 0,/g' $CARPETA_TVH/config
		sed -i "s,CARPETA_TVH,$CARPETA_TVH,g" $CARPETA_TVH/config
		#cron y grabber config epggrab
		sed -i 's/"cron": .*,/"cron": "# Se ejecuta todos los días a las 8:10\\n10 8 * * *",/g' $CARPETA_TVH/epggrab/config
		sed -i '/tv_grab_EPG_dobleM/,/},/d' $CARPETA_TVH/epggrab/config
		sed -i 's/"modules": {/"modules": {\n\t\t"CARPETA_GRABBER\/tv_grab_EPG_dobleM": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - Movistar+",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 3\n\t\t},/g' $CARPETA_TVH/epggrab/config
		sed -i "s,CARPETA_GRABBER,$CARPETA_GRABBER,g" $CARPETA_TVH/epggrab/config
		
# Borramos carpeta termporal dobleM
	echo
	echo "\e[38;5;198m8. Eliminando archivos temporales\e[0m"
		rm -rf $CARPETA_DOBLEM
	
# Reiniciamos el servicio de TVH
	echo
	echo "\e[38;5;198m9. Iniciando servicio tvheadend\e[0m" 
#		/etc/init.d/tvheadend start

# Fin instalación
	echo	
	echo "La primera captura de EPG tardará unos minutos hasta que todos"
	echo "los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo "tvheadend ha quedado configurado de la siguiente manera:"
	echo " Spanish - Guía con etiquetas de colores"
	echo " English - Guía sin etiquetas de colores"
	echo " German - Guía con etiquetas de colores, título en una sola linea"
	echo " French - Guía sin etiquetas de colores, título en una sola linea y sin caracteres especiales"
	echo
	echo "\e[36m###############################################################\e[0m" 
	echo "\e[36m###                Gracias por usar dobleM                  ###\e[0m" 
	echo "\e[36m###############################################################\e[0m" 
	echo
}

# Preguntamos si es todo correcto
while :	
do
	echo "\e[36m###############################################################\e[0m" 
	echo "\e[36m#   \e[38;5;198m¡PRECAUCION!\e[0m   \e[36mComprueba que el sistema y los directorios #\e[0m" 
	echo "\e[36m# de instalación sean correctos, en caso de duda no continues #\e[0m" 
	echo "\e[36m# Si continuas se borrará cualquier lista de canales anterior #\e[0m"
	echo "\e[36m###############################################################\e[0m" 
	echo
	echo "Se ha detectado el sistema operativo: \e[38;5;198m$INFO_SISTEMA\e[0m\n"
	echo "Vas a ejecutar el script para el sistema: \e[32m$NOMBRE_SCRIPT\e[0m"
	echo "Directorio instalación tvheadend: \e[32m$CARPETA_TVH\e[0m"
	echo "Directorio instalación grabber: \e[32m$CARPETA_GRABBER\e[0m\n"
	echo "Versión instalada: \e[31m$ver_local\e[0m ---> Nueva versión: \e[32m$ver_web\e[0m\n"
	echo "---------------------------------------------------------------\n"
	echo "1) \e[0;32mHacer copia de seguridad\e[0m"
	echo
	echo "2) \e[0;36mInstalar lista de canales, picons, grabber y configurar tvheadend\e[0m"
	echo 
    echo "3) \e[31mVolver\e[0m"
	echo
	echo -n "Indica una opción: "
	read opcion
	case $opcion in
		1) backup && clear;;
		2) install; break;;
		3) clear && sudo sh $CARPETA_SCRIPT/dobleM.sh; break;;	
		*) echo "$opcion es una opción inválida";
	esac
done
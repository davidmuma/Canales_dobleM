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

# Variables
NOMBRE_SCRIPT="i_linux.sh"
CARPETA_TVH="/home/hts/.hts/tvheadend"
CARPETA_GRABBER="/usr/bin"
SERVICE_TVH="tvheadend"
PARAR_TVHEADEND="sudo service $SERVICE_TVH stop"
INICIAR_TVHEADEND="sudo service $SERVICE_TVH start"

NOMBRE_APP="dobleM"
NOMBRE_APP_IPTV="dobleM-IPTV"
CARPETA_DOBLEM="$CARPETA_TVH/dobleM"
CARPETA_SCRIPT="$PWD"

Infdir_linux="find /home -maxdepth 4 -type d -iname tvheadend*"								#/home/hts/.hts/tvheadend
Infdir_syno="find /var -maxdepth 3 -type d -iname tvheadend*"								#/var/packages/tvheadend/target/var
Infdir_libre="find /storage/.kodi/userdata -maxdepth 5 -type d -iname service.tvheadend*"	#/storage/.kodi/userdata/addon_data/service.tvheadend43
Infdir_alex="find /storage -maxdepth 3 -type d -iname tvheadend*"							#/storage/.config/tvheadend
INFO_SISTEMA="$(sed -e '/PRETTY_NAME=/!d' -e 's/PRETTY_NAME=//g' /etc/*-release)"
INFO_CARPETA_TVH="$($Infdir_linux & $Infdir_syno & $Infdir_libre & $Infdir_alex)"
INFO_CARPETA_GRABBER="$(which tvheadend | sed 's/\/tvheadend//')"

	USER_TVH=$(stat -c %U $CARPETA_TVH/config)
	GROUP_TVH=$(stat -c %G $CARPETA_TVH/config)

		TVHEADEND_CHANNEL_PERMISSIONS="777"
        TVHEADEND_INPUT_PERMISSIONS="755"      
        TVHEADEND_PICONS_PERMISSIONS="755"
        TVHEADEND_EPGGRAB_PERMISSIONS="755"
		TVHEADEND_BOUQUET_PERMISSIONS="755"

ver_local=`cat $CARPETA_TVH/dobleM.ver 2>/dev/null`
ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.ver 2>/dev/null`

ver_local_IPTV=`cat $CARPETA_TVH/dobleM-IPTV.ver 2>/dev/null`
ver_web_IPTV=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-IPTV.ver 2>/dev/null`

# COPIA DE SEGURIDAD
backup()
{
	echo
	echo -e "$blue ################################################################ $end"
	echo -e "$blue ###               Iniciando copia de seguridad               ### $end" 
	echo -e "$blue ################################################################ $end"

# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos	
	echo
	echo -e "$magenta 1. Parando servicio tvheadend $end"
		$PARAR_TVHEADEND
		cd $CARPETA_TVH

# Hacemos la copia de seguridad
	echo
	echo -e "$magenta 2. Realizando copia de seguridad $end"	
	if [ -f "$CARPETA_SCRIPT/Backup_Tvheadend_$(date +"%Y-%m-%d").tar.xz" ]; then
		FILE="Backup_Tvheadend_$(date +"%Y-%m-%d__%H-%M-%S").tar.xz"
		tar -cjf $CARPETA_SCRIPT/$FILE bouquet channel epggrab input/dvb input/iptv picons 2>/dev/null
	else
		FILE="Backup_Tvheadend_$(date +"%Y-%m-%d").tar.xz"
		tar -cjf $CARPETA_SCRIPT/$FILE bouquet channel epggrab input/dvb input/iptv picons 2>/dev/null
	fi
	
# Reiniciamos el servicio de tvheadend
	echo
	echo -e "$magenta 3. Iniciando servicio tvheadend $end"
		cd $CARPETA_SCRIPT
		$INICIAR_TVHEADEND	

# Fin copia de seguridad		
	echo
	echo -e "$blue ################################################################ $end"
	echo -e "$blue ###              Copia de seguridad completada               ### $end" 
	echo -e "$blue ################################################################ $end"
		echo
		echo -e "$green Pulsa intro para continuar... $end"
		read CAD
}

# INSTALADOR SATELITE
install()
{
	echo
	echo -e "$blue ################################################################ $end"
	echo -e "$blue ###  Iniciando instalación de canales satélite y EPG dobleM  ### $end" 
	echo -e "$blue ################################################################ $end" 	

# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos	
	echo
	echo -e "$magenta 1. Parando servicio tvheadend $end"
		$PARAR_TVHEADEND
		cd $CARPETA_TVH
				
# Borramos carpeta dobleM y configuración actual menos "channel" y "epggrab" de tvheadend
	echo
	echo -e "$magenta 2. Borrando instalación anterior $end"
	rm -rf $CARPETA_DOBLEM
	rm -rf $CARPETA_TVH/bouquet/
	rm -rf $CARPETA_TVH/input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/
	rm -rf $CARPETA_TVH/picons/
	
# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
	rm -f 
		if [ "$1" != "ALL" ];then
			# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM
			for fichero in $CARPETA_TVH/channel/config/* $CARPETA_TVH/channel/tag/*
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
			rm -rf $CARPETA_TVH/channel/
	fi		

# Descargamos el tar de dobleM y lo descomprimimos en CARPETA_DOBLEM		
	echo
	echo -e "$magenta 3. Descargando nueva lista de canales $end" 		
		mkdir $CARPETA_DOBLEM
		cd $CARPETA_DOBLEM
		wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.tar.xz
		tar -xf "dobleM.tar.xz"
	# Marcamos con dobleM al final todos los archivos de la carpeta /channel/config/ y /channel/tag/
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/*
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/*
		sed -i "\$a}\n$NOMBRE_APP" $CARPETA_DOBLEM/channel/config/*
		sed -i "\$a}\n$NOMBRE_APP" $CARPETA_DOBLEM/channel/tag/*

# Empezamos a copiar los archivos necesarios
	echo	
	echo -e "$magenta 4. Instalando lista de canales $end"
		cp -r $CARPETA_DOBLEM/dobleM.ver $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/bouquet/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/channel/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/input/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/picons/ $CARPETA_TVH

# Instalación de grabber. Borramos carpeta epggrab y grabber viejo. Copiamos carpeta epggrab y grabber nuevos. Damos permisos.
	echo			
	echo -e "$magenta 5. Instalando grabber $end"
		rm -f $CARPETA_GRABBER/tv_grab_EPG_dobleM
		cp -r $CARPETA_DOBLEM/grabber/tv_grab_EPG_dobleM $CARPETA_GRABBER
		
		rm -rf $CARPETA_TVH/epggrab/xmltv/
		cp -r $CARPETA_DOBLEM/epggrab/ $CARPETA_TVH
		sed -i -- "s,\"modid\":.*,\"modid\": \"$CARPETA_GRABBER/tv_grab_EPG_dobleM\"\,,g" $CARPETA_TVH/epggrab/xmltv/channels/*	
while :	
do
	echo "      5a. Escoge que tipo de imágenes quieres que aparezcan en la guía:"
	echo "	1) Posters"
	echo "	2) Fanarts"
	echo -n "	Indica una opción: "
	read opcion
	case $opcion in
			1) sed -i 's/enable_fanart=.*/enable_fanart=false/g' $CARPETA_GRABBER/tv_grab_EPG_dobleM; break;;
			2) sed -i 's/enable_fanart=.*/enable_fanart=true/g' $CARPETA_GRABBER/tv_grab_EPG_dobleM; break;;	
			*) echo "$opcion es una opción inválida";
	esac
done		
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_GRABBER/tv_grab_EPG_dobleM
		chmod +rx $CARPETA_GRABBER/tv_grab_EPG_dobleM
		
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/epggrab/
		chmod -R $TVHEADEND_EPGGRAB_PERMISSIONS $CARPETA_TVH/epggrab/

# Damos permisos a los directorios
	echo
	echo -e "$magenta 6. Aplicando permisos $end"
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/bouquet/
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/channel/
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/input/
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/picons/
		
		chmod -R $TVHEADEND_BOUQUET_PERMISSIONS $CARPETA_TVH/bouquet/
		chmod -R $TVHEADEND_CHANNEL_PERMISSIONS $CARPETA_TVH/channel/
		chmod -R $TVHEADEND_INPUT_PERMISSIONS $CARPETA_TVH/input/
		chmod -R $TVHEADEND_PICONS_PERMISSIONS $CARPETA_TVH/picons/
	
# Configuramos tvheadend
	echo
	echo -e "$magenta 7. Configurando tvheadend $end"
		#Idiomas EPG config tvheadend
		sed -i 's/"language": \[/"language": \[\ndobleM/g' $CARPETA_TVH/config
		sed -i '/dobleM/,/],/d' $CARPETA_TVH/config
		sed -i 's/"language": \[/"language": \[\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t\],/g' $CARPETA_TVH/config
		#picons config tvheadend
		sed -i '/"chiconscheme": .*,/d' $CARPETA_TVH/config
		sed -i '/"piconpath": .*,/d' $CARPETA_TVH/config
		sed -i '/"piconscheme": .*,/d' $CARPETA_TVH/config
		sed -i 's/"prefer_picon": .*,/"prefer_picon": false,\n\t"chiconscheme": 2,\n\t"piconpath": "file:\/\/CARPETA_TVH\/picons",\n\t"piconscheme": 0,/g' $CARPETA_TVH/config
		sed -i "s,CARPETA_TVH,$CARPETA_TVH,g" $CARPETA_TVH/config
		#cron y grabber config epggrab
		sed -i 's/"cron": .*,/"cron": "# Se ejecuta todos los días a las 8:10\\n10 8 * * *",/g' $CARPETA_TVH/epggrab/config
		sed -i 's/"enabled": .*,/"enabled": false,/g' $CARPETA_TVH/epggrab/config
		sed -i '/tv_grab_EPG_dobleM/,/},/d' $CARPETA_TVH/epggrab/config
		sed -i '/tv_grab_EPG_dobleM-IPTV/,/},/d' $CARPETA_TVH/epggrab/config
		sed -i 's/"modules": {/"modules": {\n\t\t"CARPETA_GRABBER\/tv_grab_EPG_dobleM": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - Movistar+",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 3\n\t\t},\n\t\t"CARPETA_GRABBER\/tv_grab_EPG_dobleM-IPTV": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - IPTV",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 3\n\t\t},/g' $CARPETA_TVH/epggrab/config
		sed -i "s,CARPETA_GRABBER,$CARPETA_GRABBER,g" $CARPETA_TVH/epggrab/config
		
# Borramos carpeta termporal dobleM
	echo
	echo -e "$magenta 8. Eliminando archivos temporales $end"
		rm -rf $CARPETA_DOBLEM
	
# Reiniciamos el servicio de tvheadend
	echo
	echo -e "$magenta 9. Iniciando servicio tvheadend $end"
		cd $CARPETA_SCRIPT
		$INICIAR_TVHEADEND

# Fin instalación
	echo
	echo " Acuerdate de asignar en cada sintonizador \"Red DVB-S\" en la pestaña:"
	echo "   Configuración --- Entradas DVB --- Adaptadores de TV"
	echo
	echo " La primera captura de EPG tardará unos minutos hasta que todos"
	echo " los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo " tvheadend ha quedado configurado de la siguiente manera:"
	echo "  Spanish - Guía con etiquetas de colores"
	echo "  English - Guía sin etiquetas de colores"
	echo "  German - Guía con etiquetas de colores, título en una sola linea"
	echo "  French - Guía sin etiquetas de colores, título en una sola linea y sin caracteres especiales"
	echo
	echo -e "$blue ################################################################# $end"
	echo -e "$blue ###     Instalación completada, gracias por usar dobleM       ### $end" 
	echo -e "$blue ################################################################# $end" 
		echo
		echo -e "$green Pulsa intro para continuar... $end"
		read CAD
}

# INSTALADOR IPTV
installIPTV()
{
	echo
	echo -e "$blue ################################################################ $end"
	echo -e "$blue ###    Iniciando instalación de canales IPTV y EPG dobleM    ### $end" 
	echo -e "$blue ################################################################ $end" 	

# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos	
	echo
	echo -e "$magenta 1. Parando servicio tvheadend $end"
		$PARAR_TVHEADEND
		cd $CARPETA_TVH
				
# Borramos carpeta dobleM e input actual de tvheadend
	echo
	echo -e "$magenta 2. Borrando instalación anterior $end"
	rm -rf $CARPETA_DOBLEM
	rm -rf $CARPETA_TVH/input/iptv/networks/d040f9ac2f2bfe2df2af82722cf1a7b6/
	
# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
	rm -f 
		if [ "$1" != "ALL" ];then
			# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM
			for fichero in $CARPETA_TVH/channel/config/* $CARPETA_TVH/channel/tag/*
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
			rm -rf $CARPETA_TVH/channel/
	fi		

# Descargamos el tar de dobleM y lo descomprimimos en CARPETA_DOBLEM		
	echo
	echo -e "$magenta 3. Descargando nueva lista de canales $end" 		
		mkdir $CARPETA_DOBLEM
		cd $CARPETA_DOBLEM
		wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM-IPTV.tar.xz
		tar -xf "dobleM-IPTV.tar.xz"
	# Marcamos con dobleM al final todos los archivos de la carpeta /channel/config/ y /channel/tag/
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/*
		sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/*
		sed -i "\$a}\n$NOMBRE_APP_IPTV" $CARPETA_DOBLEM/channel/config/*
		sed -i "\$a}\n$NOMBRE_APP_IPTV" $CARPETA_DOBLEM/channel/tag/*

# Empezamos a copiar los archivos necesarios
	echo	
	echo -e "$magenta 4. Instalando lista de canales $end"
		cp -r $CARPETA_DOBLEM/dobleM-IPTV.ver $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/channel/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/input/ $CARPETA_TVH

# Instalación de grabbers. Borramos grabbers viejos y copiamos grabbers nuevos. Damos permisos.
	echo			
	echo -e "$magenta 5. Instalando grabber $end"
		rm -f $CARPETA_GRABBER/tv_grab_EPG_dobleM-IPTV		
		cp -r $CARPETA_DOBLEM/grabber/tv_grab_EPG_dobleM-IPTV $CARPETA_GRABBER
			
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_GRABBER/tv_grab_EPG_dobleM-IPTV
		chmod +rx $CARPETA_GRABBER/tv_grab_EPG_dobleM-IPTV

# Damos permisos a los directorios
	echo
	echo -e "$magenta 6. Aplicando permisos $end"
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/channel/
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/input/
		
		chmod -R $TVHEADEND_CHANNEL_PERMISSIONS $CARPETA_TVH/channel/
		chmod -R $TVHEADEND_INPUT_PERMISSIONS $CARPETA_TVH/input/
	
# Configuramos tvheadend
	echo
	echo -e "$magenta 7. Configurando tvheadend $end"
		#Idiomas EPG config tvheadend
		sed -i 's/"language": \[/"language": \[\ndobleM/g' $CARPETA_TVH/config
		sed -i '/dobleM/,/],/d' $CARPETA_TVH/config
		sed -i 's/"language": \[/"language": \[\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t\],/g' $CARPETA_TVH/config
		#picons config tvheadend
		sed -i '/"chiconscheme": .*,/d' $CARPETA_TVH/config
		sed -i '/"piconpath": .*,/d' $CARPETA_TVH/config
		sed -i '/"piconscheme": .*,/d' $CARPETA_TVH/config
		sed -i 's/"prefer_picon": .*,/"prefer_picon": false,\n\t"chiconscheme": 2,\n\t"piconpath": "file:\/\/CARPETA_TVH\/picons",\n\t"piconscheme": 0,/g' $CARPETA_TVH/config
		sed -i "s,CARPETA_TVH,$CARPETA_TVH,g" $CARPETA_TVH/config
		#cron y grabber config epggrab
		sed -i 's/"cron": .*,/"cron": "# Se ejecuta todos los días a las 8:10\\n10 8 * * *",/g' $CARPETA_TVH/epggrab/config
		sed -i 's/"enabled": .*,/"enabled": false,/g' $CARPETA_TVH/epggrab/config
		sed -i '/tv_grab_EPG_dobleM/,/},/d' $CARPETA_TVH/epggrab/config
		sed -i '/tv_grab_EPG_dobleM-IPTV/,/},/d' $CARPETA_TVH/epggrab/config
		sed -i 's/"modules": {/"modules": {\n\t\t"CARPETA_GRABBER\/tv_grab_EPG_dobleM": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - Movistar+",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 3\n\t\t},\n\t\t"CARPETA_GRABBER\/tv_grab_EPG_dobleM-IPTV": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - IPTV",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 3\n\t\t},/g' $CARPETA_TVH/epggrab/config
		sed -i "s,CARPETA_GRABBER,$CARPETA_GRABBER,g" $CARPETA_TVH/epggrab/config
		
# Borramos carpeta termporal dobleM
	echo
	echo -e "$magenta 8. Eliminando archivos temporales $end"
		rm -rf $CARPETA_DOBLEM
	
# Reiniciamos el servicio de tvheadend
	echo
	echo -e "$magenta 9. Iniciando servicio tvheadend $end"
		cd $CARPETA_SCRIPT
		$INICIAR_TVHEADEND

# Fin instalación
	echo
	echo " La primera captura de EPG tardará unos minutos hasta que todos"
	echo " los procesos de tvheadend se terminen de iniciar, ten paciencia."
	echo
	echo -e "$blue ################################################################# $end"
	echo -e "$blue ###     Instalación completada, gracias por usar dobleM       ### $end" 
	echo -e "$blue ################################################################# $end" 
		echo
		echo -e "$green Pulsa intro para continuar... $end"
		read CAD
}

# CAMBIAR IMAGENES GRABBER
imagenesgrabber()
{
	echo
	echo -e "$blue ################################################################ $end"
	echo -e "$blue ###     Iniciando cambio de tipo de imágenes en grabber      ### $end" 
	echo -e "$blue ################################################################ $end" 
while :	
do
	echo
	echo -e "$cyan Escoge que tipo de imágenes quieres que aparezcan en la guía: $end"
	echo -e "$yellow 1) Posters $end"
	echo -e "$yellow 2) Fanarts $end"
	echo -n "    Indica una opción: "
	read opcion
	case $opcion in
			1) sed -i 's/enable_fanart=.*/enable_fanart=false/g' $CARPETA_GRABBER/tv_grab_EPG_dobleM; break;;
			2) sed -i 's/enable_fanart=.*/enable_fanart=true/g' $CARPETA_GRABBER/tv_grab_EPG_dobleM; break;;	
			*) echo "$opcion es una opción inválida";
	esac
done
	echo
	echo -e "$blue ################################################################# $end"
	echo -e "$blue ###               Cambio realizado correctamente              ### $end" 
	echo -e "$blue ################################################################# $end"
		echo
		echo -e "$green Pulsa intro para continuar... $end"
		read CAD
}

# LIMPIEZA TOTAL DE CANALES
limpiezatotalcanales()
{
	echo
	echo -e "$blue ################################################################ $end"
	echo -e "$blue ###            Iniciando limpieza total de canales           ### $end" 
	echo -e "$blue ################################################################ $end" 	

# Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos	
	echo
	echo -e "$magenta 1. Parando servicio tvheadend $end"
		$PARAR_TVHEADEND
		cd $CARPETA_TVH
				
# Borramos carpeta "channel" de tvheadend
	echo
	echo -e "$magenta 2. Borrando carpeta de canales $end"
	rm -rf $CARPETA_TVH/channel/
	
# Reiniciamos el servicio de tvheadend
	echo
	echo -e "$magenta 3. Iniciando servicio tvheadend $end"
		cd $CARPETA_SCRIPT
		$INICIAR_TVHEADEND
		
# Fin limpieza
	echo
	echo -e "$blue ################################################################# $end"
	echo -e "$blue ###              Limpieza realizada correctamente             ### $end" 
	echo -e "$blue ################################################################# $end"
		echo
		echo -e "$green Pulsa intro para continuar... $end"
		read CAD
}

# MENU INSTALACION
while :	
do
clear
	echo
	echo -e "$blue ################################################################# $end" 
	echo -e "$blue #                       $green -= dobleM =- $end                         $blue # $end" 
	echo -e "$blue #                 Telegram: $cyan t.me/EPG_dobleM $end                  $blue # $end"
	echo -e "$blue # ------------------------------------------------------------- #$end"
	echo -e "$blue #  $red¡ PRECAUCION! $end  $blue Comprueba que el sistema y los directorios  # $end" 
	echo -e "$blue #  de instalación sean correctos, en caso de duda no continues  # $end" 
	echo -e "$blue ################################################################# $end" 
	echo
	echo -e " Detectado el sistema operativo:  $yellow $INFO_SISTEMA $end"
	echo -e " Detectado directorio tvheadend:  $yellow $INFO_CARPETA_TVH $end"
	echo -e " Detectado directorio grabber:    $yellow $INFO_CARPETA_GRABBER $end"
	echo
	echo -e " Directorio instalación tvheadend:$green $CARPETA_TVH $end"
	echo -e " Directorio instalación grabber:  $green $CARPETA_GRABBER $end"
	echo
	echo -e " Vas a ejecutar el script:  $cyan $NOMBRE_SCRIPT $end"
	echo -e " Versión SATELITE instalada:$red $ver_local $end --->  Nueva versión:$green $ver_web $end"
	echo -e " Versión IPTV instalada:    $red $ver_local_IPTV $end --->  Nueva versión:$green $ver_web_IPTV $end"
	echo
	echo "-------------------------------------------------------------------"
	echo
	echo -e " 1)$green Hacer copia de seguridad de tvheadend $end"
	echo
	echo -e " 2)$cyan Instalar lista de canales$yellow SATELITE $end+ picons, grabber y configurar tvheadend $end"
	echo
	echo -e " 3)$cyan Instalar lista de canales$yellow IPTV $end+ picons, grabber y configurar tvheadend $end"
	echo
	echo -e " 4)$cyan Cambiar tipo de imágenes que aparecen en la guía $end"
	echo
	echo -e " 5)$blue Hacer una limpieza total de canales $end"
	echo
    echo -e " 6)$magenta Volver $end"
	echo
    echo -e " 7)$red Salir $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) clear && backup;;
		2) clear && install;;
		3) clear && installIPTV;;
		4) clear && imagenesgrabber;;
		5) clear && limpiezatotalcanales;;
		6) rm -rf $CARPETA_SCRIPT/$NOMBRE_SCRIPT && clear && sh $CARPETA_SCRIPT/i_dobleM.sh; break;;
		7) rm -rf $CARPETA_SCRIPT/i_*.sh; exit;;		
		*) echo "$opcion es una opción inválida\n";
	esac
done
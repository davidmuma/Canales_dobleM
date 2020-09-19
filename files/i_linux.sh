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
CARPETA_SCRIPT="$PWD"
CARPETA_TVH="/home/hts/.hts/tvheadend"
CARPETA_GRABBER="/usr/bin"

CARPETA_DOBLEM="$CARPETA_TVH/dobleM"

	USER_TVH=$(stat -c %U $CARPETA_TVH/config)
	GROUP_TVH=$(stat -c %G $CARPETA_TVH/config)
	PERMISSIONS_TVH=$(stat -c %a $CARPETA_TVH/config)

		TVHEADEND_PERMISSIONS="755"
		TVHEADEND_CHANNEL_PERMISSIONS="777"
        TVHEADEND_INPUT_PERMISSIONS="755"      
        TVHEADEND_PICONS_PERMISSIONS="755"
        TVHEADEND_EPGGRAB_PERMISSIONS="755"
		TVHEADEND_BOUQUET_PERMISSIONS="755"

# carpeta_channel="$CARPETA_TVH/channel/config/*"
# carpeta_tag="$CARPETA_TVH/channel/tag/*"

ver_local=`cat $CARPETA_TVH/dobleM.ver 2>/dev/null`
ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.ver 2>/dev/null`

INFO_SISTEMA="$(lsb_release -d | cut -f 2-10 -d":")"

clear

# Copia de seguridad
backup()
{
	echo "$blue Realizando copia de seguridad $end"
	cd $CARPETA_TVH
	if [ -f "$CARPETA_SCRIPT/Backup_Tvheadend_$(date +"%Y-%m-%d").tar.xz" ]; then
		FILE="Backup_Tvheadend_$(date +"%Y-%m-%d__%H-%M-%S").tar.xz"
		tar -cJf $CARPETA_SCRIPT/$FILE bouquet channel epggrab input/dvb picons 
		echo "$green Copia de seguridad completada. Pulsa intro para continuar... $end"
		read CAD
	else
		FILE="Backup_Tvheadend_$(date +"%Y-%m-%d").tar.xz"
		tar -cJf $CARPETA_SCRIPT/$FILE bouquet channel epggrab input/dvb picons 
		echo "$green Copia de seguridad completada. Pulsa intro para continuar... $end"
		read CAD
	fi
}

# Instalador
install()
{
	echo
	echo "$blue ################################################################ $end"
	echo "$blue ###  Iniciando instalación de lista de canales y EPG dobleM  ### $end" 
	echo "$blue ################################################################ $end" 	

#Paramos tvheadend para evitar conflictos al copiar y/o borrar archivos	
	echo
	echo "$magenta 1. Parando servicio tvheadend $end"
		sudo service tvheadend stop
				
# Borramos grabber anterior y carpeta dobleM. Vamos al directorio principal de tvheadend y borramos configuración actual	
	echo
	echo "$magenta 2. Borrando instalación anterior $end"
	rm -f $CARPETA_GRABBER/tv_grab_EPG_dobleM
	rm -rf $CARPETA_DOBLEM
	cd $CARPETA_TVH
	rm -rf picons/
	rm -rf bouquet/
	rm -rf channel/
	rm -rf epggrab/xmltv/
	rm -rf input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/

# Descargamos el tar de dobleM y lo descomprimimos en CARPETA_DOBLEM		
	echo
	echo "$magenta 3. Descargando nueva lista de canales $end" 		
		mkdir $CARPETA_DOBLEM
		cd $CARPETA_DOBLEM
		wget -q https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM.tar.xz
		tar -xf "dobleM.tar.xz"

# Empezamos a copiar los archivos necesarios
	echo	
	echo "$magenta 4. Instalando lista de canales dobleM $end"
		cp -r $CARPETA_DOBLEM/dobleM.ver $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/bouquet/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/channel/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/input/ $CARPETA_TVH
		cp -r $CARPETA_DOBLEM/picons/ $CARPETA_TVH

# Instalamos el grabber
	echo			
	echo "$magenta 5. Instalando grabber $end"		
		cp -r $CARPETA_DOBLEM/grabber/* $CARPETA_GRABBER
		cp -r $CARPETA_DOBLEM/epggrab/ $CARPETA_TVH
		sed -i -- "s,\"modid\":.*,\"modid\": \"$CARPETA_GRABBER/tv_grab_EPG_dobleM\"\,,g" $CARPETA_TVH/epggrab/xmltv/channels/*
	
while :	
do
	echo "   5a. Escoge que tipo de imágenes quieres que aparezcan en la guía:"
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
		
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_TVH/epggrab/
		chmod -R $TVHEADEND_EPGGRAB_PERMISSIONS $CARPETA_TVH/epggrab/
		
		chown -R $USER_TVH:$GROUP_TVH $CARPETA_GRABBER/tv_grab_EPG_dobleM
		chmod +rx $CARPETA_GRABBER/tv_grab_EPG_dobleM

# Damos permisos a los directorios
	echo
	echo "$magenta 6. Aplicando permisos $end"
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
	echo "$magenta 7. Configurando tvheadend $end"
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
		sed -i '/tv_grab_EPG_dobleM/,/},/d' $CARPETA_TVH/epggrab/config
		sed -i 's/"modules": {/"modules": {\n\t\t"CARPETA_GRABBER\/tv_grab_EPG_dobleM": {\n\t\t\t"class": "epggrab_mod_int_xmltv",\n\t\t\t"dn_chnum": 0,\n\t\t\t"name": "XMLTV: EPG_dobleM - Movistar+",\n\t\t\t"type": "Internal",\n\t\t\t"enabled": true,\n\t\t\t"priority": 3\n\t\t},/g' $CARPETA_TVH/epggrab/config
		sed -i "s,CARPETA_GRABBER,$CARPETA_GRABBER,g" $CARPETA_TVH/epggrab/config
		
# Borramos carpeta termporal dobleM
	echo
	echo "$magenta 8. Eliminando archivos temporales $end"
		rm -rf $CARPETA_DOBLEM
	
# Reiniciamos el servicio de TVH
	echo
	echo "$magenta 9. Iniciando servicio tvheadend $end"
		cd $CARPETA_SCRIPT
		sudo service tvheadend start

# Fin instalación
	echo 
	echo " Acuerdate de asignar en cada sintonizador \"Red DVB-S\" en la pestaña"
	echo "    Configuración --- Entradas DVB --- Adaptadores de TV"
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
	echo "$blue ################################################################# $end"
	echo "$blue ###                  Gracias por usar dobleM                  ### $end" 
	echo "$blue ################################################################# $end" 
	echo 
		rm -rf $CARPETA_SCRIPT/i_*.sh
}

# Menu instalacion
while :	
do
	echo "$blue ################################################################# $end" 
	echo "$blue #                       $green -= dobleM =- $end                         $blue # $end" 
	echo "$blue #                 Telegram: $cyan t.me/EPG_dobleM $end                  $blue # $end"
	echo "$blue # ------------------------------------------------------------- #$end"
	echo "$blue #  $red¡ PRECAUCION! $end  $blue Comprueba que el sistema y los directorios  # $end" 
	echo "$blue #  de instalación sean correctos, en caso de duda no continues  # $end" 
	echo "$blue #  Si continuas se borrará cualquier lista de canales anterior  # $end"
	echo "$blue ################################################################# $end" 
	echo
	echo " Se ha detectado el sistema operativo: $yellow $INFO_SISTEMA $end"
	echo
	echo " Vas a ejecutar el script:$green $NOMBRE_SCRIPT $end"
	echo " Directorio instalación tvheadend:$green $CARPETA_TVH $end"
	echo " Directorio instalación grabber:$green $CARPETA_GRABBER $end"
	echo
	echo " Versión instalada:$red $ver_local $end --->  Nueva versión:$green $ver_web $end"
	echo
	echo "------------------------------------------------------------------"
	echo
	echo " 1)$green Hacer copia de seguridad $end"
	echo
	echo " 2)$blue Instalar lista de canales, picons, grabber y configurar tvheadend $end"
	echo 
    echo " 3)$red Volver $end"
	echo
	echo -n " Indica una opción: "
	read opcion
	case $opcion in
		1) backup && clear;;
		2) install; break;;
		3) rm -rf $CARPETA_SCRIPT/$NOMBRE_SCRIPT && clear && sudo sh $CARPETA_SCRIPT/i_dobleM.sh; break;;	
		*) echo "$opcion es una opción inválida\n";
	esac
done